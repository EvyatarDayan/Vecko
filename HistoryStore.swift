//
//  HistoryStore.swift
//  Vecko
//

import Combine
import Foundation

struct FamilyHistoryEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let detail: String
    let date: Date
    let iconSystemName: String
    let kidId: UUID?
    let kidName: String?

    /// Detail without a leading kid name (shown separately in the UI).
    var displayDetail: String {
        var text = detail
        if let kidName, !kidName.isEmpty {
            let prefix = "\(kidName) · "
            if text.hasPrefix(prefix) {
                text = String(text.dropFirst(prefix.count))
            }
        }
        if title == FamilyHistoryEvent.scheduledAllowancePaid.title
            || title == "Allowance paid"
            || title == "Weekly allowance paid" {
            if let separator = text.range(of: " · ") {
                text = String(text[..<separator.lowerBound])
            }
        }
        return text
    }
}

/// Central catalog of all events that create a history record.
enum FamilyHistoryEvent: String, CaseIterable {
    case kidAdded
    case kidRemoved
    case kidUpdated
    case goalAdded
    case scheduledAllowancePaid
    case monthlyInterestCredited
    case manualDeposit
    case manualWithdraw
    case kidBirthday

    var title: String {
        switch self {
        case .kidAdded: return "Kid added"
        case .kidRemoved: return "Kid removed"
        case .kidUpdated: return "Kid updated"
        case .goalAdded: return "New goal"
        case .scheduledAllowancePaid: return "Allowance paid"
        case .monthlyInterestCredited: return "Interest credited"
        case .manualDeposit: return "Deposit"
        case .manualWithdraw: return "Withdrawal"
        case .kidBirthday: return "Birthday"
        }
    }

    var iconSystemName: String {
        switch self {
        case .kidAdded: return "person.badge.plus"
        case .kidRemoved: return "person.badge.minus"
        case .kidUpdated: return "pencil.circle.fill"
        case .goalAdded: return "target"
        case .scheduledAllowancePaid: return "banknote.fill"
        case .monthlyInterestCredited: return "percent"
        case .manualDeposit: return "plus.circle.fill"
        case .manualWithdraw: return "minus.circle.fill"
        case .kidBirthday: return "gift.fill"
        }
    }

    /// Human-readable trigger for quick reference.
    var trigger: String {
        switch self {
        case .kidAdded: return "A new kid is added in Family."
        case .kidRemoved: return "A kid is deleted in Family."
        case .kidUpdated: return "An existing kid profile is saved."
        case .goalAdded: return "A new goal is added from Goals."
        case .scheduledAllowancePaid: return "Automatic scheduled allowance is credited."
        case .monthlyInterestCredited: return "Monthly interest is credited on month start."
        case .manualDeposit: return "Manual deposit is made from Edit Kid."
        case .manualWithdraw: return "Manual withdrawal is made from Edit Kid."
        case .kidBirthday: return "A kid’s birthday matches today’s calendar date."
        }
    }
}

final class HistoryStore: ObservableObject {
    @Published private(set) var entries: [FamilyHistoryEntry] = [] {
        didSet { save() }
    }

    private let storageKey = "family.history.entries"

    init() {
        load()
    }

    func recordKidAdded(kidId: UUID, kidName: String) {
        append(
            title: FamilyHistoryEvent.kidAdded.title,
            detail: kidName,
            iconSystemName: FamilyHistoryEvent.kidAdded.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordKidRemoved(kidId: UUID, kidName: String) {
        append(
            title: FamilyHistoryEvent.kidRemoved.title,
            detail: kidName,
            iconSystemName: FamilyHistoryEvent.kidRemoved.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordKidUpdated(kidId: UUID, kidName: String, changeLines: [String]) {
        guard !changeLines.isEmpty else { return }
        let detail = changeLines.joined(separator: "\n")
        append(
            title: FamilyHistoryEvent.kidUpdated.title,
            detail: detail,
            iconSystemName: FamilyHistoryEvent.kidUpdated.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordGoalAdded(kidId: UUID, kidName: String, goalTitle: String, targetAmount: Double) {
        let formatted = CurrencyManager().formatAmount(targetAmount)
        append(
            title: FamilyHistoryEvent.goalAdded.title,
            detail: "\(goalTitle) · \(formatted)",
            iconSystemName: FamilyHistoryEvent.goalAdded.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordScheduledAllowancePaid(kidId: UUID, kidName: String, amount: Double) {
        let formatted = CurrencyManager().formatAmount(amount)
        append(
            title: FamilyHistoryEvent.scheduledAllowancePaid.title,
            detail: "+\(formatted)",
            iconSystemName: FamilyHistoryEvent.scheduledAllowancePaid.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordMonthlyInterestCredited(kidId: UUID, kidName: String, percent: Int, amount: Double) {
        let formatted = CurrencyManager().formatAmount(amount)
        append(
            title: FamilyHistoryEvent.monthlyInterestCredited.title,
            detail: "\(percent)% interest paid - \(formatted)",
            iconSystemName: FamilyHistoryEvent.monthlyInterestCredited.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordManualDeposit(kidId: UUID, kidName: String, amount: Double, note: String) {
        let formatted = CurrencyManager().formatAmount(amount)
        var detail = "+\(formatted)"
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            detail += " · \(trimmed)"
        }
        append(
            title: FamilyHistoryEvent.manualDeposit.title,
            detail: detail,
            iconSystemName: FamilyHistoryEvent.manualDeposit.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordKidBirthday(kidId: UUID, kidName: String) {
        append(
            title: FamilyHistoryEvent.kidBirthday.title,
            detail: kidName,
            iconSystemName: FamilyHistoryEvent.kidBirthday.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordManualWithdraw(kidId: UUID, kidName: String, amount: Double, note: String) {
        let formatted = CurrencyManager().formatAmount(amount)
        var detail = "−\(formatted)"
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            detail += " · \(trimmed)"
        }
        append(
            title: FamilyHistoryEvent.manualWithdraw.title,
            detail: detail,
            iconSystemName: FamilyHistoryEvent.manualWithdraw.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func clearAllHistory() {
        entries = []
    }

    private func append(
        title: String,
        detail: String,
        iconSystemName: String,
        kidId: UUID? = nil,
        kidName: String? = nil
    ) {
        let row = FamilyHistoryEntry(
            id: UUID(),
            title: title,
            detail: detail,
            date: Date(),
            iconSystemName: iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
        entries.insert(row, at: 0)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([FamilyHistoryEntry].self, from: data)
        else {
            entries = []
            return
        }
        entries = decoded.sorted { $0.date > $1.date }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

}

// MARK: - Kid profile update descriptions (history)

enum KidProfileUpdateSummary {
    static func changeLines(from original: FamilyKid, to updated: FamilyKid, language: AppLanguage) -> [String] {
        var lines: [String] = []
        let locale = language.locale
        let currency = CurrencyManager()
        let calendar = Calendar.current

        let originalName = original.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedName = updated.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if originalName != updatedName {
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdateNameFormat, language: language),
                    locale: locale,
                    arguments: [updatedName]
                )
            )
        }

        if abs(original.weeklyAllowance - updated.weeklyAllowance) > 0.001 {
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdateAllowanceFormat, language: language),
                    locale: locale,
                    arguments: [currency.formatAmount(updated.weeklyAllowance)]
                )
            )
        }

        if original.monthlyInterestPercent != updated.monthlyInterestPercent {
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdateInterestFormat, language: language),
                    locale: locale,
                    arguments: [updated.monthlyInterestPercent]
                )
            )
        }

        if original.depositWeekday != updated.depositWeekday {
            let dayName = AppStringCatalog.weekdayName(updated.depositWeekday, language: language)
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdatePayDayFormat, language: language),
                    locale: locale,
                    arguments: [dayName]
                )
            )
        }

        if !isSameHourAndMinute(original.depositTime, updated.depositTime, calendar: calendar) {
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.timeStyle = .short
            let timeText = formatter.string(from: updated.depositTime)
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdateDepositTimeFormat, language: language),
                    locale: locale,
                    arguments: [timeText]
                )
            )
        }

        let originalBirthday = original.birthday.map { calendar.startOfDay(for: $0) }
        let updatedBirthday = updated.birthday.map { calendar.startOfDay(for: $0) }
        if originalBirthday != updatedBirthday, let birthday = updated.birthday {
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let dateText = formatter.string(from: birthday)
            lines.append(
                String(
                    format: AppStringCatalog.string(.historyKidUpdateBirthdayFormat, language: language),
                    locale: locale,
                    arguments: [dateText]
                )
            )
        }

        if original.icon != updated.icon || !isSameImageData(original.customImageData, updated.customImageData) {
            lines.append(AppStringCatalog.string(.historyKidUpdatePhotoFormat, language: language))
        }

        return lines
    }

    private static func isSameHourAndMinute(_ a: Date, _ b: Date, calendar: Calendar) -> Bool {
        calendar.component(.hour, from: a) == calendar.component(.hour, from: b)
            && calendar.component(.minute, from: a) == calendar.component(.minute, from: b)
    }

    private static func isSameImageData(_ a: Data?, _ b: Data?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (lhs?, rhs?): return lhs == rhs
        default: return false
        }
    }
}

extension HistoryStore {
    private static func groupedAmountString(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.secondaryGroupingSize = 3
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
