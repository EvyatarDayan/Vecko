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
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
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
            case .daily:
                if let last = kid.lastScheduledAllowancePaymentAt, calendar.isDate(last, inSameDayAs: now) {
                    continue
                }
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

            // Test-mode helper: also apply configured monthly interest immediately
            // after scheduled allowance is paid, so interest behavior is easier to verify.
            if kid.monthlyInterestPercent > 0, kid.currentBalance > 0 {
                let rawBonus = kid.currentBalance * Double(kid.monthlyInterestPercent) / 100.0
                let bonus = (rawBonus * 100).rounded() / 100
                if bonus > 0 {
                    kid.currentBalance += bonus
                    let interestNotePattern = AppStringCatalog.string(.noteMonthlyInterestFormat, language: lang)
                    let interestNote = String(format: interestNotePattern, locale: lang.locale, arguments: [kid.monthlyInterestPercent])
                    activityStore.addTransaction(
                        kidId: kid.id,
                        kidName: kid.name,
                        amount: bonus,
                        note: interestNote,
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
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var goalsStore: GoalsStore
    @State private var showingAddKid = false
    @State private var editingKid: FamilyKid?
    @State private var activeTransactionType: FamilyBulkTransactionType?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    pageHeader
                    transactionButtons

                    if kids.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(kids) { kid in
                                    FamilyKidRow(kid: kid, isDarkMode: isDarkMode)
                                        .onTapGesture {
                                            editingKid = kid
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 70)
                        }
                    }
                }
                Button {
                    showingAddKid = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 6)
                .padding(.trailing, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddKid) {
                AddEditKidView(mode: .add, onDelete: nil) { newKid in
                    familyStore.addKid(newKid)
                    historyStore.recordKidAdded(kidId: newKid.id, kidName: newKid.name)
                }
            }
            .sheet(item: $activeTransactionType) { type in
                FamilyBulkTransactionView(type: type) { amount, note, selectedKidIDs in
                    applyBulkTransaction(type: type, amount: amount, note: note, selectedKidIDs: selectedKidIDs)
                }
                .environmentObject(currencyManager)
                .environmentObject(familyStore)
            }
            .sheet(item: $editingKid) { kid in
                AddEditKidView(
                    mode: .edit(kid),
                    onDelete: { deletedID, deletedName in
                        familyStore.deleteKid(id: deletedID)
                        activityStore.removeAll(forKidId: deletedID)
                        goalsStore.removeGoals(forKidId: deletedID)
                        historyStore.recordKidRemoved(kidId: deletedID, kidName: deletedName)
                    }
                ) { updatedKid in
                    familyStore.updateKid(updatedKid)
                    historyStore.recordKidUpdated(kidId: updatedKid.id, kidName: updatedKid.name)
                }
            }
        }
    }


    private var pageHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.familyTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(languageManager.text(.familySubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
         .padding(.top, 15)
         .padding(.bottom, 6)
    }

    private var transactionButtons: some View {
        HStack(spacing: 12) {
            Button {
                activeTransactionType = .deposit
            } label: {
                Text(languageManager.text(.familyDeposit))
                    .font(.headline)
                    .foregroundColor(kids.isEmpty ? .secondary : .appGreen)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.appGreen)
            .disabled(kids.isEmpty)

            Button {
                activeTransactionType = .withdraw
            } label: {
                Text(languageManager.text(.familyWithdraw))
                    .font(.headline)
                    .foregroundColor(kids.isEmpty ? .secondary : .red)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .disabled(kids.isEmpty)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 23)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(languageManager.text(.familyNoKidsTitle))
                .font(.headline)
            Text(languageManager.text(.familyNoKidsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                showingAddKid = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.appGreen)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var totalBalance: Double {
        kids.reduce(0) { $0 + $1.currentBalance }
    }

    private var kids: [FamilyKid] {
        familyStore.kids
    }

    private func applyBulkTransaction(
        type: FamilyBulkTransactionType,
        amount: Double,
        note: String,
        selectedKidIDs: Set<UUID>
    ) {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard amount > 0, !trimmedNote.isEmpty, !selectedKidIDs.isEmpty else { return }

        let isDeposit = type == .deposit
        let lang = AppLanguage.stored
        for kid in kids where selectedKidIDs.contains(kid.id) {
            var updatedKid = kid
            updatedKid.currentBalance = isDeposit
                ? (updatedKid.currentBalance + amount)
                : (updatedKid.currentBalance - amount)
            familyStore.updateKid(updatedKid)

            activityStore.addTransaction(
                kidId: kid.id,
                kidName: kid.name,
                amount: amount,
                note: trimmedNote,
                isDeposit: isDeposit
            )
            if isDeposit {
                historyStore.recordManualDeposit(kidId: kid.id, kidName: kid.name, amount: amount, note: trimmedNote)
                // Test-mode helper: apply interest immediately after manual deposit.
                if updatedKid.monthlyInterestPercent > 0, updatedKid.currentBalance > 0 {
                    let rawBonus = updatedKid.currentBalance * Double(updatedKid.monthlyInterestPercent) / 100.0
                    let bonus = (rawBonus * 100).rounded() / 100
                    if bonus > 0 {
                        updatedKid.currentBalance += bonus
                        familyStore.updateKid(updatedKid)

                        let notePattern = AppStringCatalog.string(.noteMonthlyInterestFormat, language: lang)
                        let note = String(format: notePattern, locale: lang.locale, arguments: [updatedKid.monthlyInterestPercent])

                        activityStore.addTransaction(
                            kidId: kid.id,
                            kidName: kid.name,
                            amount: bonus,
                            note: note,
                            isDeposit: true,
                            isInterest: true
                        )
                        historyStore.recordMonthlyInterestCredited(
                            kidId: kid.id,
                            kidName: kid.name,
                            percent: updatedKid.monthlyInterestPercent,
                            amount: bonus
                        )
                    }
                }
            } else {
                historyStore.recordManualWithdraw(kidId: kid.id, kidName: kid.name, amount: amount, note: trimmedNote)
            }
        }
    }
}

private enum FamilyBulkTransactionType: String, Identifiable {
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

private struct FamilyBulkTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var familyStore: FamilyStore

    let type: FamilyBulkTransactionType
    let onConfirm: (Double, String, Set<UUID>) -> Void

    @State private var amount = ""
    @State private var note = ""
    @State private var selectedKidIDs: Set<UUID> = []
    @State private var attemptedSubmit = false
    
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

    var body: some View {
        NavigationStack {
            Form {
                Section(type.title(language: languageManager)) {
                    HStack(spacing: 8) {
                        Text(currencyManager.getCurrencySymbol())
                            .foregroundStyle(attemptedSubmit && !isAmountValid ? .red : .secondary)
                        TextField(
                            "",
                            text: $amount,
                            prompt: Text(
                                attemptedSubmit && !isAmountValid
                                ? languageManager.text(.familyBulkAmountRequired)
                                : languageManager.text(.familyBulkAmount)
                            ).foregroundColor(attemptedSubmit && !isAmountValid ? .red : .secondary)
                        )
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .onChange(of: amount) { _, newValue in
                                amount = sanitizeNumericInput(newValue)
                            }
                    }
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
            .navigationTitle(type.title(language: languageManager))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(languageManager.text(.commonCancel)) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(type.actionTitle(language: languageManager)) {
                        attemptedSubmit = true
                        guard isValid, let value = Double(amount) else { return }
                        onConfirm(value, note, selectedKidIDs)
                        dismiss()
                    }
                }
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

private struct FamilyKidRow: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let kid: FamilyKid
    let isDarkMode: Bool

    var body: some View {
        HStack(spacing: 16) {
            if let customImageData = kid.customImageData, let customImage = UIImage(data: customImageData) {
                Image(uiImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(kid.iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: kid.icon)
                        .font(.title2)
                        .foregroundColor(kid.iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(kid.name)
                    .font(.headline)
                    .lineLimit(1)
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
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currencyManager.formatAmount(kid.currentBalance))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(kid.currentBalance < 0 ? .appRed : .appGreen)
                Text(languageManager.text(.familyKidRowCurrent))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

private struct AddEditKidView: View {
    enum Mode {
        case add
        case edit(FamilyKid)
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var currencyManager: CurrencyManager

    let mode: Mode
    let onDelete: ((UUID, String) -> Void)?
    let onSave: (FamilyKid) -> Void

    @State private var name = ""
    @State private var weeklyAllowance = ""
    @State private var currentBalance = "0.00"
    @State private var selectedIcon = "person.fill"
    @State private var selectedImage: UIImage?
    @State private var showingIconPicker = false
    @State private var depositFrequency: DepositFrequency = .weekly
    @State private var selectedWeekday = 2
    @State private var selectedMonthlyDay = 1
    @State private var depositTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingDepositTimePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var monthlyInterestPercent = 1
    @State private var attemptedSave = false
    private var weekdayNames: [String] {
        [
            languageManager.text(.weekdaySun),
            languageManager.text(.weekdayMon),
            languageManager.text(.weekdayTue),
            languageManager.text(.weekdayWed),
            languageManager.text(.weekdayThu),
            languageManager.text(.weekdayFri),
            languageManager.text(.weekdaySat)
        ]
    }

    var body: some View {
        NavigationView {
            Form {
                Section(languageManager.text(.kidSectionInfo)) {
                    TextField(
                        "",
                        text: $name,
                        prompt: Text(isNameValid || !attemptedSave ? languageManager.text(.kidNamePlaceholder) : languageManager.text(.kidNameRequired))
                            .foregroundColor(isNameValid || !attemptedSave ? .secondary : .red)
                    )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(.primary)
                }

                Section(languageManager.text(.kidSectionAllowance)) {
                    HStack(spacing: 8) {
                        Text(currencyManager.getCurrencySymbol())
                            .foregroundColor(isWeeklyAllowanceValid || !attemptedSave ? .secondary : .red)
                        TextField(
                            "",
                            text: $weeklyAllowance,
                            prompt: Text(isWeeklyAllowanceValid || !attemptedSave ? languageManager.text(.kidWeeklyAllowancePlaceholder) : languageManager.text(.kidWeeklyAllowanceRequired))
                                .foregroundColor(isWeeklyAllowanceValid || !attemptedSave ? .secondary : .red)
                        )
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.primary)
                    }

                    Picker(languageManager.text(.kidDepositFrequency), selection: $depositFrequency) {
                        ForEach(DepositFrequency.allCases, id: \.self) { option in
                            Text(AppStringCatalog.displayDepositFrequency(option, language: languageManager.language)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button {
                        showingDepositTimePicker = true
                    } label: {
                        HStack {
                            Text(languageManager.text(.kidDepositTime))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(depositTimeString)
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    if depositFrequency == .weekly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(languageManager.text(.kidSelectWeekdayTitle))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(Array(weekdayNames.enumerated()), id: \.offset) { index, dayName in
                                Button {
                                    selectedWeekday = index + 1
                                } label: {
                                    HStack {
                                        Text(dayName)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: selectedWeekday == index + 1 ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedWeekday == index + 1 ? .blue : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if depositFrequency == .monthly {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(languageManager.text(.kidSelectMonthDayTitle))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Menu {
                                ForEach(1...28, id: \.self) { day in
                                    Button("\(day)") {
                                        selectedMonthlyDay = day
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(ordinalDay(selectedMonthlyDay))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }

                            Text(
                                String(
                                    format: languageManager.text(.kidSelectedMonthlyFormat),
                                    locale: languageManager.locale,
                                    arguments: [ordinalDay(selectedMonthlyDay)]
                                )
                            )
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if depositFrequency == .daily {
                        Text(languageManager.text(.kidDailyAllowanceCaption))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    Picker(languageManager.text(.kidMonthlyInterestHeader), selection: $monthlyInterestPercent) {
                        ForEach(1...30, id: \.self) { value in
                            Text("\(value)%").tag(value)
                        }
                    }
                    Text(languageManager.text(.kidMonthlyInterestExplanation))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text(languageManager.text(.kidMonthlyInterestHeader))
                }

                Section(languageManager.text(.kidSectionIcon)) {
                    HStack {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }

                        Spacer()

                        Button(languageManager.text(.kidSelectIcon)) {
                            showingIconPicker = true
                        }
                        .foregroundColor(.blue)
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
            .navigationTitle(isEditMode ? languageManager.text(.kidNavEdit) : languageManager.text(.kidNavAdd))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.text(.commonCancel)) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.text(.commonSave)) {
                        saveKid()
                    }
                }
            }
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
                depositTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            case .edit(let kid):
                name = kid.name
                weeklyAllowance = String(format: "%.2f", kid.weeklyAllowance)
                currentBalance = String(format: "%.2f", kid.currentBalance)
                selectedIcon = kid.icon
                depositFrequency = kid.depositFrequency
                selectedWeekday = kid.depositWeekday
                selectedMonthlyDay = kid.depositMonthlyDay
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
            weeklyAllowance: weeklyValue,
            currentBalance: balanceValue,
            icon: selectedIcon,
            customImageData: selectedImage?.jpegData(compressionQuality: 0.8),
            depositFrequency: depositFrequency,
            depositWeekday: selectedWeekday,
            depositMonthlyDay: selectedMonthlyDay,
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

    private func ordinalDay(_ number: Int) -> String {
        switch number {
        case 1, 21, 31: return "\(number)st"
        case 2, 22: return "\(number)nd"
        case 3, 23: return "\(number)rd"
        default: return "\(number)th"
        }
    }
}

private struct KidIconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedIcon: String
    @Binding var selectedImage: UIImage?
    @State private var selectedTab = 0
    @State private var showingImagePicker = false

    private let icons = [
        "person.fill", "star.fill", "book.fill", "gamecontroller.fill", "figure.run", "paintbrush.fill",
        "soccerball", "music.note", "trophy.fill", "heart.fill", "gift.fill", "graduationcap.fill"
    ]
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker(languageManager.text(.pickerSelection), selection: $selectedTab) {
                    Text(languageManager.text(.iconPickerIcons)).tag(0)
                    Text(languageManager.text(.iconPickerPhotos)).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    selectedImage = nil
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.12))
                                            .frame(width: 58, height: 58)
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundColor(selectedIcon == icon ? .white : .blue)
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

                        if selectedImage != nil {
                            Button(languageManager.text(.iconPickerUseImage)) {
                                selectedIcon = "person.fill"
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(languageManager.text(.iconPickerNavSelect))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.text(.commonDone)) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}

struct FamilyKid: Identifiable {
    let id: UUID
    var name: String
    var weeklyAllowance: Double
    var currentBalance: Double
    var icon: String
    var customImageData: Data?
    var depositFrequency: DepositFrequency = .weekly
    var depositWeekday: Int = 2
    var depositMonthlyDay: Int = 1
    var depositTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    /// Percent applied on the 1st of each month (1–30).
    var monthlyInterestPercent: Int = 1
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

    static let sample: [FamilyKid] = [
        FamilyKid(id: UUID(), name: "Noa", weeklyAllowance: 25, currentBalance: 81, icon: "star.fill", customImageData: nil, depositFrequency: .weekly, depositWeekday: 2, depositMonthlyDay: 1, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 1, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil),
        FamilyKid(id: UUID(), name: "Liam", weeklyAllowance: 20, currentBalance: 43, icon: "gamecontroller.fill", customImageData: nil, depositFrequency: .monthly, depositWeekday: 3, depositMonthlyDay: 7, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 2, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil),
        FamilyKid(id: UUID(), name: "Maya", weeklyAllowance: 15, currentBalance: 29, icon: "book.fill", customImageData: nil, depositFrequency: .daily, depositWeekday: 4, depositMonthlyDay: 1, depositTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(), monthlyInterestPercent: 1, lastInterestAppliedMonthKey: nil, lastScheduledAllowancePaymentAt: nil)
    ]
}

extension FamilyKid: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, weeklyAllowance, currentBalance, icon, customImageData
        case depositFrequency, depositWeekday, depositMonthlyDay, depositTime
        case monthlyInterestPercent, lastInterestAppliedMonthKey, lastScheduledAllowancePaymentAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        weeklyAllowance = try container.decode(Double.self, forKey: .weeklyAllowance)
        currentBalance = try container.decode(Double.self, forKey: .currentBalance)
        icon = try container.decode(String.self, forKey: .icon)
        customImageData = try container.decodeIfPresent(Data.self, forKey: .customImageData)
        depositFrequency = try container.decodeIfPresent(DepositFrequency.self, forKey: .depositFrequency) ?? .weekly
        depositWeekday = try container.decodeIfPresent(Int.self, forKey: .depositWeekday) ?? 2
        depositMonthlyDay = try container.decodeIfPresent(Int.self, forKey: .depositMonthlyDay) ?? 1
        depositTime = try container.decodeIfPresent(Date.self, forKey: .depositTime)
            ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        let rawPercent = try container.decodeIfPresent(Int.self, forKey: .monthlyInterestPercent) ?? 1
        monthlyInterestPercent = min(30, max(1, rawPercent))
        lastInterestAppliedMonthKey = try container.decodeIfPresent(String.self, forKey: .lastInterestAppliedMonthKey)
        lastScheduledAllowancePaymentAt = try container.decodeIfPresent(Date.self, forKey: .lastScheduledAllowancePaymentAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
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
