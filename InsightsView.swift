//
//  InsightsView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-25.
//

import Combine
import SwiftUI

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
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var goalsStore: GoalsStore

    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var slideDirection: SlideDirection = .none
    @State private var selectedFactIndex = 0
    @State private var factCarouselAdvancingForward = true

    private let factCarouselTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

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
                icon: icon,
                isProjected: false
            )
        }
    }

    /// Past deposits and withdrawals for the calendar (interest excluded).
    private var pastCalendarEvents: [AllowanceEvent] {
        events.filter { $0.category != .interest }
    }

    /// Scheduled allowance payments in the next 60 days (no interest).
    private var projectedAllowanceEvents: [AllowanceEvent] {
        ScheduledAllowanceProjection.projectedPayments(
            kids: familyStore.kids,
            calendar: calendar
        ).map { item in
            AllowanceEvent(
                id: ScheduledAllowanceProjection.stableEventID(
                    kidId: item.kid.id,
                    scheduledAt: item.scheduledAt,
                    calendar: calendar
                ),
                kidId: item.kid.id,
                kidName: item.kid.name,
                category: .deposit,
                amount: item.kid.weeklyAllowance,
                date: item.scheduledAt,
                icon: "calendar.badge.clock",
                isProjected: true
            )
        }
    }

    private var calendarEvents: [AllowanceEvent] {
        pastCalendarEvents + projectedAllowanceEvents
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
                ScrollView {
                    VStack(spacing: 20) {
                        insightsFactsCard
                        breakdownCard
                        interestByKidCard
                        goalsByKidCard
                        calendarCard
                    }
                    .padding()
                    .padding(.bottom, 70)
                }
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }


    private var insightFacts: [InsightFact] {
        InsightsFactsBuilder.build(
            InsightsFactsBuilder.Context(
                kids: familyStore.kids,
                goals: goalsStore.goals,
                events: events.map { event in
                    InsightsFactsBuilder.InsightsFactEvent(
                        kidId: event.kidId,
                        kidName: event.kidName,
                        amount: event.amount,
                        date: event.date,
                        isInterest: event.category == .interest,
                        isDeposit: event.category == .deposit
                    )
                },
                language: languageManager.language,
                locale: languageManager.locale,
                calendar: calendar,
                referenceDate: Date(),
                formatAmount: { currencyManager.formatAmount($0) }
            )
        )
    }

    private var insightsFactsCard: some View {
        Group {
            if insightFacts.isEmpty {
                Text(languageManager.text(.insightsFactsEmpty))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ZStack {
                    TabView(selection: $selectedFactIndex) {
                        ForEach(Array(insightFacts.enumerated()), id: \.element.id) { index, fact in
                            insightFactSlide(fact)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 68)

                    if insightFacts.count > 1 {
                        HStack {
                            factCarouselButton(
                                systemName: "chevron.left",
                                enabled: selectedFactIndex > 0
                            ) {
                                factCarouselAdvancingForward = false
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFactIndex = max(0, selectedFactIndex - 1)
                                }
                            }

                            Spacer()

                            factCarouselButton(
                                systemName: "chevron.right",
                                enabled: selectedFactIndex < insightFacts.count - 1
                            ) {
                                factCarouselAdvancingForward = true
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFactIndex = min(insightFacts.count - 1, selectedFactIndex + 1)
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onChange(of: insightFacts.count) { _, count in
            if selectedFactIndex >= count {
                selectedFactIndex = max(0, count - 1)
            }
            factCarouselAdvancingForward = true
        }
        .onChange(of: selectedFactIndex) { oldIndex, newIndex in
            if newIndex > oldIndex {
                factCarouselAdvancingForward = true
            } else if newIndex < oldIndex {
                factCarouselAdvancingForward = false
            }
        }
        .onReceive(factCarouselTimer) { _ in
            guard scenePhase == .active else { return }
            advanceFactCarouselAutomatically()
        }
    }

    private func advanceFactCarouselAutomatically() {
        let count = insightFacts.count
        guard count > 1 else { return }

        withAnimation(.easeInOut(duration: 0.35)) {
            if factCarouselAdvancingForward {
                if selectedFactIndex >= count - 1 {
                    factCarouselAdvancingForward = false
                    selectedFactIndex = count - 2
                } else {
                    selectedFactIndex += 1
                }
            } else {
                if selectedFactIndex <= 0 {
                    factCarouselAdvancingForward = true
                    selectedFactIndex = 1
                } else {
                    selectedFactIndex -= 1
                }
            }
        }
    }

    private func insightFactSlide(_ fact: InsightFact) -> some View {
        Group {
            if let goalTitle = fact.highlightedGoalTitle {
                VStack(spacing: 6) {
                    factStyledText(fact.parts)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    HStack(spacing: 6) {
                        Text("🎯")
                            .font(.subheadline)
                        Text(goalTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appGreen)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Text("🎯")
                            .font(.subheadline)
                    }
                }
            } else {
                factStyledText(fact.parts)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 32)
    }

    private func factStyledText(_ parts: [InsightFactPart]) -> Text {
        parts.reduce(Text("")) { combined, part in
            switch part {
            case .plain(let string):
                return combined + Text(string)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            case .amount(let string):
                return combined + Text(string)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appGreen)
            }
        }
    }

    private func factCarouselButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.caption.weight(.bold))
                .foregroundStyle(enabled ? Color.appGreen : Color.secondary.opacity(0.35))
                .frame(width: 28, height: 28)
                .background(Color(.systemBackground).opacity(0.9))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
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
                                let goalGraphicSize: CGFloat = 48
                                VStack(spacing: 12) {
                                    HStack(alignment: .center, spacing: 12) {
                                        GoalRadialProgressView(
                                            percent: item.completionPercent,
                                            color: item.color,
                                            lineWidth: 7
                                        )
                                        .frame(width: goalGraphicSize, height: goalGraphicSize)

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
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                                        KidStoredIconView(
                                            iconName: item.icon,
                                            customImageData: item.customImageData,
                                            size: goalGraphicSize,
                                            symbolAccentColor: item.color
                                        )
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
                                                .opacity(event.isProjected ? 0.45 : 1)
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
                                                .fill(categoryColor(for: event.category).opacity(event.isProjected ? 0.08 : 0.15))
                                                .frame(width: 30, height: 30)
                                            Image(systemName: event.icon)
                                                .font(.caption)
                                                .foregroundColor(categoryColor(for: event.category).opacity(event.isProjected ? 0.7 : 1))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(event.kidName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(eventSubtitle(for: event))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Text(amountText(for: event))
                                            .font(.caption)
                                            .foregroundColor(event.isProjected ? .secondary : .primary)
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

    private func insightsKidColor(forKidId kidId: UUID) -> Color {
        guard let index = familyStore.kids.firstIndex(where: { $0.id == kidId }) else {
            return categoryPalette[0]
        }
        return categoryPalette[index % categoryPalette.count]
    }

    private var kidBalanceColored: [(kidId: UUID, name: String, amount: Double, color: Color)] {
        kidBalanceRows.map { item in
            (
                kidId: item.kidId,
                name: item.name,
                amount: item.amount,
                color: insightsKidColor(forKidId: item.kidId)
            )
        }
    }

    private var goalCompletionRows: [(kidId: UUID, name: String, completionPercent: Int, goalsCount: Int, color: Color, icon: String, customImageData: Data?)] {
        familyStore.kids
            .map { kid in
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
                    color: insightsKidColor(forKidId: kid.id),
                    icon: kid.icon,
                    customImageData: kid.customImageData
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
        calendarEvents.filter { calendar.isDate($0.date, inSameDayAs: date) }
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

    private func eventSubtitle(for event: AllowanceEvent) -> String {
        if event.isProjected {
            return languageManager.text(.insightsCategoryExpectedAllowance)
        }
        return event.category.localizedTitle(language: languageManager.language)
    }

    private func amountText(for event: AllowanceEvent) -> String {
        if event.isProjected {
            return String(
                format: languageManager.text(.insightsExpectedAmountFormat),
                locale: languageManager.locale,
                arguments: [currencyManager.formatAmount(event.amount)]
            )
        }
        return signedAmountText(for: event)
    }

}

private struct PieSliceData {
    let value: Double
    let color: Color
}

private struct DonutChartView: View {
    let slices: [PieSliceData]
    let lineWidth: CGFloat

    private static let appearDuration: TimeInterval = 0.4

    @State private var drawProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(normalizedSlices.enumerated()), id: \.offset) { index, slice in
                    let gap = min(0.012, (slice.end - slice.start) * 0.35)
                    let sliceStart = slice.start + (gap / 2)
                    let sliceEnd = slice.end - (gap / 2)
                    let animatedEnd = sliceStart + (sliceEnd - sliceStart) * drawProgress
                    Circle()
                        .trim(from: sliceStart, to: animatedEnd)
                        .stroke(slice.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .scaleEffect(0.94 + (0.06 * drawProgress))
            .opacity(Double(drawProgress))
            .onAppear { playAppearAnimation() }
            .onChange(of: slices.count) { _, _ in playAppearAnimation() }
        }
    }

    private func playAppearAnimation() {
        drawProgress = 0
        withAnimation(.easeOut(duration: Self.appearDuration)) {
            drawProgress = 1
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
    let isProjected: Bool
}

private enum SlideDirection {
    case left
    case right
    case none
}

#Preview {
    InsightsView()
        .environmentObject(LanguageManager())
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(ActivityStore())
        .environmentObject(GoalsStore())
}
