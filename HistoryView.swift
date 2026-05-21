//
//  HistoryView.swift
//  Vecko
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var historyStore: HistoryStore

    @State private var selectedHistoryKidID: UUID?
    @State private var selectedHistoryEntry: FamilyHistoryEntry?

    private var historyKidFilters: [HistoryKidFilter] {
        var seen: Set<UUID> = []
        var items: [HistoryKidFilter] = []

        for kid in familyStore.kids {
            guard !seen.contains(kid.id) else { continue }
            seen.insert(kid.id)
            items.append(HistoryKidFilter(id: kid.id, name: kid.name))
        }

        for entry in historyStore.entries {
            guard let kidId = entry.kidId, let kidName = entry.kidName else { continue }
            guard !seen.contains(kidId) else { continue }
            seen.insert(kidId)
            items.append(HistoryKidFilter(id: kidId, name: kidName))
        }

        return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var filteredHistoryEntries: [FamilyHistoryEntry] {
        guard let selectedHistoryKidID else { return historyStore.entries }
        return historyStore.entries.filter { $0.kidId == selectedHistoryKidID }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageHeader
                historyContent
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedHistoryEntry) { entry in
                HistoryEntryDetailSheet(
                    entry: entry,
                    kid: familyStore.kids.first(where: { $0.id == entry.kidId })
                )
                .environmentObject(languageManager)
            }
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.familyTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(languageManager.text(.historySubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private var historyContent: some View {
        if historyStore.entries.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text(languageManager.text(.historyEmptyTitle))
                    .font(.headline)
                Text(languageManager.text(.historyEmptySubtitle))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        } else {
            VStack(spacing: 8) {
                historyKidFilterBar

                if filteredHistoryEntries.isEmpty {
                    VStack(spacing: 10) {
                        Spacer()
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text(languageManager.text(.historyFilteredEmptyTitle))
                            .font(.headline)
                        Text(languageManager.text(.historyFilteredEmptySubtitle))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredHistoryEntries) { entry in
                                Button {
                                    selectedHistoryEntry = entry
                                } label: {
                                    FamilyHistoryRowView(
                                        entry: entry,
                                        kid: familyStore.kids.first(where: { $0.id == entry.kidId }),
                                        isDarkMode: isDarkMode
                                    )
                                }
                                .buttonStyle(.plain)
                                .environmentObject(languageManager)
                            }
                        }
                        .padding()
                        .padding(.bottom, 70)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var historyFilterChipIdleBackground: Color {
        if colorScheme == .light {
            Color(UIColor.systemGray5)
        } else {
            Color(UIColor.secondarySystemBackground)
        }
    }

    private func kid(for filterID: UUID) -> FamilyKid? {
        familyStore.kids.first(where: { $0.id == filterID })
    }

    private var historyKidFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    selectedHistoryKidID = nil
                } label: {
                    Text(languageManager.text(.goalsAll))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedHistoryKidID == nil ? Color.blue.opacity(0.18) : historyFilterChipIdleBackground)
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(historyKidFilters) { item in
                    Button {
                        selectedHistoryKidID = item.id
                    } label: {
                        HStack(spacing: 5) {
                            if let kid = kid(for: item.id) {
                                KidStoredIconView(
                                    iconName: kid.icon,
                                    customImageData: kid.customImageData,
                                    size: 18,
                                    symbolAccentColor: kid.iconColor
                                )
                            }
                            Text(item.name)
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedHistoryKidID == item.id ? Color.blue.opacity(0.18) : historyFilterChipIdleBackground)
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
    }
}

private struct HistoryKidFilter: Identifiable {
    let id: UUID
    let name: String
}

private struct HistoryEntryDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    let entry: FamilyHistoryEntry
    let kid: FamilyKid?

    private var localizedTitle: String {
        AppStringCatalog.localizedHistoryDetailTitle(storedTitle: entry.title, language: languageManager.language)
    }

    private var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    private var isAllowancePaidEntry: Bool {
        switch entry.title {
        case FamilyHistoryEvent.scheduledAllowancePaid.title, "Allowance paid", "Weekly allowance paid":
            return true
        default:
            return false
        }
    }

    private var isInterestCreditedEntry: Bool {
        entry.title == FamilyHistoryEvent.monthlyInterestCredited.title || entry.title == "Interest credited"
    }

    private var interestCreditedDetailText: String {
        AppStringCatalog.localizedInterestCreditedDetail(
            storedDetail: entry.displayDetail,
            language: languageManager.language
        )
    }

    private var isNewGoalEntry: Bool {
        switch entry.title {
        case FamilyHistoryEvent.goalAdded.title, "Goal added", "New goal":
            return true
        default:
            return false
        }
    }

    private var isDepositOrWithdrawEntry: Bool {
        switch entry.title {
        case FamilyHistoryEvent.manualDeposit.title, "Deposit",
             FamilyHistoryEvent.manualWithdraw.title, "Withdrawal":
            return true
        default:
            return false
        }
    }

    private var newGoalDetailParts: (name: String, price: String)? {
        guard isNewGoalEntry else { return nil }
        let text = entry.displayDetail
        guard let separator = text.range(of: " · ") else { return nil }
        let name = String(text[..<separator.lowerBound])
        let price = String(text[separator.upperBound...])
        guard !name.isEmpty, !price.isEmpty else { return nil }
        return (name, price)
    }

    private var isKidUpdatedEntry: Bool {
        entry.title == FamilyHistoryEvent.kidUpdated.title || entry.title == "Kid updated"
    }

    private var isBirthdayEntry: Bool {
        entry.title == FamilyHistoryEvent.kidBirthday.title || entry.title == "Birthday"
    }

    private var birthdayDetailText: String {
        let name = entry.kidName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? entry.kidName!
            : entry.displayDetail
        return AppStringCatalog.localizedKidBirthdayHistoryDetail(
            kidName: name,
            language: languageManager.language
        )
    }

    private var kidUpdateChangeLines: [String] {
        guard isKidUpdatedEntry else { return [] }
        return entry.displayDetail
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var depositWithdrawDetailParts: (amount: String, note: String?)? {
        guard isDepositOrWithdrawEntry else { return nil }
        let text = entry.displayDetail
        guard !text.isEmpty else { return nil }
        if let separator = text.range(of: " · ") {
            let amount = String(text[..<separator.lowerBound])
            let note = String(text[separator.upperBound...])
            guard !amount.isEmpty else { return nil }
            return (amount, note.isEmpty ? nil : note)
        }
        return (text, nil)
    }

    private var emphasisDetailFont: Font { .title2.weight(.bold) }

    @ViewBuilder
    private var detailContent: some View {
        if let parts = newGoalDetailParts {
            VStack(spacing: 8) {
                Text(parts.name)
                    .font(emphasisDetailFont)
                    .multilineTextAlignment(.center)
                Text(parts.price)
                    .font(emphasisDetailFont)
                    .multilineTextAlignment(.center)
            }
        } else if !kidUpdateChangeLines.isEmpty {
            VStack(spacing: 8) {
                ForEach(kidUpdateChangeLines, id: \.self) { line in
                    Text(line)
                        .font(emphasisDetailFont)
                        .multilineTextAlignment(.center)
                }
            }
        } else if let parts = depositWithdrawDetailParts {
            VStack(spacing: 8) {
                Text(parts.amount)
                    .font(emphasisDetailFont)
                    .multilineTextAlignment(.center)
                if let note = parts.note {
                    Text(note)
                        .font(emphasisDetailFont)
                        .multilineTextAlignment(.center)
                }
            }
        } else if isAllowancePaidEntry {
            Text(entry.displayDetail)
                .font(emphasisDetailFont)
                .multilineTextAlignment(.center)
        } else if isInterestCreditedEntry {
            Text(interestCreditedDetailText)
                .font(emphasisDetailFont)
                .multilineTextAlignment(.center)
        } else if isBirthdayEntry {
            Text(birthdayDetailText)
                .font(emphasisDetailFont)
                .multilineTextAlignment(.center)
        } else {
            Text(entry.displayDetail)
                .font(.body)
                .multilineTextAlignment(.center)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 14) {
                    Text(localizedTitle)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)

                    Rectangle()
                        .fill(Color.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)

                    if let kidName = entry.kidName, !kidName.isEmpty {
                        HStack(spacing: 12) {
                            if let kid {
                                KidStoredIconView(
                                    iconName: kid.icon,
                                    customImageData: kid.customImageData,
                                    size: 60,
                                    symbolAccentColor: kid.iconColor
                                )
                            }
                            Text(kidName)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    detailContent
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(formattedDateTime)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Button {
                dismiss()
            } label: {
                Text(languageManager.text(.historyGotIt))
            }
            .veckoPillActionStyle(foreground: .black)
        }
        .padding(.horizontal, 28)
        .padding(.top, 43)
        .padding(.bottom, 10)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
    }
}

private struct FamilyHistoryRowView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let entry: FamilyHistoryEntry
    let kid: FamilyKid?
    let isDarkMode: Bool

    private var fallbackInitial: String {
        let source = (entry.kidName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            ? entry.kidName!
            : entry.detail
        return String(source.prefix(1)).uppercased()
    }

    private var historyRowDetail: String {
        if entry.title == FamilyHistoryEvent.kidBirthday.title || entry.title == "Birthday" {
            let name = entry.kidName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? entry.kidName!
                : entry.displayDetail
            return AppStringCatalog.localizedKidBirthdayHistoryDetail(
                kidName: name,
                language: languageManager.language
            )
        }
        return entry.displayDetail
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                Text(AppStringCatalog.localizedHistoryTitle(storedTitle: entry.title, language: languageManager.language))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(historyRowDetail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formattedTime(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let data = kid?.customImageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else if let kid {
            KidStoredIconView(
                iconName: kid.icon,
                customImageData: kid.customImageData,
                size: 50,
                symbolAccentColor: kid.iconColor
            )
        } else {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(fallbackInitial)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
        .environmentObject(LanguageManager())
        .environmentObject(FamilyStore())
        .environmentObject(HistoryStore())
}
