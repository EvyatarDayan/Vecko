//
//  InsightsView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-25.
//

import SwiftUI

private enum InsightsMainTab: String, CaseIterable {
    case insights
    case history

    func title(using language: LanguageManager) -> String {
        switch self {
        case .insights: return language.text(.insightsTabInsights)
        case .history: return language.text(.insightsTabHistory)
        }
    }
}

private enum ActivityCategory {
    case interest
    case deposit
    case withdraw

    func localizedTitle(language: AppLanguage) -> String {
        switch self {
        case .interest: return AppStringCatalog.string(.categoryInterest, language: language)
        case .deposit: return AppStringCatalog.string(.categoryDeposit, language: language)
        case .withdraw: return AppStringCatalog.string(.categoryWithdraw, language: language)
        }
    }
}

struct InsightsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var goalsStore: GoalsStore

    @State private var mainTab: InsightsMainTab = .insights
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var slideDirection: SlideDirection = .none
    @State private var selectedHistoryKidID: UUID?
    private var historyKidFilters: [HistoryKidFilter] {
        var seen: Set<UUID> = []
        var items: [HistoryKidFilter] = []

        // Always include current kids, even if older history rows lack kid metadata.
        for kid in familyStore.kids {
            guard !seen.contains(kid.id) else { continue }
            seen.insert(kid.id)
            items.append(HistoryKidFilter(id: kid.id, name: kid.name))
        }

        // Also include kids that might be removed from family but still exist in history.
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


    private var events: [AllowanceEvent] {
        activityStore.transactions(forKids: familyStore.kids).map { transaction in
            let displayName = familyStore.kids.first(where: { $0.id == transaction.kidId })?.name ?? transaction.kidName
            let category: ActivityCategory
            let icon: String
            if transaction.isInterest {
                category = .interest
                icon = "percent"
            } else if transaction.isDeposit {
                category = .deposit
                icon = "arrow.down.circle.fill"
            } else {
                category = .withdraw
                icon = "arrow.up.circle.fill"
            }
            return AllowanceEvent(
                id: transaction.id,
                kidId: transaction.kidId,
                kidName: displayName,
                category: category,
                amount: transaction.amount,
                date: transaction.date,
                icon: icon
            )
        }
    }

    /// Activity rows limited to the month shown in the calendar / overview.
    private var eventsInVisibleMonth: [AllowanceEvent] {
        events.filter { calendar.isDate($0.date, equalTo: currentDate, toGranularity: .month) }
    }

    private var monthDepositsTotal: Double {
        eventsInVisibleMonth.filter { $0.category == .deposit }.reduce(0) { $0 + $1.amount }
    }

    private var monthWithdrawalsTotal: Double {
        eventsInVisibleMonth.filter { $0.category == .withdraw }.reduce(0) { $0 + $1.amount }
    }

    private var monthNetFlow: Double {
        monthDepositsTotal - monthWithdrawalsTotal
    }

    private var monthInterestByKid: [(kidId: UUID, name: String, amount: Double, monthlyRate: Int)] {
        let interestRows = events.filter { $0.category == .interest }
        var totals: [UUID: Double] = [:]
        for event in interestRows {
            totals[event.kidId, default: 0] += event.amount
        }
        return familyStore.kids
            .map { kid in
                (kidId: kid.id, name: kid.name, amount: totals[kid.id, default: 0], monthlyRate: kid.monthlyInterestPercent)
            }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.amount > rhs.amount
            }
    }
    private let categoryPalette: [Color] = [
        Color(red: 38/255, green: 70/255, blue: 83/255),
        Color(red: 42/255, green: 157/255, blue: 143/255),
        Color(red: 233/255, green: 196/255, blue: 106/255),
        Color(red: 244/255, green: 162/255, blue: 97/255),
        Color(red: 231/255, green: 111/255, blue: 81/255)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageHeader
                Picker("", selection: $mainTab) {
                    ForEach(InsightsMainTab.allCases, id: \.self) { tab in
                        Text(tab.title(using: languageManager)).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))

                if mainTab == .insights {
                    ScrollView {
                        VStack(spacing: 20) {
                            breakdownCard
                            interestByKidCard
                            goalsByKidCard
                            calendarCard
                        }
                        .padding()
                        .padding(.bottom, 70)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    historyTabContent
                }
            }
            .background(Color(.systemGroupedBackground))
                        .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }


    private var pageHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.insightsTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(languageManager.text(.insightsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    private var historyTabContent: some View {
        Group {
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
    }

    private var historyKidFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedHistoryKidID = nil
                } label: {
                    Text(languageManager.text(.insightsAll))
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(selectedHistoryKidID == nil ? Color.blue.opacity(0.18) : Color(.secondarySystemBackground))
                        .foregroundStyle(selectedHistoryKidID == nil ? Color.blue : Color.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(historyKidFilters) { item in
                    Button {
                        selectedHistoryKidID = item.id
                    } label: {
                        Text(item.name)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedHistoryKidID == item.id ? Color.blue.opacity(0.18) : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedHistoryKidID == item.id ? Color.blue : Color.primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private var interestByKidCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(languageManager.text(.insightsInterestByKidTitle))
                .font(.title2)
                .fontWeight(.semibold)

            if familyStore.kids.isEmpty {
                Text(languageManager.text(.insightsNoInterestThisMonth))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(monthInterestByKid.enumerated()), id: \.element.kidId) { index, row in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(row.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(currencyManager.formatAmount(row.amount))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appGreen)
                            }
                            Text(
                                String(
                                    format: languageManager.text(.insightsKidMonthlyRateFormat),
                                    locale: languageManager.locale,
                                    arguments: [row.name, row.monthlyRate]
                                )
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            if index < monthInterestByKid.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var goalsByKidCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(languageManager.text(.insightsGoalsByKidTitle))
                .font(.title2)
                .fontWeight(.semibold)

            if familyStore.kids.isEmpty {
                Text(languageManager.text(.insightsNoActivityYet))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    if !goalCompletionRows.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(goalCompletionRows.enumerated()), id: \.element.kidId) { index, item in
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        GoalRadialProgressView(
                                            percent: item.completionPercent,
                                            color: item.color,
                                            lineWidth: 7
                                        )
                                        .frame(width: 48, height: 48)

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Circle()
                                                    .fill(item.color)
                                                    .frame(width: 10, height: 10)
                                                Text(item.name)
                                                    .font(.subheadline)
                                                Text("\(item.completionPercent)%")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Text(
                                                item.goalsCount == 0
                                                ? String(
                                                    format: languageManager.text(.insightsKidHasNoGoalsFormat),
                                                    locale: languageManager.locale,
                                                    arguments: [item.name]
                                                )
                                                : String(
                                                    format: languageManager.text(.insightsGoalsCountFormat),
                                                    locale: languageManager.locale,
                                                    arguments: [item.goalsCount]
                                                )
                                            )
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }

                                    if index < goalCompletionRows.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                    } else {
                        Text(languageManager.text(.insightsNoGoalsForKid))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(languageManager.text(.insightsKidsBreakdown))
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    DonutChartView(slices: pieSlices, lineWidth: 45)
                    VStack(spacing: 4) {
                        Text(languageManager.text(.insightsTotal))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(currencyManager.formatAmount(totalKidsBalance))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appGreen)
                    }
                }
                .padding(.top, 25)
                .padding(.bottom, 25)
                .frame(width: 270, height: 270)
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(kidBalanceColored, id: \.kidId) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            Text(item.name)
                                .font(.subheadline)
                            Spacer()
                            Text("\(percentage(of: item.amount), specifier: "%.0f")%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(currencyManager.formatAmount(item.amount))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(languageManager.text(.insightsMonthlyCalendar))
                .font(.title2)
                .fontWeight(.semibold)

            HStack {
                Button(action: {
                    slideDirection = .right
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.appGreen)
                }

                Spacer()
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appGreen)
                Spacer()

                Button(action: {
                    slideDirection = .left
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.appGreen)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(height: 30)
                }

                ForEach(calendarDays, id: \.self) { date in
                    if let date {
                        Button {
                            selectedDate = date
                        } label: {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(isToday(date) ? .white : .primary)

                                if !eventsForDate(date).isEmpty {
                                    let dotCount = min(2, eventsForDate(date).count)
                                    HStack(spacing: 2) {
                                        ForEach(Array(eventsForDate(date).prefix(dotCount)), id: \.id) { event in
                                            Circle()
                                                .fill(categoryColor(for: event.category))
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                }
                            }
                            .frame(width: 40, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedDate == date ? Color(.systemGray5) : (isToday(date) ? Color.appGreen : Color.clear))
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(width: 40, height: 44)
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: slideDirection == .left ? .trailing : .leading),
                removal: .move(edge: slideDirection == .left ? .leading : .trailing)
            ))
            .id(currentDate)

            if let selectedDate {
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(
                            String(
                                format: languageManager.text(.insightsActivityOnFormat),
                                locale: languageManager.locale,
                                arguments: [selectedDateString(selectedDate)]
                            )
                        )
                            .font(.headline)
                            .fontWeight(.medium)
                    }

                    if eventsForDate(selectedDate).isEmpty {
                        Text(languageManager.text(.insightsNoActivityDay))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(spacing: 8) {
                                ForEach(eventsForDate(selectedDate)) { event in
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(categoryColor(for: event.category).opacity(0.15))
                                                .frame(width: 30, height: 30)
                                            Image(systemName: event.icon)
                                                .font(.caption)
                                                .foregroundColor(categoryColor(for: event.category))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.kidName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(event.category.localizedTitle(language: languageManager.language))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Text(signedAmountText(for: event))
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func metricBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var categorySpending: [(category: ActivityCategory, amount: Double)] {
        var totals: [ActivityCategory: Double] = [:]
        for event in eventsInVisibleMonth {
            totals[event.category, default: 0] += event.amount
        }
        return totals.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    private var kidBalanceRows: [(kidId: UUID, name: String, amount: Double)] {
        familyStore.kids
            .map { (kidId: $0.id, name: $0.name, amount: $0.currentBalance) }
            .sorted { $0.amount > $1.amount }
    }

    private var kidBalanceColored: [(kidId: UUID, name: String, amount: Double, color: Color)] {
        kidBalanceRows.enumerated().map { index, item in
            (kidId: item.kidId, name: item.name, amount: item.amount, color: categoryPalette[index % categoryPalette.count])
        }
    }

    private var goalCompletionRows: [(kidId: UUID, name: String, completionPercent: Int, goalsCount: Int, color: Color)] {
        familyStore.kids
            .enumerated()
            .map { index, kid in
                let goals = goalsStore.goals(for: kid.id)
                let balance = max(0, kid.currentBalance)
                let completion: Int = {
                    guard !goals.isEmpty else { return 0 }
                    let averageCompletion = goals.reduce(0.0) { partial, goal in
                        guard goal.targetAmount > 0 else { return partial }
                        return partial + min(1.0, balance / goal.targetAmount)
                    } / Double(goals.count)
                    return Int((averageCompletion * 100).rounded())
                }()
                return (
                    kidId: kid.id,
                    name: kid.name,
                    completionPercent: completion,
                    goalsCount: goals.count,
                    color: categoryPalette[index % categoryPalette.count]
                )
            }
            .sorted { $0.completionPercent > $1.completionPercent }
    }

    private var pieSlices: [PieSliceData] {
        kidBalanceColored.map { item in
            PieSliceData(value: item.amount, color: item.color)
        }
    }

    private var totalKidsBalance: Double {
        kidBalanceRows.reduce(0) { $0 + $1.amount }
    }

    private var totalSpentThisMonth: Double {
        eventsInVisibleMonth.reduce(0) { $0 + $1.amount }
    }

    private var totalInterestThisMonth: Double {
        eventsInVisibleMonth.filter { $0.category == .interest }.reduce(0) { $0 + $1.amount }
    }

    private var activeKidsCount: Int {
        familyStore.kids.count
    }

    private var depositCount: Int {
        eventsInVisibleMonth.filter { $0.category == .deposit }.count
    }

    private var withdrawCount: Int {
        eventsInVisibleMonth.filter { $0.category == .withdraw }.count
    }

    private var topCategoryText: String {
        guard let top = categorySpending.first else { return languageManager.text(.insightsNoActivityYet) }
        let label = top.category.localizedTitle(language: languageManager.language)
        return "\(label) • \(currencyManager.formatAmount(top.amount))"
    }

    private func percentage(of amount: Double) -> Double {
        let total = max(totalKidsBalance, 0.000001)
        return (amount / total) * 100
    }

    private func categoryColor(for category: ActivityCategory) -> Color {
        if let index = categorySpending.firstIndex(where: { $0.category == category }) {
            return categoryPalette[index % categoryPalette.count]
        }
        return .gray
    }

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = languageManager.locale
        return cal
    }
    private var daysInWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        let symbols = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        let start = calendar.firstWeekday
        return (0..<7).map { offset in
            let weekday = ((start - 1 + offset) % 7) + 1
            let index = (weekday - 1) % symbols.count
            return symbols[index]
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - 1

        let startDate = calendar.date(byAdding: .day, value: -Int(offsetDays), to: startOfMonth) ?? startOfMonth
        let endDate = calendar.date(byAdding: .day, value: 41, to: startDate) ?? startDate

        var dates: [Date?] = []
        var tempDate = startDate

        while tempDate < endDate {
            if calendar.isDate(tempDate, equalTo: startOfMonth, toGranularity: .month) {
                dates.append(tempDate)
            } else {
                dates.append(nil)
            }
            tempDate = calendar.date(byAdding: .day, value: 1, to: tempDate) ?? tempDate
        }

        return dates
    }

    private func eventsForDate(_ date: Date) -> [AllowanceEvent] {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func selectedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.locale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func signedAmountText(for event: AllowanceEvent) -> String {
        let sign = event.category == .withdraw ? "-" : "+"
        return "\(sign)\(currencyManager.formatAmount(event.amount))"
    }

}

private struct PieSliceData {
    let value: Double
    let color: Color
}

private struct DonutChartView: View {
    let slices: [PieSliceData]
    let lineWidth: CGFloat
    @State private var isVisible: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(normalizedSlices.enumerated()), id: \.offset) { index, slice in
                    let gap = min(0.012, (slice.end - slice.start) * 0.35)
                    Circle()
                        .trim(
                            from: slice.start + (gap / 2),
                            to: slice.end - (gap / 2)
                        )
                        .stroke(slice.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(isVisible ? 1 : 0.92)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                isVisible = false
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    isVisible = true
                }
            }
            .onChange(of: slices.count) { _, _ in
                isVisible = false
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    isVisible = true
                }
            }
        }
    }

    private var normalizedSlices: [(start: CGFloat, end: CGFloat, color: Color)] {
        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return [] }

        var start: CGFloat = 0
        return slices.map { slice in
            let portion = CGFloat(slice.value / total)
            let end = start + portion
            defer { start = end }
            return (start: start, end: end, color: slice.color)
        }
    }
}

private struct GoalRadialProgressView: View {
    let percent: Int
    let color: Color
    let lineWidth: CGFloat
    @State private var animatedPercent: Double = 0

    private var clampedPercent: Double {
        min(100, max(0, Double(percent)))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: animatedPercent / 100)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(animatedPercent.rounded()))%")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .onAppear {
            animatedPercent = 0
            withAnimation(.easeOut(duration: 0.45)) {
                animatedPercent = clampedPercent
            }
        }
        .onChange(of: percent) { _, _ in
            animatedPercent = 0
            withAnimation(.easeOut(duration: 0.45)) {
                animatedPercent = clampedPercent
            }
        }
    }
}

private struct AllowanceEvent: Identifiable {
    let id: UUID
    let kidId: UUID
    let kidName: String
    let category: ActivityCategory
    let amount: Double
    let date: Date
    let icon: String
}

private struct HistoryKidFilter: Identifiable {
    let id: UUID
    let name: String
}

private enum SlideDirection {
    case left
    case right
    case none
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
            ZStack {
                Circle()
                    .fill(kid.iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: kid.icon)
                    .font(.title2)
                    .foregroundColor(kid.iconColor)
            }
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
    InsightsView()
        .environmentObject(LanguageManager())
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(ActivityStore())
        .environmentObject(HistoryStore())
        .environmentObject(GoalsStore())
}
