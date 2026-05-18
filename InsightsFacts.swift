//
//  InsightsFacts.swift
//  Vecko
//

import Foundation
import SwiftUI

enum InsightFactPart: Equatable {
    case plain(String)
    case amount(String)
}

struct InsightFact: Identifiable, Equatable {
    let id: String
    let parts: [InsightFactPart]
    let symbolName: String
    /// When set, the goal name is shown on the next line with target emojis on each side.
    let highlightedGoalTitle: String?

    init(
        id: String,
        parts: [InsightFactPart],
        symbolName: String,
        highlightedGoalTitle: String? = nil
    ) {
        self.id = id
        self.parts = parts
        self.symbolName = symbolName
        self.highlightedGoalTitle = highlightedGoalTitle
    }
}

enum InsightsFactsBuilder {
    struct Context {
        let kids: [FamilyKid]
        let goals: [KidGoal]
        let events: [InsightsFactEvent]
        let language: AppLanguage
        let locale: Locale
        let calendar: Calendar
        let referenceDate: Date
        let formatAmount: (Double) -> String
    }

    struct InsightsFactEvent {
        let kidId: UUID
        let kidName: String
        let amount: Double
        let date: Date
        let isInterest: Bool
        let isDeposit: Bool
    }

    static func build(_ context: Context) -> [InsightFact] {
        var facts: [InsightFact] = []

        if context.kids.isEmpty {
            return [
                InsightFact(
                    id: "welcome",
                    parts: [.plain(AppStringCatalog.string(.insightsFactsEmpty, language: context.language))],
                    symbolName: "sparkles"
                )
            ]
        }

        for kid in context.kids where kid.isBirthday(on: context.referenceDate) {
            facts.append(
                InsightFact(
                    id: "birthday-\(kid.id.uuidString)",
                    parts: [.plain(String(
                        format: AppStringCatalog.string(.insightsFactBirthdayToday, language: context.language),
                        locale: context.locale,
                        arguments: [kid.name]
                    ))],
                    symbolName: "gift.fill"
                )
            )
        }

        let monthEvents = context.events.filter {
            context.calendar.isDate($0.date, equalTo: context.referenceDate, toGranularity: .month)
        }
        let weekInterval = context.calendar.dateInterval(of: .weekOfYear, for: context.referenceDate)
        let weekEvents = context.events.filter { event in
            guard let weekInterval else { return false }
            return weekInterval.contains(event.date)
        }

        let monthInterest = monthEvents.filter(\.isInterest).reduce(0) { $0 + $1.amount }
        if monthInterest > 0 {
            let amount = context.formatAmount(monthInterest)
            facts.append(
                InsightFact(
                    id: "month-interest",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactMonthInterest, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "percent"
                )
            )
        }

        let monthDeposits = monthEvents.filter { $0.isDeposit && !$0.isInterest }.reduce(0) { $0 + $1.amount }
        if monthDeposits > 0 {
            let amount = context.formatAmount(monthDeposits)
            facts.append(
                InsightFact(
                    id: "month-deposits",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactMonthDeposits, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "arrow.down.circle.fill"
                )
            )
        }

        let monthWithdrawals = monthEvents.filter { !$0.isDeposit && !$0.isInterest }.reduce(0) { $0 + $1.amount }
        if monthWithdrawals > 0 {
            let amount = context.formatAmount(monthWithdrawals)
            facts.append(
                InsightFact(
                    id: "month-withdrawals",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactMonthWithdrawals, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "arrow.up.circle.fill"
                )
            )
        }

        let monthNet = monthDeposits - monthWithdrawals
        if monthNet > 0 {
            let amount = context.formatAmount(monthNet)
            facts.append(
                InsightFact(
                    id: "month-net-positive",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactMonthNetPositive, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "chart.line.uptrend.xyaxis"
                )
            )
        } else if monthNet < 0 {
            let amount = context.formatAmount(abs(monthNet))
            facts.append(
                InsightFact(
                    id: "month-net-negative",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactMonthNetNegative, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "chart.line.downtrend.xyaxis"
                )
            )
        }

        appendBiggestSpenderAndSaverFacts(
            monthEvents: monthEvents,
            to: &facts,
            context: context
        )

        let weekDeposits = weekEvents.filter { $0.isDeposit && !$0.isInterest }.reduce(0) { $0 + $1.amount }
        if weekDeposits > 0 {
            let amount = context.formatAmount(weekDeposits)
            facts.append(
                InsightFact(
                    id: "week-deposits",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactWeekDeposits, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "calendar"
                )
            )
        }

        for kid in context.kids {
            let kidGoals = context.goals.filter { $0.kidId == kid.id }
            for goal in kidGoals where goal.targetAmount > 0 {
                let balance = max(0, kid.currentBalance)
                if balance >= goal.targetAmount {
                    let hadDepositThisWeek = weekEvents.contains {
                        $0.kidId == kid.id && $0.isDeposit && !$0.isInterest
                    }
                    let formatKey: AppStringKey = hadDepositThisWeek
                        ? .insightsFactGoalReachedThisWeek
                        : .insightsFactGoalReached
                    facts.append(
                        InsightFact(
                            id: "goal-reached-\(goal.id.uuidString)",
                            parts: [.plain(String(
                                format: AppStringCatalog.string(formatKey, language: context.language),
                                locale: context.locale,
                                arguments: [kid.name]
                            ))],
                            symbolName: "target",
                            highlightedGoalTitle: goal.title
                        )
                    )
                } else {
                    let progress = balance / goal.targetAmount
                    if progress >= 0.75 {
                        let remaining = context.formatAmount(goal.targetAmount - balance)
                        facts.append(
                            InsightFact(
                                id: "goal-close-\(goal.id.uuidString)",
                                parts: [
                                    .plain(String(
                                        format: AppStringCatalog.string(.insightsFactGoalAlmostLead, language: context.language),
                                        locale: context.locale,
                                        arguments: [kid.name]
                                    )),
                                    .amount(remaining),
                                    .plain(AppStringCatalog.string(.insightsFactGoalAlmostTrail, language: context.language)),
                                ],
                                symbolName: "flag.checkered",
                                highlightedGoalTitle: goal.title
                            )
                        )
                    }
                }
            }
        }

        if let topKid = context.kids.max(by: { $0.currentBalance < $1.currentBalance }),
           topKid.currentBalance > 0,
           context.kids.count > 1 {
            let amount = context.formatAmount(topKid.currentBalance)
            facts.append(
                InsightFact(
                    id: "top-balance-\(topKid.id.uuidString)",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactTopBalanceKid, language: context.language),
                        locale: context.locale,
                        amount: amount,
                        leadingArguments: [topKid.name]
                    ),
                    symbolName: "crown.fill"
                )
            )
        }

        let totalBalance = context.kids.reduce(0) { $0 + $1.currentBalance }
        if totalBalance > 0 {
            let amount = context.formatAmount(totalBalance)
            facts.append(
                InsightFact(
                    id: "family-balance",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactFamilyBalance, language: context.language),
                        locale: context.locale,
                        amount: amount
                    ),
                    symbolName: "banknote.fill"
                )
            )
        }

        let activeGoals = context.goals.count
        if activeGoals > 0 {
            facts.append(
                InsightFact(
                    id: "goals-count",
                    parts: [.plain(String(
                        format: AppStringCatalog.string(.insightsFactActiveGoals, language: context.language),
                        locale: context.locale,
                        arguments: [activeGoals]
                    ))],
                    symbolName: "star.fill"
                )
            )
        }

        if facts.isEmpty {
            facts.append(
                InsightFact(
                    id: "tip",
                    parts: [.plain(AppStringCatalog.string(.insightsFactsTip, language: context.language))],
                    symbolName: "lightbulb.fill"
                )
            )
        }

        return facts
    }

    private static func appendBiggestSpenderAndSaverFacts(
        monthEvents: [InsightsFactEvent],
        to facts: inout [InsightFact],
        context: Context
    ) {
        var depositsByKid: [UUID: Double] = [:]
        var withdrawalsByKid: [UUID: Double] = [:]
        var namesByKid: [UUID: String] = [:]

        for event in monthEvents where !event.isInterest {
            namesByKid[event.kidId] = event.kidName
            if event.isDeposit {
                depositsByKid[event.kidId, default: 0] += event.amount
            } else {
                withdrawalsByKid[event.kidId, default: 0] += event.amount
            }
        }

        if let topSpender = withdrawalsByKid.max(by: { lhs, rhs in
            if lhs.value == rhs.value {
                let left = namesByKid[lhs.key] ?? ""
                let right = namesByKid[rhs.key] ?? ""
                return left.localizedCaseInsensitiveCompare(right) == .orderedDescending
            }
            return lhs.value < rhs.value
        }), topSpender.value > 0, let name = namesByKid[topSpender.key] {
            let amount = context.formatAmount(topSpender.value)
            facts.append(
                InsightFact(
                    id: "biggest-spender-\(topSpender.key.uuidString)",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactBiggestSpender, language: context.language),
                        locale: context.locale,
                        amount: amount,
                        leadingArguments: [name]
                    ),
                    symbolName: "arrow.up.circle.fill"
                )
            )
        }

        var netByKid: [(kidId: UUID, name: String, net: Double)] = []
        let kidIds = Set(depositsByKid.keys).union(withdrawalsByKid.keys)
        for kidId in kidIds {
            let net = (depositsByKid[kidId] ?? 0) - (withdrawalsByKid[kidId] ?? 0)
            guard net > 0, let name = namesByKid[kidId] else { continue }
            netByKid.append((kidId: kidId, name: name, net: net))
        }

        if let topSaver = netByKid.max(by: { lhs, rhs in
            if lhs.net == rhs.net {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
            }
            return lhs.net < rhs.net
        }) {
            let amount = context.formatAmount(topSaver.net)
            facts.append(
                InsightFact(
                    id: "biggest-saver-\(topSaver.kidId.uuidString)",
                    parts: partsHighlightingAmount(
                        format: AppStringCatalog.string(.insightsFactBiggestSaver, language: context.language),
                        locale: context.locale,
                        amount: amount,
                        leadingArguments: [topSaver.name]
                    ),
                    symbolName: "arrow.down.circle.fill"
                )
            )
        }
    }

    private static func partsHighlightingAmount(
        format: String,
        locale: Locale,
        amount: String,
        leadingArguments: [CVarArg] = []
    ) -> [InsightFactPart] {
        var arguments: [CVarArg] = leadingArguments
        arguments.append(amount)
        let full = String(format: format, locale: locale, arguments: arguments)
        return splitHighlightingAmount(full, amount: amount)
    }

    private static func splitHighlightingAmount(_ text: String, amount: String) -> [InsightFactPart] {
        guard let range = text.range(of: amount) else {
            return [.plain(text)]
        }
        var parts: [InsightFactPart] = []
        if range.lowerBound > text.startIndex {
            parts.append(.plain(String(text[text.startIndex..<range.lowerBound])))
        }
        parts.append(.amount(amount))
        if range.upperBound < text.endIndex {
            parts.append(.plain(String(text[range.upperBound...])))
        }
        return parts
    }
}
