//
//  ActivityStore.swift
//  Vecko
//

import Combine
import Foundation

struct AllowanceTransaction: Identifiable, Codable {
    let id: UUID
    let kidId: UUID
    var kidName: String
    let amount: Double
    let note: String
    let date: Date
    let isDeposit: Bool
    let isInterest: Bool

    enum CodingKeys: String, CodingKey {
        case id, kidId, kidName, amount, note, date, isDeposit, isInterest
    }

    init(
        id: UUID = UUID(),
        kidId: UUID,
        kidName: String,
        amount: Double,
        note: String,
        date: Date,
        isDeposit: Bool,
        isInterest: Bool = false
    ) {
        self.id = id
        self.kidId = kidId
        self.kidName = kidName
        self.amount = amount
        self.note = note
        self.date = date
        self.isDeposit = isDeposit
        self.isInterest = isInterest
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        kidId = try container.decode(UUID.self, forKey: .kidId)
        kidName = try container.decode(String.self, forKey: .kidName)
        amount = try container.decode(Double.self, forKey: .amount)
        note = try container.decode(String.self, forKey: .note)
        date = try container.decode(Date.self, forKey: .date)
        isDeposit = try container.decode(Bool.self, forKey: .isDeposit)
        isInterest = try container.decodeIfPresent(Bool.self, forKey: .isInterest) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(kidId, forKey: .kidId)
        try container.encode(kidName, forKey: .kidName)
        try container.encode(amount, forKey: .amount)
        try container.encode(note, forKey: .note)
        try container.encode(date, forKey: .date)
        try container.encode(isDeposit, forKey: .isDeposit)
        try container.encode(isInterest, forKey: .isInterest)
    }
}

final class ActivityStore: ObservableObject {
    @Published private(set) var transactions: [AllowanceTransaction] = [] {
        didSet { save() }
    }

    private let storageKey = "allowance.transactions.storage"

    init() {
        load()
    }

    func addTransaction(
        kidId: UUID,
        kidName: String,
        amount: Double,
        note: String,
        isDeposit: Bool,
        isInterest: Bool = false,
        date: Date = Date()
    ) {
        let row = AllowanceTransaction(
            kidId: kidId,
            kidName: kidName,
            amount: amount,
            note: note,
            date: date,
            isDeposit: isDeposit,
            isInterest: isInterest
        )
        transactions.append(row)
    }

    func removeAll(forKidId kidId: UUID) {
        transactions.removeAll { $0.kidId == kidId }
    }

    func clearAllTransactions() {
        transactions = []
    }

    /// Only transactions for kids that still exist in the family list.
    func transactions(forKids kids: [FamilyKid]) -> [AllowanceTransaction] {
        let ids = Set(kids.map(\.id))
        return transactions.filter { ids.contains($0.kidId) }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([AllowanceTransaction].self, from: data)
        else {
            transactions = []
            return
        }
        transactions = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(transactions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
