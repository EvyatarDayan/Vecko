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

    var title: String {
        switch self {
        case .kidAdded: return "Kid added"
        case .kidRemoved: return "Kid removed"
        case .kidUpdated: return "Kid updated"
        case .goalAdded: return "Goal added"
        case .scheduledAllowancePaid: return "Allowance paid"
        case .monthlyInterestCredited: return "Interest credited"
        case .manualDeposit: return "Deposit"
        case .manualWithdraw: return "Withdrawal"
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

    func recordKidUpdated(kidId: UUID, kidName: String) {
        append(
            title: FamilyHistoryEvent.kidUpdated.title,
            detail: kidName,
            iconSystemName: FamilyHistoryEvent.kidUpdated.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordGoalAdded(kidId: UUID, kidName: String, goalTitle: String, targetAmount: Double) {
        let amt = Self.groupedAmountString(targetAmount)
        append(
            title: FamilyHistoryEvent.goalAdded.title,
            detail: "\(kidName) · \(goalTitle) · \(amt)",
            iconSystemName: FamilyHistoryEvent.goalAdded.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordScheduledAllowancePaid(kidId: UUID, kidName: String, amount: Double, scheduleLabel: String) {
        let amt = Self.groupedAmountString(amount)
        append(
            title: FamilyHistoryEvent.scheduledAllowancePaid.title,
            detail: "\(kidName) · +\(amt) · \(scheduleLabel)",
            iconSystemName: FamilyHistoryEvent.scheduledAllowancePaid.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordMonthlyInterestCredited(kidId: UUID, kidName: String, percent: Int, amount: Double) {
        let amt = Self.groupedAmountString(amount)
        append(
            title: FamilyHistoryEvent.monthlyInterestCredited.title,
            detail: "\(kidName) · \(percent)% · +\(amt)",
            iconSystemName: FamilyHistoryEvent.monthlyInterestCredited.iconSystemName,
            kidId: kidId,
            kidName: kidName
        )
    }

    func recordManualDeposit(kidId: UUID, kidName: String, amount: Double, note: String) {
        let amt = Self.groupedAmountString(amount)
        var detail = "\(kidName) · +\(amt)"
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

    func recordManualWithdraw(kidId: UUID, kidName: String, amount: Double, note: String) {
        let amt = Self.groupedAmountString(amount)
        var detail = "\(kidName) · −\(amt)"
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
