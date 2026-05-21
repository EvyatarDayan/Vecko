//
//  HomeView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-25.
//

import SwiftUI
import UIKit

@MainActor
struct HomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var goalsStore: GoalsStore

    @AppStorage("home.selectedKidID") private var selectedKidIDRaw: String = ""
    @State private var cardFlipAngle: Double = 0
    @State private var showingAddKid = false
    @State private var editingKid: FamilyKid?
    @State private var activeTransactionType: FamilyBulkTransactionType?

    private var kids: [KidAllowance] {
        familyStore.kids.map(KidAllowance.init(from:))
    }

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var selectedKid: KidAllowance? {
        if let selectedKidID, let matchedKid = kids.first(where: { $0.id == selectedKidID }) {
            return matchedKid
        }
        return kids.first
    }

    private var selectedKidID: UUID? {
        UUID(uuidString: selectedKidIDRaw)
    }

    /// Selected card’s `FamilyKid` for editing (same logic as list / card selection).
    private var focusedFamilyKid: FamilyKid? {
        guard let id = selectedKid?.id else { return nil }
        return familyStore.kids.first(where: { $0.id == id })
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        headerSection
                        summaryCard
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))

                    if kids.isEmpty {
                        emptyStateView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemGroupedBackground))
                    } else {
                        kidsListSection
                            .background(Color(.systemGroupedBackground))
                    }
                }

                HStack(alignment: .center) {
                    Button {
                        if let kid = focusedFamilyKid {
                            editingKid = kid
                        }
                    } label: {
                        Text(languageManager.text(.homeNavEdit))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.appGreen)
                    }
                    .veckoToolbarActionStyle()
                    .disabled(focusedFamilyKid == nil)

                    Spacer(minLength: 0)

                    Button {
                        showingAddKid = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.appGreen)
                    }
                    .veckoToolbarActionStyle()
                }
                .padding(.top, 6)
                .padding(.horizontal, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddKid) {
                AddEditKidView(mode: .add, onDelete: nil) { newKid in
                    familyStore.addKid(newKid)
                    historyStore.recordKidAdded(kidId: newKid.id, kidName: newKid.name)
                }
            }
            .sheet(item: $editingKid) { kid in
                AddEditKidView(
                    mode: .edit(kid),
                    onDelete: { deletedID, deletedName in
                        familyStore.deleteKid(id: deletedID)
                        activityStore.removeAll(forKidId: deletedID)
                        goalsStore.removeGoals(forKidId: deletedID)
                        historyStore.recordKidRemoved(kidId: deletedID, kidName: deletedName)
                        if selectedKidID == deletedID {
                            persistSelectedKidID(familyStore.kids.first?.id)
                        }
                    }
                ) { updatedKid in
                    familyStore.updateKid(updatedKid)
                    let changes = KidProfileUpdateSummary.changeLines(
                        from: kid,
                        to: updatedKid,
                        language: languageManager.language
                    )
                    if !changes.isEmpty {
                        historyStore.recordKidUpdated(
                            kidId: updatedKid.id,
                            kidName: updatedKid.name,
                            changeLines: changes
                        )
                    }
                }
            }
            .sheet(item: $activeTransactionType) { type in
                FamilyBulkTransactionView(
                    type: type,
                    initialSelectedKidIDs: selectedKid.map { Set([$0.id]) },
                    onConfirm: { amount, note, kidIDs in
                        applyBulkTransaction(type: type, amount: amount, note: note, selectedKidIDs: kidIDs)
                    }
                )
                .environmentObject(currencyManager)
                .environmentObject(familyStore)
            }
        }
        .onAppear {
            syncSelectionIfNeeded()
            cardFlipAngle = 0
        }
        .onChange(of: familyStore.kids.map(\.id)) { _, _ in
            syncSelectionIfNeeded()
        }
    }

    private func syncSelectionIfNeeded() {
        let ids = Set(kids.map(\.id))
        if let selectedKidID, ids.contains(selectedKidID) {
            return
        }
        persistSelectedKidID(kids.first?.id)
    }

    private func persistSelectedKidID(_ id: UUID?) {
        selectedKidIDRaw = id?.uuidString ?? ""
    }

    private func triggerCardEntranceAnimation() {
        cardFlipAngle = -120
        withAnimation(.easeInOut(duration: 0.35)) {
            cardFlipAngle = 0
        }
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
        for kid in familyStore.kids where selectedKidIDs.contains(kid.id) {
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
            } else {
                historyStore.recordManualWithdraw(kidId: kid.id, kidName: kid.name, amount: amount, note: trimmedNote)
            }
        }
    }

    private var headerSection: some View {
        Text(languageManager.text(.homeFamilyOverview))
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(selectedKid?.name ?? languageManager.text(.homeNoKidSelected))
                        .font(.system(size: isIPad ? 12 : 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))

                    Text(languageManager.text(.homeAllowanceCard))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.bottom, 10)
                }

                Spacer()

                Image("wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }

            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 2) {
                    Text(balanceTitle)
                        .font(.system(size: isIPad ? 22 : 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))

                    Text(currencyManager.formatAmount(selectedKid?.currentBalance ?? 0))
                        .font(.system(size: isIPad ? 42 : 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 10)

            Text("**** **** **** \(selectedKid?.cardLast4 ?? "0000")")
                .font(.system(size: isIPad ? 16 : 12, weight: .medium, design: .monospaced))
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 6)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(allowanceFrequencyTitle)
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))

                    Text(currencyManager.formatAmount(selectedKid?.weeklyAllowance ?? 0))
                        .font(.system(size: isIPad ? 12 : 10, weight: .semibold))
                        .foregroundColor(.black)
                }

                Spacer()

                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: -5)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(languageManager.text(.homeCardBrand))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black)
                        .offset(x: -2)
                }
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, isIPad ? 20 : 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.6, blue: 0.2),
                    Color(red: 0.9, green: 0.7, blue: 0.3),
                    Color(red: 0.7, green: 0.5, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: VeckoCreditCardChrome.cornerRadius, style: .continuous))
        .shadow(color: VeckoCreditCardChrome.shadowColor, radius: VeckoCreditCardChrome.shadowRadius, x: VeckoCreditCardChrome.shadowX, y: VeckoCreditCardChrome.shadowY)
        .overlay(
            RoundedRectangle(cornerRadius: VeckoCreditCardChrome.cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(alignment: .top) {
            cardPhotoOverlay
                .allowsHitTesting(false)
        }
        .frame(maxWidth: isIPad ? VeckoCreditCardChrome.ipadMaxWidth : .infinity)
        .rotation3DEffect(
            .degrees(cardFlipAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.7
        )
        .opacity(abs(cardFlipAngle) > 80 ? 0 : 1)
        .scaleEffect(0.8)
    }

    @ViewBuilder
    private var cardPhotoOverlay: some View {
        if let kid = selectedKid {
            if let data = kid.customImageData, let uiImage = UIImage(data: data) {
                cardWatermark {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            } else if UIImage(named: kid.icon) != nil {
                cardWatermark {
                    Image(kid.icon)
                        .resizable()
                        .scaledToFill()
                }
            } else {
                cardWatermark {
                    Image(systemName: kid.icon)
                        .font(.system(size: 100, weight: .regular))
                        .foregroundStyle(.primary.opacity(0.07))
                }
            }
        }
    }

    private func cardWatermark<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
                .frame(width: isIPad ? 180 : 180, height: isIPad ? 180 : 180)
                .clipShape(Circle())
                .opacity(0.1)
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity)
    }

    private var kidsListSection: some View {
        VStack(spacing: 0) {
            homeTransactionButtons
                .background(Color(.systemGroupedBackground))

            ScrollView {
                TimelineView(.periodic(from: Date(), by: 60)) { context in
                    LazyVStack(spacing: 12) {
                        ForEach(kids) { kid in
                            KidAllowanceRowView(
                                kid: kid,
                                isSelected: selectedKidID == kid.id,
                                referenceNow: context.date
                            )
                            .onTapGesture {
                                guard selectedKidID != kid.id else { return }
                                persistSelectedKidID(kid.id)
                                triggerCardEntranceAnimation()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 70)
                }
            }
        }
    }

    private var homeTransactionButtonForeground: Color {
        guard !kids.isEmpty else { return .secondary }
        return colorScheme == .dark ? .white : .primary
    }

    private var homeTransactionButtons: some View {
        HStack(spacing: 12) {
            Button {
                activeTransactionType = .deposit
            } label: {
                HStack(spacing: 6) {
                    Image("Deposit")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text(languageManager.text(.familyDeposit))
                        .font(.headline)
                }
                .foregroundStyle(homeTransactionButtonForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.primary.opacity(0.22), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(kids.isEmpty)

            Button {
                activeTransactionType = .withdraw
            } label: {
                HStack(spacing: 6) {
                    Image("Withdraw")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    Text(languageManager.text(.familyWithdraw))
                        .font(.headline)
                }
                .foregroundStyle(homeTransactionButtonForeground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.primary.opacity(0.22), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(kids.isEmpty)
        }
        .padding(.horizontal)
        .padding(.top, 1)
        .padding(.bottom, 35)
        .scaleEffect(0.9)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text(languageManager.text(.homeNoKidsTitle))
                .font(.headline)
            Text(languageManager.text(.homeNoKidsSubtitleFamily))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var balanceTitle: String {
        if let name = selectedKid?.name, !name.isEmpty {
            return String(format: languageManager.text(.homeBalanceNamedFormat), locale: languageManager.locale, arguments: [name])
        }
        return languageManager.text(.homeCurrentBalance)
    }

}

private struct KidAllowance: Identifiable {
    let id: UUID
    let name: String
    let weeklyAllowance: Double
    let depositFrequency: DepositFrequency
    let currentBalance: Double
    let icon: String
    let cardLast4: String
    let customImageData: Data?
    let birthday: Date?

    init(from kid: FamilyKid) {
        self.id = kid.id
        self.name = kid.name
        self.weeklyAllowance = kid.weeklyAllowance
        self.depositFrequency = kid.depositFrequency
        self.currentBalance = kid.currentBalance
        self.icon = kid.icon
        self.cardLast4 = KidAllowance.last4Digits(from: kid.id)
        self.customImageData = kid.customImageData
        self.birthday = kid.birthday
    }

    private static func last4Digits(from id: UUID) -> String {
        let digits = id.uuidString.filter(\.isNumber)
        if digits.count >= 4 {
            return String(digits.suffix(4))
        }
        return "0000"
    }
}

private struct KidAllowanceRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let kid: KidAllowance
    let isSelected: Bool
    var referenceNow: Date = Date()

    private var isBirthdayToday: Bool {
        guard let birthday = kid.birthday else { return false }
        return FamilyKid.isBirthday(birth: birthday, on: referenceNow)
    }

    var body: some View {
        HStack(spacing: 16) {
            KidStoredIconView(
                iconName: kid.icon,
                customImageData: kid.customImageData,
                size: 50,
                symbolAccentColor: iconColor
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(kid.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    if isBirthdayToday {
                        Text("🎁")
                            .font(.title3)
                            .accessibilityLabel(languageManager.text(.kidBirthdayToday))
                    }
                }

                Text(
                    String(
                        format: languageManager.text(
                            kid.depositFrequency == .monthly
                                ? .homeKidAllowancePerMonthLineFormat
                                : .homeKidAllowancePerWeekLineFormat
                        ),
                        locale: languageManager.locale,
                        arguments: [currencyManager.formatAmount(kid.weeklyAllowance)]
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
        .background(
            isSelected
            ? Color.appGreen.opacity(colorScheme == .dark ? 0.2 : 0.1)
            : (colorScheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected
                    ? Color.appGreen.opacity(0.6)
                    : (colorScheme == .dark ? Color(.systemGray4) : Color.clear),
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    private var iconColor: Color {
        switch kid.name.lowercased() {
        case "noa":
            return .pink
        case "liam":
            return .blue
        case "maya":
            return .purple
        case "daniel":
            return .green
        default:
            return .gray
        }
    }
}

private extension HomeView {
    var allowanceFrequencyTitle: String {
        let frequency = selectedKid?.depositFrequency ?? .weekly
        return AppStringCatalog.displayDepositFrequency(frequency, language: languageManager.language)
    }
}

#Preview {
    HomeView()
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(ActivityStore())
        .environmentObject(HistoryStore())
        .environmentObject(GoalsStore())
        .environmentObject(LanguageManager())
}
