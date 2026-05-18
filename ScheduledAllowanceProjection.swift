//
//  ScheduledAllowanceProjection.swift
//  Vecko
//

import Foundation

enum ScheduledAllowanceProjection {
    /// Upcoming scheduled allowance payments (excludes interest).
    static func projectedPayments(
        kids: [FamilyKid],
        from now: Date = Date(),
        horizonDays: Int = 60,
        calendar: Calendar = .current
    ) -> [(kid: FamilyKid, scheduledAt: Date)] {
        guard horizonDays > 0 else { return [] }
        let horizonEnd = calendar.date(byAdding: .day, value: horizonDays, to: now) ?? now
        var results: [(kid: FamilyKid, scheduledAt: Date)] = []

        for kid in kids {
            guard kid.weeklyAllowance > 0 else { continue }
            let dates: [Date]
            switch kid.depositFrequency {
            case .weekly:
                dates = weeklyOccurrences(kid: kid, through: horizonEnd, calendar: calendar)
            case .monthly:
                dates = monthlyOccurrences(kid: kid, through: horizonEnd, calendar: calendar)
            }
            for scheduledAt in dates where scheduledAt > now && scheduledAt <= horizonEnd {
                guard !isAllowanceAlreadyPaid(for: kid, scheduledAt: scheduledAt, calendar: calendar) else { continue }
                results.append((kid: kid, scheduledAt: scheduledAt))
            }
        }

        return results.sorted { lhs, rhs in lhs.scheduledAt < rhs.scheduledAt }
    }

    /// First scheduled allowance date on or after `now` when cumulative deposits reach `remaining`.
    static func completionDate(
        for kid: FamilyKid,
        remaining: Double,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        guard remaining > 0.001, kid.weeklyAllowance > 0 else { return nil }

        var left = remaining
        let paymentCount = Int(ceil(remaining / kid.weeklyAllowance))
        let horizonDays = min(365 * 10, max(120, paymentCount * 14 + 30))
        let payments = projectedPayments(kids: [kid], from: now, horizonDays: horizonDays, calendar: calendar)

        for entry in payments {
            left -= kid.weeklyAllowance
            if left <= 0.001 {
                return entry.scheduledAt
            }
        }
        return nil
    }

    static func stableEventID(kidId: UUID, scheduledAt: Date, calendar: Calendar) -> UUID {
        let dayStart = calendar.startOfDay(for: scheduledAt)
        var hasher = Hasher()
        hasher.combine("vecko.projected.allowance")
        hasher.combine(kidId)
        hasher.combine(dayStart.timeIntervalSince1970)
        let hash = UInt64(bitPattern: Int64(hasher.finalize()))
        return UUID(uuid: (
            UInt8((hash >> 56) & 0xff),
            UInt8((hash >> 48) & 0xff),
            UInt8((hash >> 40) & 0xff),
            UInt8((hash >> 32) & 0xff),
            UInt8((hash >> 24) & 0xff),
            UInt8((hash >> 16) & 0xff),
            UInt8((hash >> 8) & 0xff),
            UInt8(hash & 0xff),
            0xA1, 0xB2, 0xC3, 0xD4, 0xE5, 0xF6, 0x07, 0x18
        ))
    }

    private static func weeklyOccurrences(kid: FamilyKid, through horizonEnd: Date, calendar: Calendar) -> [Date] {
        let rangeStart = calendar.startOfDay(for: Date())
        var cursor = rangeStart
        while calendar.component(.weekday, from: cursor) != kid.depositWeekday {
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { return [] }
            cursor = next
        }

        var results: [Date] = []
        while let scheduled = dateByApplyingDepositTime(kid.depositTime, to: cursor, calendar: calendar) {
            if scheduled > horizonEnd { break }
            results.append(scheduled)
            guard let nextWeek = calendar.date(byAdding: .day, value: 7, to: cursor) else { break }
            cursor = nextWeek
        }
        return results
    }

    private static func monthlyOccurrences(kid: FamilyKid, through horizonEnd: Date, calendar: Calendar) -> [Date] {
        let rangeStart = calendar.startOfDay(for: Date())
        guard var monthCursor = calendar.date(from: calendar.dateComponents([.year, .month], from: rangeStart)) else {
            return []
        }

        var results: [Date] = []
        let payDay = kid.depositMonthlyDay

        while monthCursor <= horizonEnd {
            if let dayCount = calendar.range(of: .day, in: .month, for: monthCursor)?.count {
                var components = calendar.dateComponents([.year, .month], from: monthCursor)
                components.day = min(payDay, dayCount)
                if let dayDate = calendar.date(from: components),
                   let scheduled = dateByApplyingDepositTime(kid.depositTime, to: dayDate, calendar: calendar),
                   scheduled >= rangeStart {
                    results.append(scheduled)
                }
            }
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthCursor) else { break }
            monthCursor = nextMonth
        }
        return results
    }

    private static func dateByApplyingDepositTime(_ depositTime: Date, to day: Date, calendar: Calendar) -> Date? {
        let hour = calendar.component(.hour, from: depositTime)
        let minute = calendar.component(.minute, from: depositTime)
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }

    private static func isAllowanceAlreadyPaid(for kid: FamilyKid, scheduledAt: Date, calendar: Calendar) -> Bool {
        guard let last = kid.lastScheduledAllowancePaymentAt else { return false }
        switch kid.depositFrequency {
        case .weekly:
            let y1 = calendar.component(.yearForWeekOfYear, from: last)
            let w1 = calendar.component(.weekOfYear, from: last)
            let y2 = calendar.component(.yearForWeekOfYear, from: scheduledAt)
            let w2 = calendar.component(.weekOfYear, from: scheduledAt)
            return y1 == y2 && w1 == w2
        case .monthly:
            return calendar.isDate(last, equalTo: scheduledAt, toGranularity: .month)
        }
    }
}
