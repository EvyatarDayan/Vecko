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
                                FamilyHistoryRowView(
                                    entry: entry,
                                    kid: familyStore.kids.first(where: { $0.id == entry.kidId }),
                                    isDarkMode: isDarkMode
                                )
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
                        .foregroundStyle(selectedHistoryKidID == nil ? Color.blue : Color.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(historyKidFilters) { item in
                    Button {
                        selectedHistoryKidID = item.id
                    } label: {
                        Text(item.name)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedHistoryKidID == item.id ? Color.blue.opacity(0.18) : historyFilterChipIdleBackground)
                            .foregroundStyle(selectedHistoryKidID == item.id ? Color.blue : Color.primary)
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

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                Text(AppStringCatalog.localizedHistoryTitle(storedTitle: entry.title, language: languageManager.language))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(entry.detail)
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
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
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
