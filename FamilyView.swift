//
//  FamilyView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-25.
//

import SwiftUI
import UIKit
import Combine

enum DepositFrequency: String, CaseIterable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case Self.monthly.rawValue:
            self = .monthly
        case Self.weekly.rawValue, "Daily":
            self = .weekly
        default:
            self = .weekly
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - Kid avatar (`Avatar.xcassets` + SF Symbol fallback)

enum KidAvatarCatalog {
    /// Ordered assets in `Avatar.xcassets` shown in Add/Edit kid → icon picker (first tab). `Avatar1` … `Avatar21`.
    static let pickerAssetNames: [String] = (1...21).map { "Avatar\($0)" }
}

struct KidStoredIconView: View {
    let iconName: String
    let customImageData: Data?
    var size: CGFloat = 50
    var symbolAccentColor: Color = .blue

    var body: some View {
        Group {
            if let data = customImageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if UIImage(named: iconName) != nil {
                Image(iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(symbolAccentColor.opacity(0.15))
                        .frame(width: size, height: size)
                    Image(systemName: iconName)
                        .font(.system(size: size * 0.42, weight: .regular))
                        .foregroundColor(symbolAccentColor)
                }
            }
        }
    }
}

final class FamilyStore: ObservableObject {
    @Published var kids: [FamilyKid] = [] {
        didSet { saveKids() }
    }

    private let storageKey = "family.kids.storage"

    init() {
        loadKids()
    }

    func addKid(_ kid: FamilyKid) {
        kids.append(kid)
    }

    func updateKid(_ updatedKid: FamilyKid) {
        guard let index = kids.firstIndex(where: { $0.id == updatedKid.id }) else { return }
        kids[index] = updatedKid
    }

    func deleteKid(id: UUID) {
        kids.removeAll { $0.id == id }
    }

    func clearAllKids() {
        kids = []
    }

    /// Credits scheduled allowance when the calendar matches the kid’s frequency and it is on or after their deposit time.
    func processScheduledAllowanceIfNeeded(activityStore: ActivityStore, historyStore: HistoryStore) {
        let calendar = Calendar.current
        let now = Date()
        var newKids = kids
        var didChange = false

        for index in newKids.indices {
            var kid = newKids[index]
            guard kid.weeklyAllowance > 0 else { continue }
            guard Self.isPastOrAtDepositTime(depositTime: kid.depositTime, now: now, calendar: calendar) else { continue }

            switch kid.depositFrequency {
            case .weekly:
                guard calendar.component(.weekday, from: now) == kid.depositWeekday else { continue }
                if let last = kid.lastScheduledAllowancePaymentAt {
                    let y1 = calendar.component(.yearForWeekOfYear, from: last)
                    let w1 = calendar.component(.weekOfYear, from: last)
                    let y2 = calendar.component(.yearForWeekOfYear, from: now)
                    let w2 = calendar.component(.weekOfYear, from: now)
                    if y1 == y2 && w1 == w2 {
                        continue
                    }
                }
            case .monthly:
                guard calendar.component(.day, from: now) == kid.depositMonthlyDay else { continue }
                if let last = kid.lastScheduledAllowancePaymentAt, calendar.isDate(last, equalTo: now, toGranularity: .month) {
                    continue
                }
            }

            let amount = kid.weeklyAllowance
            kid.currentBalance += amount
            kid.lastScheduledAllowancePaymentAt = now

            let lang = AppLanguage.stored
            let scheduleLabel = AppStringCatalog.displayDepositFrequency(kid.depositFrequency, language: lang)
            let notePattern = AppStringCatalog.string(.noteScheduledAllowanceFormat, language: lang)
            let note = String(format: notePattern, locale: lang.locale, arguments: [scheduleLabel])

            activityStore.addTransaction(
                kidId: kid.id,
                kidName: kid.name,
                amount: amount,
                note: note,
                isDeposit: true,
                isInterest: false,
                date: now
            )
            historyStore.recordScheduledAllowancePaid(kidId: kid.id, kidName: kid.name, amount: amount, scheduleLabel: scheduleLabel)

            newKids[index] = kid
            didChange = true
        }

        if didChange {
            kids = newKids
        }
    }

    /// Applies monthly interest on the **1st** of each calendar month (once per kid per month).
    func processMonthlyInterestIfNeeded(activityStore: ActivityStore, historyStore: HistoryStore) {
        let calendar = Calendar.current
        let now = Date()
        guard calendar.component(.day, from: now) == 1 else { return }

        let monthKey = Self.monthYearKey(for: now)
        var newKids = kids
        var didChange = false

        for index in newKids.indices {
            guard newKids[index].lastInterestAppliedMonthKey != monthKey else { continue }
            var kid = newKids[index]

            if kid.monthlyInterestPercent > 0, kid.currentBalance > 0 {
                let rawBonus = kid.currentBalance * Double(kid.monthlyInterestPercent) / 100.0
                let bonus = (rawBonus * 100).rounded() / 100
                if bonus > 0 {
                    kid.currentBalance += bonus
                    let lang = AppLanguage.stored
                    let notePattern = AppStringCatalog.string(.noteMonthlyInterestFormat, language: lang)
                    let note = String(format: notePattern, locale: lang.locale, arguments: [kid.monthlyInterestPercent])

                    activityStore.addTransaction(
                        kidId: kid.id,
                        kidName: kid.name,
                        amount: bonus,
                        note: note,
                        isDeposit: true,
                        isInterest: true,
                        date: now
                    )
                    historyStore.recordMonthlyInterestCredited(
                        kidId: kid.id,
                        kidName: kid.name,
                        percent: kid.monthlyInterestPercent,
                        amount: bonus
                    )
                }
            }

            kid.lastInterestAppliedMonthKey = monthKey
            newKids[index] = kid
            didChange = true
        }

        if didChange {
            kids = newKids
        }
    }

    private static func isPastOrAtDepositTime(depositTime: Date, now: Date, calendar: Calendar) -> Bool {
        let hour = calendar.component(.hour, from: depositTime)
        let minute = calendar.component(.minute, from: depositTime)
        guard let threshold = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
            return true
        }
        return now >= threshold
    }

    private static func monthYearKey(for date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return String(format: "%04d-%02d", year, month)
    }

    private func loadKids() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([FamilyKid].self, from: data)
        else {
            kids = []
            return
        }

        kids = decoded
    }

    private func saveKids() {
        guard let data = try? JSONEncoder().encode(kids) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

struct FamilyView: View {
    var body: some View {
        HistoryView()
    }
}

enum FamilyBulkTransactionType: String, Identifiable {
    case deposit
    case withdraw

    var id: String { rawValue }
    func title(language: LanguageManager) -> String {
        self == .deposit ? language.text(.familyDeposit) : language.text(.familyWithdraw)
    }

    func actionTitle(language: LanguageManager) -> String {
        self == .deposit ? language.text(.familyBulkAdd) : language.text(.familyBulkWithdrawAction)
    }

    var isDeposit: Bool { self == .deposit }
}

struct FamilyBulkTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var familyStore: FamilyStore

    let type: FamilyBulkTransactionType
    let onConfirm: (Double, String, Set<UUID>) -> Void

    @State private var amount = ""
    @State private var note = ""
    @State private var selectedKidIDs: Set<UUID>
    @State private var attemptedSubmit = false

    init(
        type: FamilyBulkTransactionType,
        initialSelectedKidIDs: Set<UUID>? = nil,
        onConfirm: @escaping (Double, String, Set<UUID>) -> Void
    ) {
        self.type = type
        self.onConfirm = onConfirm
        _selectedKidIDs = State(initialValue: initialSelectedKidIDs ?? [])
    }
    
    private var allKidIDs: Set<UUID> {
        Set(familyStore.kids.map(\.id))
    }
    
    private var allSelected: Bool {
        !allKidIDs.isEmpty && selectedKidIDs == allKidIDs
    }

    private var isAmountValid: Bool { (Double(amount) ?? 0) > 0 }
    private var isNoteValid: Bool { !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isKidsValid: Bool { !selectedKidIDs.isEmpty }
    private var isValid: Bool { isAmountValid && isNoteValid && isKidsValid }

    private var selectedKids: [FamilyKid] {
        familyStore.kids.filter { selectedKidIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: type.title(language: languageManager),
                    leadingTitle: languageManager.text(.commonCancel),
                    trailingTitle: type.actionTitle(language: languageManager),
                    onLeading: { dismiss() },
                    onTrailing: {
                        attemptedSubmit = true
                        guard isValid, let value = Double(amount) else { return }
                        onConfirm(value, note, selectedKidIDs)
                        dismiss()
                    }
                )
                Form {
                Section(languageManager.text(.familyBulkAmount)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill((type.isDeposit ? Color.appGreen : Color.appRed).opacity(colorScheme == .dark ? 0.2 : 0.14))
                        KidAllowanceInputRow(
                            text: $amount,
                            symbol: currencyManager.getCurrencySymbol(),
                            isValid: isAmountValid,
                            showErrorAppearance: attemptedSubmit,
                            placeholderOK: "0.00",
                            placeholderError: languageManager.text(.familyBulkAmountRequired)
                        )
                        .frame(minHeight: 48)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .onChange(of: amount) { _, newValue in
                    amount = sanitizeNumericInput(newValue)
                }

                Section(languageManager.text(.familyBulkNote)) {
                    TextField(
                        "",
                        text: $note,
                        prompt: Text(
                            attemptedSubmit && !isNoteValid
                            ? languageManager.text(.familyBulkNoteRequired)
                            : languageManager.text(.familyBulkNote)
                        ).foregroundColor(attemptedSubmit && !isNoteValid ? .red : .secondary)
                    )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    ForEach(familyStore.kids) { kid in
                        Button {
                            if selectedKidIDs.contains(kid.id) {
                                selectedKidIDs.remove(kid.id)
                            } else {
                                selectedKidIDs.insert(kid.id)
                            }
                        } label: {
                            HStack {
                                Text(kid.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: selectedKidIDs.contains(kid.id) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(selectedKidIDs.contains(kid.id) ? .blue : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    if !selectedKids.isEmpty {
                        SelectedKidsOverlappingAvatars(kids: selectedKids)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                            .padding(.bottom, 12)
                            .padding(.horizontal, 8)
                            .listRowSeparator(.hidden)
                    }
                } header: {
                    HStack {
                        Text(languageManager.text(.familyKidsSection))
                            .foregroundStyle(attemptedSubmit && !isKidsValid ? .red : .primary)
                        Spacer()
                        Button {
                            if allSelected {
                                selectedKidIDs.removeAll()
                            } else {
                                selectedKidIDs = allKidIDs
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(languageManager.text(.familySelectAll))
                                Image(systemName: allSelected ? "checkmark.square.fill" : "square")
                            }
                        }
                        .buttonStyle(.plain)
                        .textCase(nil)
                    }
                } footer: {
                    if attemptedSubmit && !isKidsValid {
                        Text(languageManager.text(.familyBulkKidsRequired))
                            .foregroundStyle(.red)
                    }
                }
            }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    private func sanitizeNumericInput(_ input: String) -> String {
        var result = ""
        var hasDecimalSeparator = false

        for character in input {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !hasDecimalSeparator {
                hasDecimalSeparator = true
                result.append(character)
            }
        }

        return result
    }
}

/// Stacked profile photos for selected kids (same sources as Add/Edit kid).
struct SelectedKidsOverlappingAvatars: View {
    let kids: [FamilyKid]
    var avatarSize: CGFloat = 72
    /// Each avatar to the right covers this fraction of the previous one (0.7 → 30% of prior photo still visible).
    var overlapHiddenFraction: CGFloat = 0.7

    var body: some View {
        Group {
            if kids.isEmpty {
                Color.clear
                    .frame(height: 0)
            } else {
                HStack(spacing: -avatarSize * overlapHiddenFraction) {
                    ForEach(Array(kids.enumerated()), id: \.element.id) { index, kid in
                        KidStoredIconView(
                            iconName: kid.icon,
                            customImageData: kid.customImageData,
                            size: avatarSize,
                            symbolAccentColor: kid.iconColor
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color(.systemBackground), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .zIndex(Double(index))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: kids.map(\.id))
    }
}

private struct FamilyKidRow: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let kid: FamilyKid
    let isDarkMode: Bool

    var body: some View {
        HStack(spacing: 16) {
            KidStoredIconView(
                iconName: kid.icon,
                customImageData: kid.customImageData,
                size: 50,
                symbolAccentColor: kid.iconColor
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(kid.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(
                    String(
                        format: languageManager.text(.allowanceLineFormat),
                        locale: languageManager.locale,
                        arguments: [
                            AppStringCatalog.displayDepositFrequency(kid.depositFrequency, language: languageManager.language),
                            currencyManager.formatAmount(kid.weeklyAllowance)
                        ]
                    )
                )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Text(currencyManager.formatAmount(kid.currentBalance))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(kid.currentBalance < 0 ? .appRed : .appGreen)
        }
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

/// Allowance amount + currency symbol, centered as a unit (SwiftUI `TextField` + `Form` layout fights horizontal centering).
struct KidAllowanceInputRow: UIViewRepresentable {
    @Binding var text: String
    let symbol: String
    let isValid: Bool
    let showErrorAppearance: Bool
    let placeholderOK: String
    let placeholderError: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.isLayoutMarginsRelativeArrangement = false

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.textAlignment = .right
        textField.adjustsFontForContentSizeCategory = true
        textField.keyboardType = .decimalPad
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)

        let symbolLabel = UILabel()
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.adjustsFontForContentSizeCategory = true
        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(symbolLabel)

        container.addSubview(stack)

        let widthConstraint = textField.widthAnchor.constraint(equalToConstant: 88)
        widthConstraint.priority = .required

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            widthConstraint,
        ])

        context.coordinator.textField = textField
        context.coordinator.symbolLabel = symbolLabel
        context.coordinator.widthConstraint = widthConstraint

        context.coordinator.applyAll()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applyAll()
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KidAllowanceInputRow
        weak var textField: UITextField?
        weak var symbolLabel: UILabel?
        var widthConstraint: NSLayoutConstraint?

        init(_ parent: KidAllowanceInputRow) {
            self.parent = parent
        }

        private static func boldBodyFont() -> UIFont {
            let base = UIFont.preferredFont(forTextStyle: .body)
            if let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) {
                return UIFont(descriptor: descriptor, size: 0)
            }
            return base
        }

        func applyAll() {
            guard let textField, let symbolLabel else { return }
            let font = Self.boldBodyFont()
            textField.font = font
            symbolLabel.font = font

            let showInvalid = parent.showErrorAppearance && !parent.isValid
            textField.textColor = showInvalid ? .systemRed : .label
            symbolLabel.textColor = showInvalid ? .systemRed : .secondaryLabel
            textField.placeholder = showInvalid ? parent.placeholderError : parent.placeholderOK

            if textField.text != parent.text {
                textField.text = parent.text
            }
            symbolLabel.text = parent.symbol

            updateTextFieldWidth()
        }

        func updateTextFieldWidth() {
            guard let textField, let widthConstraint else { return }
            let font = textField.font ?? Self.boldBodyFont()
            let raw = textField.text ?? ""
            let measure: String = {
                if raw.isEmpty {
                    return textField.placeholder ?? parent.placeholderOK
                }
                return raw
            }()
            let w = (measure as NSString).size(withAttributes: [.font: font]).width
            widthConstraint.constant = max(56, min(280, ceil(w) + 20))
            textField.layoutIfNeeded()
        }

        @objc func editingChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
            updateTextFieldWidth()
        }
    }
}

/// Centered bold text field for form pills (e.g. goal name), matching `KidAllowanceInputRow` layout.
struct KidCenteredTextInputRow: UIViewRepresentable {
    @Binding var text: String
    let isValid: Bool
    let showErrorAppearance: Bool
    let placeholderOK: String
    let placeholderError: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.adjustsFontForContentSizeCategory = true
        textField.keyboardType = .default
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)

        container.addSubview(textField)

        let widthConstraint = textField.widthAnchor.constraint(equalToConstant: 120)
        widthConstraint.priority = .required

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            widthConstraint,
        ])

        context.coordinator.textField = textField
        context.coordinator.widthConstraint = widthConstraint
        context.coordinator.applyAll()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applyAll()
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KidCenteredTextInputRow
        weak var textField: UITextField?
        var widthConstraint: NSLayoutConstraint?

        init(_ parent: KidCenteredTextInputRow) {
            self.parent = parent
        }

        private static func boldBodyFont() -> UIFont {
            let base = UIFont.preferredFont(forTextStyle: .body)
            if let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) {
                return UIFont(descriptor: descriptor, size: 0)
            }
            return base
        }

        func applyAll() {
            guard let textField else { return }
            let font = Self.boldBodyFont()
            textField.font = font

            let showInvalid = parent.showErrorAppearance && !parent.isValid
            textField.textColor = showInvalid ? .systemRed : .label
            textField.placeholder = showInvalid ? parent.placeholderError : parent.placeholderOK
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [
                    .foregroundColor: showInvalid ? UIColor.systemRed : UIColor.secondaryLabel,
                    .font: font,
                ]
            )

            if textField.text != parent.text {
                textField.text = parent.text
            }

            updateTextFieldWidth()
        }

        func updateTextFieldWidth() {
            guard let textField, let widthConstraint else { return }
            let font = textField.font ?? Self.boldBodyFont()
            let raw = textField.text ?? ""
            let measure: String = {
                if raw.isEmpty {
                    return textField.placeholder ?? parent.placeholderOK
                }
                return raw
            }()
            let w = (measure as NSString).size(withAttributes: [.font: font]).width
            widthConstraint.constant = max(80, min(280, ceil(w) + 24))
            textField.layoutIfNeeded()
        }

        @objc func editingChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
            updateTextFieldWidth()
        }
    }
}

/// Monthly interest percent (0–30): **value + %** is centered in the pill; chevrons sit just outside that group.
private struct KidPercentInputRow: UIViewRepresentable {
    @Binding var percent: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let downButton = Self.makeStepButton(systemName: "chevron.down", accessibilityLabelKey: "Decrease")
        downButton.addTarget(context.coordinator, action: #selector(Coordinator.stepDown), for: .touchUpInside)

        let valueStack = UIStackView()
        valueStack.translatesAutoresizingMaskIntoConstraints = false
        valueStack.axis = .horizontal
        valueStack.alignment = .center
        valueStack.spacing = 3
        valueStack.isLayoutMarginsRelativeArrangement = false
        valueStack.setContentHuggingPriority(.required, for: .horizontal)
        valueStack.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.textAlignment = .right
        textField.adjustsFontForContentSizeCategory = true
        textField.keyboardType = .numberPad
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        textField.setContentHuggingPriority(.required, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)

        let symbolLabel = UILabel()
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.adjustsFontForContentSizeCategory = true
        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        valueStack.addArrangedSubview(textField)
        valueStack.addArrangedSubview(symbolLabel)

        let upButton = Self.makeStepButton(systemName: "chevron.up", accessibilityLabelKey: "Increase")
        upButton.addTarget(context.coordinator, action: #selector(Coordinator.stepUp), for: .touchUpInside)

        container.addSubview(valueStack)
        container.addSubview(downButton)
        container.addSubview(upButton)

        let widthConstraint = textField.widthAnchor.constraint(equalToConstant: 88)
        widthConstraint.priority = .required

        let arrowGap: CGFloat = 10

        NSLayoutConstraint.activate([
            valueStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            widthConstraint,

            downButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            downButton.trailingAnchor.constraint(equalTo: valueStack.leadingAnchor, constant: -arrowGap),
            downButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            downButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            {
                let c = downButton.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 4)
                c.priority = .defaultHigh
                return c
            }(),

            upButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            upButton.leadingAnchor.constraint(equalTo: valueStack.trailingAnchor, constant: arrowGap),
            upButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            upButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            {
                let c = upButton.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -4)
                c.priority = .defaultHigh
                return c
            }(),
        ])

        context.coordinator.textField = textField
        context.coordinator.symbolLabel = symbolLabel
        context.coordinator.widthConstraint = widthConstraint
        context.coordinator.upButton = upButton
        context.coordinator.downButton = downButton

        context.coordinator.applyAll()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.applyAll()
    }

    private static func makeStepButton(systemName: String, accessibilityLabelKey: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let img = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body), scale: .medium))
        button.setImage(img, for: .normal)
        button.tintColor = .secondaryLabel
        button.accessibilityLabel = accessibilityLabelKey
        button.contentMode = .center
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: KidPercentInputRow
        weak var textField: UITextField?
        weak var symbolLabel: UILabel?
        weak var upButton: UIButton?
        weak var downButton: UIButton?
        var widthConstraint: NSLayoutConstraint?

        init(_ parent: KidPercentInputRow) {
            self.parent = parent
        }

        private static func boldBodyFont() -> UIFont {
            let base = UIFont.preferredFont(forTextStyle: .body)
            if let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) {
                return UIFont(descriptor: descriptor, size: 0)
            }
            return base
        }

        func applyAll() {
            guard let textField, let symbolLabel else { return }
            let font = Self.boldBodyFont()
            textField.font = font
            symbolLabel.font = font
            textField.textColor = .label
            symbolLabel.textColor = .secondaryLabel
            textField.placeholder = nil

            let display = "\(parent.percent)"
            if !textField.isFirstResponder {
                textField.text = display
            }
            symbolLabel.text = "%"

            upButton?.isEnabled = parent.percent < 30
            downButton?.isEnabled = parent.percent > 0

            updateTextFieldWidth()
        }

        func updateTextFieldWidth() {
            guard let textField, let widthConstraint else { return }
            let font = textField.font ?? Self.boldBodyFont()
            let raw = textField.text ?? ""
            let measure = raw.isEmpty ? "\(parent.percent)" : raw
            let w = (measure as NSString).size(withAttributes: [.font: font]).width
            // Right-aligned + tight width so digits sit flush next to “%”.
            widthConstraint.constant = max(24, min(120, ceil(w) + 6))
            textField.layoutIfNeeded()
        }

        @objc func stepUp() {
            textField?.resignFirstResponder()
            parent.percent = min(30, parent.percent + 1)
            applyAll()
        }

        @objc func stepDown() {
            textField?.resignFirstResponder()
            parent.percent = max(0, parent.percent - 1)
            applyAll()
        }

        @objc func editingChanged(_ sender: UITextField) {
            let digits = (sender.text ?? "").filter { $0.isNumber }
            guard !digits.isEmpty else {
                parent.percent = 0
                sender.text = "0"
                updateTextFieldWidth()
                applyAll()
                return
            }
            var v = Int(digits) ?? 0
            if v > 30 { v = 30 }
            if v < 0 { v = 0 }
            parent.percent = v
            let display = "\(v)"
            if sender.text != display {
                sender.text = display
            }
            updateTextFieldWidth()
            applyAll()
        }
    }
}

struct AddEditKidView: View {
    enum Mode {
        case add
        case edit(FamilyKid)
    }

    /// Matches the green allowance amount inner frame.
    private static let contentCornerRadius: CGFloat = 10

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var currencyManager: CurrencyManager

    let mode: Mode
    let onDelete: ((UUID, String) -> Void)?
    let onSave: (FamilyKid) -> Void

    @State private var name = ""
    @State private var weeklyAllowance = ""
    @State private var currentBalance = "0.00"
    @State private var selectedIcon = KidAvatarCatalog.pickerAssetNames.first ?? "person.fill"
    @State private var selectedImage: UIImage?
    @State private var showingIconPicker = false
    /// `nil` until the user picks a date (or an existing kid birthday is loaded).
    @State private var birthday: Date?
    /// DatePicker selection; kept separate so a rolling “default” is never written into `birthday`.
    @State private var birthdayPickerDate = Self.fixedBirthdayPlaceholder
    @State private var birthdayIsSet = false
    @State private var suppressBirthdayPickerSync = false
    @State private var selectedWeekday = 2
    @State private var depositTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingDepositTimePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var monthlyInterestPercent = 5
    @State private var attemptedSave = false

    /// Stable placeholder for the picker when no birthday is saved (must not depend on `Date()`).
    private static var fixedBirthdayPlaceholder: Date {
        Calendar.current.date(from: DateComponents(year: 2015, month: 6, day: 15)) ?? Date(timeIntervalSince1970: 0)
    }

    private func applyBirthdayFromKid(_ stored: Date?) {
        suppressBirthdayPickerSync = true
        if let stored {
            let normalized = Calendar.current.startOfDay(for: stored)
            birthday = normalized
            birthdayPickerDate = normalized
            birthdayIsSet = true
        } else {
            birthday = nil
            birthdayPickerDate = Self.fixedBirthdayPlaceholder
            birthdayIsSet = false
        }
        DispatchQueue.main.async {
            suppressBirthdayPickerSync = false
        }
    }

    private func syncBirthdayFromPicker(_ newValue: Date) {
        guard !suppressBirthdayPickerSync else { return }
        let normalized = Calendar.current.startOfDay(for: newValue)
        let cal = Calendar.current
        if !birthdayIsSet, cal.isDate(normalized, inSameDayAs: Self.fixedBirthdayPlaceholder) {
            return
        }
        birthdayPickerDate = normalized
        birthday = normalized
        birthdayIsSet = true
    }

    /// Short weekday labels Mon…Sun, aligned with `selectedWeekday` (`Calendar` weekday: 1 = Sunday … 7 = Saturday).
    private var shortWeekdayLabelsMondayFirst: [String] {
        let cal = Calendar.autoupdatingCurrent
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        var d = cal.startOfDay(for: Date())
        for _ in 0..<14 {
            if cal.component(.weekday, from: d) == 2 { break }
            guard let prev = cal.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        guard cal.component(.weekday, from: d) == 2 else {
            return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
        let mapped = (0..<7).compactMap { offset -> String? in
            guard let day = cal.date(byAdding: .day, value: offset, to: d) else { return nil }
            return formatter.string(from: day)
        }
        if mapped.count == 7 {
            return mapped
        }
        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    private var kidProfileSubtitle: String {
        let freq = AppStringCatalog.displayDepositFrequency(.weekly, language: languageManager.language)
        if let val = Double(weeklyAllowance), val > 0 {
            return String(
                format: languageManager.text(.allowanceLineFormat),
                locale: languageManager.locale,
                arguments: [freq, currencyManager.formatAmount(val)]
            )
        }
        return freq
    }

    private var profileHeroCardFill: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)
    }

    private var profileSubtitleColor: Color {
        colorScheme == .dark
            ? Color(red: 0.58, green: 0.76, blue: 0.98)
            : Color(red: 0.34, green: 0.54, blue: 0.86)
    }

    private var profileAvatarSymbolColor: Color {
        colorScheme == .dark
            ? Color(red: 0.55, green: 0.72, blue: 0.96)
            : Color(red: 0.35, green: 0.55, blue: 0.9)
    }

    @ViewBuilder
    private var kidDetailsHeroSection: some View {
        let avatarSize: CGFloat = 90
        let cornerRadius = Self.contentCornerRadius
        /// How much the card is pulled up under the avatar (larger = card top closer to sheet top; avatar unchanged).
        let avatarCardOverlap: CGFloat = 60

        VStack(spacing: -avatarCardOverlap) {
            Button {
                showingIconPicker = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: avatarSize, height: avatarSize)
                                .clipShape(Circle())
                        } else {
                            KidStoredIconView(
                                iconName: selectedIcon,
                                customImageData: nil,
                                size: avatarSize,
                                symbolAccentColor: profileAvatarSymbolColor
                            )
                        }
                    }
                    .frame(width: avatarSize, height: avatarSize)
                    .background(Circle().fill(profileHeroCardFill))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.07), lineWidth: 1)
                    )

                    Image(systemName: "camera.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.black.opacity(0.48)))
                        .padding(4)
                }
                .frame(width: avatarSize, height: avatarSize)
                .shadow(
                    color: VeckoCreditCardChrome.shadowColor,
                    radius: VeckoCreditCardChrome.shadowRadius,
                    x: VeckoCreditCardChrome.shadowX,
                    y: VeckoCreditCardChrome.shadowY
                )
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .zIndex(1)
            .accessibilityLabel(languageManager.text(.kidSelectIcon))
            .accessibilityHint(languageManager.text(.kidProfileTapPhoto))

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: max(0, avatarSize - avatarCardOverlap + 8))

                TextField(
                    "",
                    text: $name,
                    prompt: Text(isNameValid || !attemptedSave ? languageManager.text(.kidNamePlaceholder) : languageManager.text(.kidNameRequired))
                        .foregroundColor(isNameValid || !attemptedSave ? .secondary : .red)
                )
                .multilineTextAlignment(.center)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .padding(.top, 25)

                Text(kidProfileSubtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(profileSubtitleColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                Divider()
                    .padding(.top, 14)
                    .padding(.bottom, 12)

                HStack(alignment: .center, spacing: 8) {
                    Text(languageManager.text(.kidBirthday))
                        .foregroundStyle(.primary)
                        .layoutPriority(1)
                    Spacer(minLength: 0)
                    DatePicker(
                        "",
                        selection: $birthdayPickerDate,
                        displayedComponents: [.date]
                    )
                    .onChange(of: birthdayPickerDate) { _, newValue in
                        syncBirthdayFromPicker(newValue)
                    }
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.locale, languageManager.locale)
                    .fixedSize()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                Spacer()
                    .frame(height: 16)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(profileHeroCardFill)
            )
            .zIndex(0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 5)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: isEditMode ? languageManager.text(.kidNavEdit) : languageManager.text(.kidNavAdd),
                    leadingTitle: languageManager.text(.commonCancel),
                    trailingTitle: languageManager.text(.commonSave),
                    onLeading: { dismiss() },
                    onTrailing: { saveKid() }
                )
                Form {
                Section {
                    kidDetailsHeroSection
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden, edges: .all)
                }

                Section(languageManager.text(.kidSectionAllowance)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Self.contentCornerRadius, style: .continuous)
                            .fill(Color.appGreen.opacity(colorScheme == .dark ? 0.2 : 0.14))
                        KidAllowanceInputRow(
                            text: $weeklyAllowance,
                            symbol: currencyManager.getCurrencySymbol(),
                            isValid: isWeeklyAllowanceValid,
                            showErrorAppearance: attemptedSave,
                            placeholderOK: "0.00",
                            placeholderError: languageManager.text(.kidWeeklyAllowanceRequired)
                        )
                        .frame(minHeight: 48)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section(languageManager.text(.kidMonthlyInterestHeader)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Self.contentCornerRadius, style: .continuous)
                            .fill(Color.yellow.opacity(colorScheme == .dark ? 0.2 : 0.18))
                        KidPercentInputRow(percent: $monthlyInterestPercent)
                            .frame(minHeight: 48)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section(languageManager.text(.kidSectionSchedule)) {
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            let weekday = ((index + 1) % 7) + 1
                            let isSelected = selectedWeekday == weekday
                            Button {
                                selectedWeekday = weekday
                            } label: {
                                VStack(spacing: 4) {
                                    Text(shortWeekdayLabelsMondayFirst[index])
                                        .font(.caption.weight(isSelected ? .bold : .medium))
                                        .minimumScaleFactor(0.65)
                                        .lineLimit(1)
                                        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(isSelected ? Color.gray : Color.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: Self.contentCornerRadius, style: .continuous)
                                        .fill(
                                            isSelected
                                                ? Color.yellow.opacity(colorScheme == .dark ? 0.2 : 0.18)
                                                : Color(UIColor.secondarySystemGroupedBackground)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 6)

                    Button {
                        showingDepositTimePicker = true
                    } label: {
                        HStack {
                            Text(languageManager.text(.kidDepositTime))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text(depositTimeString)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }

                }

                if isEditMode {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Text(languageManager.text(.kidDelete))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingIconPicker) {
                KidIconPickerView(selectedIcon: $selectedIcon, selectedImage: $selectedImage)
                    .environmentObject(languageManager)
            }
            .popover(isPresented: $showingDepositTimePicker) {
                VStack {
                    DatePicker(
                        languageManager.text(.kidDepositTime),
                        selection: $depositTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .frame(height: 200)
                    .padding()
                }
                .frame(width: 300, height: 250)
                .presentationDetents([.height(250)])
            }
            .alert(languageManager.text(.kidDeleteConfirmTitle), isPresented: $showingDeleteConfirmation) {
                Button(languageManager.text(.commonCancel), role: .cancel) { }
                Button(languageManager.text(.kidYes), role: .destructive) {
                    deleteKid()
                }
            } message: {
                Text(languageManager.text(.kidDeleteConfirmMessage))
            }
        }
        .onAppear {
            switch mode {
            case .add:
                currentBalance = "0.00"
                applyBirthdayFromKid(nil)
                depositTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            case .edit(let kid):
                name = kid.name
                applyBirthdayFromKid(kid.birthday)
                weeklyAllowance = String(format: "%.2f", kid.weeklyAllowance)
                currentBalance = String(format: "%.2f", kid.currentBalance)
                selectedIcon = kid.icon
                selectedWeekday = kid.depositWeekday
                depositTime = kid.depositTime
                monthlyInterestPercent = kid.monthlyInterestPercent
                if let data = kid.customImageData {
                    selectedImage = UIImage(data: data)
                }
            }
        }
    }

    private var isEditMode: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isWeeklyAllowanceValid: Bool {
        guard let value = Double(weeklyAllowance) else { return false }
        return value > 0
    }

    private func saveKid() {
        attemptedSave = true
        guard isNameValid, isWeeklyAllowanceValid else { return }
        guard
            let weeklyValue = Double(weeklyAllowance),
            let balanceValue = Double(currentBalance)
        else { return }

        let existingID: UUID
        switch mode {
        case .add:
            existingID = UUID()
        case .edit(let kid):
            existingID = kid.id
        }

        let savedKid = FamilyKid(
            id: existingID,
            name: name,
            birthday: birthdayIsSet ? birthday : nil,
            weeklyAllowance: weeklyValue,
            currentBalance: balanceValue,
            icon: selectedIcon,
            customImageData: selectedImage?.jpegData(compressionQuality: 0.8),
            depositFrequency: .weekly,
            depositWeekday: selectedWeekday,
            depositMonthlyDay: 1,
            depositTime: depositTime,
            monthlyInterestPercent: monthlyInterestPercent,
            lastInterestAppliedMonthKey: {
                if case .edit(let existing) = mode {
                    return existing.lastInterestAppliedMonthKey
                }
                return nil
            }(),
            lastScheduledAllowancePaymentAt: {
                if case .edit(let existing) = mode {
                    return existing.lastScheduledAllowancePaymentAt
                }
                return nil
            }()
        )

        onSave(savedKid)
        dismiss()
    }

    private func deleteKid() {
        guard case .edit(let kid) = mode else { return }
        onDelete?(kid.id, name)
        dismiss()
    }

    private var depositTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.timeStyle = .short
        return formatter.string(from: depositTime)
    }

}

private struct KidIconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedIcon: String
    @Binding var selectedImage: UIImage?
    @State private var selectedTab = 1
    @State private var showingImagePicker = false

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.iconPickerNavSelect),
                    trailingTitle: languageManager.text(.commonDone),
                    onTrailing: { dismiss() }
                )
                Picker(languageManager.text(.pickerSelection), selection: $selectedTab) {
                    Text(languageManager.text(.iconPickerIcons)).tag(0)
                    Text(languageManager.text(.iconPickerPhotos)).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(KidAvatarCatalog.pickerAssetNames, id: \.self) { assetName in
                                Button {
                                    selectedIcon = assetName
                                    selectedImage = nil
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.12))
                                            .frame(width: 58, height: 58)
                                        Image(assetName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 54, height: 54)
                                            .clipShape(Circle())
                                        if selectedIcon == assetName {
                                            Circle()
                                                .stroke(Color.blue, lineWidth: 3)
                                                .frame(width: 58, height: 58)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Spacer()

                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 58))
                                .foregroundColor(.gray)
                        }

                        Button(selectedImage == nil ? languageManager.text(.iconPickerSelectImage) : languageManager.text(.iconPickerChangeImage)) {
                            showingImagePicker = true
                        }
                        .buttonStyle(.bordered)

                        Spacer()
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

struct FamilyKid: Identifiable {
    let id: UUID
    var name: String
    /// Stored when the parent sets a birthday in kid details; `nil` means not set.
    var birthday: Date?
    var weeklyAllowance: Double
    var currentBalance: Double
    var icon: String
    var customImageData: Data?
    var depositFrequency: DepositFrequency = .weekly
    var depositWeekday: Int = 2
    var depositMonthlyDay: Int = 1
    var depositTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    /// Allowed day-of-month when `depositFrequency` is `.monthly` (three chips in Add/Edit kid).
    static let allowedMonthlyPayDays: [Int] = [1, 5, 10]

    /// Maps stored or legacy day values to the nearest allowed chip (ties → smaller day).
    static func normalizedMonthlyPayDay(_ day: Int) -> Int {
        let choices = allowedMonthlyPayDays
        if choices.contains(day) { return day }
        var best = choices[0]
        var bestDist = abs(best - day)
        for c in choices.dropFirst() {
            let d = abs(c - day)
            if d < bestDist || (d == bestDist && c < best) {
                best = c
                bestDist = d
            }
        }
        return best
    }

    /// Percent applied on the 1st of each month (1–30).
    var monthlyInterestPercent: Int = 5
    /// `yyyy-MM` of the last month for which interest was evaluated (set after processing on the 1st).
    var lastInterestAppliedMonthKey: String?
    /// Last time scheduled allowance was auto-credited (prevents duplicate same day/week/month).
    var lastScheduledAllowancePaymentAt: Date?

    var iconColor: Color {
        switch icon {
        case "star.fill": return .orange
        case "book.fill": return .indigo
        case "gamecontroller.fill": return .purple
        case "figure.run": return .green
        default: return .blue
        }
    }

    /// Whether `birthday`'s month and day match `reference` (e.g. today).
    static func isBirthday(birth: Date, on reference: Date, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        let ref = calendar.dateComponents([.month, .day], from: reference)
        let bd = calendar.dateComponents([.month, .day], from: birth)
        return ref.month == bd.month && ref.day == bd.day
    }

    func isBirthday(on reference: Date, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        guard let birthday else { return false }
        return Self.isBirthday(birth: birthday, on: reference, calendar: calendar)
    }

    static let sample: [FamilyKid] = [
        FamilyKid(id: UUID(), name: "Noa", birthday: Calendar.current.date(from: DateComponents(year: 2016, month: 3, day: 12)), weeklyAllowance: 25, currentBalance: 81, icon: "star.fill", customImageData: nil, depositFrequency: .weekly, depositWeekday: 2, depositMonthlyDay: 1, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 1, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil),
        FamilyKid(id: UUID(), name: "Liam", birthday: Calendar.current.date(from: DateComponents(year: 2014, month: 7, day: 22)), weeklyAllowance: 20, currentBalance: 43, icon: "gamecontroller.fill", customImageData: nil, depositFrequency: .monthly, depositWeekday: 3, depositMonthlyDay: 10, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 2, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil),
        FamilyKid(id: UUID(), name: "Maya", birthday: nil, weeklyAllowance: 15, currentBalance: 29, icon: "book.fill", customImageData: nil, depositFrequency: .weekly, depositWeekday: 4, depositMonthlyDay: 1, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 1, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil)
    ]
}

extension FamilyKid: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, birthday, weeklyAllowance, currentBalance, icon, customImageData
        case depositFrequency, depositWeekday, depositMonthlyDay, depositTime
        case monthlyInterestPercent, lastInterestAppliedMonthKey, lastScheduledAllowancePaymentAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday).map { Calendar.current.startOfDay(for: $0) }
        weeklyAllowance = try container.decode(Double.self, forKey: .weeklyAllowance)
        currentBalance = try container.decode(Double.self, forKey: .currentBalance)
        icon = try container.decode(String.self, forKey: .icon)
        customImageData = try container.decodeIfPresent(Data.self, forKey: .customImageData)
        depositFrequency = try container.decodeIfPresent(DepositFrequency.self, forKey: .depositFrequency) ?? .weekly
        depositWeekday = try container.decodeIfPresent(Int.self, forKey: .depositWeekday) ?? 2
        let rawMonthlyDay = try container.decodeIfPresent(Int.self, forKey: .depositMonthlyDay) ?? 1
        depositMonthlyDay = Self.normalizedMonthlyPayDay(rawMonthlyDay)
        depositTime = try container.decodeIfPresent(Date.self, forKey: .depositTime)
            ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        let rawPercent = try container.decodeIfPresent(Int.self, forKey: .monthlyInterestPercent) ?? 5
        monthlyInterestPercent = min(30, max(0, rawPercent))
        lastInterestAppliedMonthKey = try container.decodeIfPresent(String.self, forKey: .lastInterestAppliedMonthKey)
        lastScheduledAllowancePaymentAt = try container.decodeIfPresent(Date.self, forKey: .lastScheduledAllowancePaymentAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encode(weeklyAllowance, forKey: .weeklyAllowance)
        try container.encode(currentBalance, forKey: .currentBalance)
        try container.encode(icon, forKey: .icon)
        try container.encodeIfPresent(customImageData, forKey: .customImageData)
        try container.encode(depositFrequency, forKey: .depositFrequency)
        try container.encode(depositWeekday, forKey: .depositWeekday)
        try container.encode(depositMonthlyDay, forKey: .depositMonthlyDay)
        try container.encode(depositTime, forKey: .depositTime)
        try container.encode(monthlyInterestPercent, forKey: .monthlyInterestPercent)
        try container.encodeIfPresent(lastInterestAppliedMonthKey, forKey: .lastInterestAppliedMonthKey)
        try container.encodeIfPresent(lastScheduledAllowancePaymentAt, forKey: .lastScheduledAllowancePaymentAt)
    }
}

#Preview {
    FamilyView()
        .environmentObject(LanguageManager())
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(ActivityStore())
        .environmentObject(HistoryStore())
        .environmentObject(GoalsStore())
}

private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
