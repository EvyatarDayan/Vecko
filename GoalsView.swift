//
//  GoalsView.swift
//  Vecko
//

import Combine
import SwiftUI
import UIKit

struct KidGoal: Identifiable, Codable {
    let id: UUID
    var kidId: UUID
    var title: String
    var targetAmount: Double
    var imageData: Data?
    var iconSystemName: String?
    var createdAt: Date
}

final class GoalsStore: ObservableObject {
    @Published private(set) var goals: [KidGoal] = [] {
        didSet { save() }
    }

    private let storageKey = "family.kid.goals.storage"

    init() {
        load()
    }

    func addGoal(_ goal: KidGoal) {
        goals.insert(goal, at: 0)
    }

    func updateGoal(_ updatedGoal: KidGoal) {
        guard let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) else { return }
        goals[index] = updatedGoal
    }

    func removeGoal(id: UUID) {
        goals.removeAll { $0.id == id }
    }

    func goals(for kidId: UUID) -> [KidGoal] {
        goals.filter { $0.kidId == kidId }
    }

    func removeGoals(forKidId kidId: UUID) {
        goals.removeAll { $0.kidId == kidId }
    }

    func clearAllGoals() {
        goals = []
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([KidGoal].self, from: data)
        else {
            goals = []
            return
        }
        goals = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(goals) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

// MARK: - Goal image presentation (shared background, crop, shadow, PNG)

private enum GoalThumbnailMetrics {
    static let aspectRatio: CGFloat = 1
    static let cornerRadius: CGFloat = 12
    static let listSize: CGFloat = 84
    static let shadowOpacity: Double = 0.12
    static let shadowRadius: CGFloat = 6
    static let shadowY: CGFloat = 3
}

private enum GoalImageEncoding {
    static func hasTransparency(_ image: UIImage) -> Bool {
        guard let alpha = image.cgImage?.alphaInfo else { return false }
        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        default:
            return false
        }
    }

    static func data(from image: UIImage?) -> Data? {
        guard let image else { return nil }
        if hasTransparency(image), let png = image.pngData() {
            return png
        }
        return image.jpegData(compressionQuality: 0.85)
    }
}

private struct GoalThumbnailView: View {
    @Environment(\.colorScheme) private var colorScheme

    let imageData: Data?
    let previewImage: UIImage?
    let iconSystemName: String?
    var size: CGFloat = GoalThumbnailMetrics.listSize
    var cornerRadius: CGFloat = GoalThumbnailMetrics.cornerRadius

    init(
        imageData: Data? = nil,
        previewImage: UIImage? = nil,
        iconSystemName: String? = nil,
        size: CGFloat = GoalThumbnailMetrics.listSize,
        cornerRadius: CGFloat = GoalThumbnailMetrics.cornerRadius
    ) {
        self.imageData = imageData
        self.previewImage = previewImage
        self.iconSystemName = iconSystemName
        self.size = size
        self.cornerRadius = cornerRadius
    }

    private var resolvedUIImage: UIImage? {
        if let previewImage { return previewImage }
        if let imageData { return UIImage(data: imageData) }
        return nil
    }

    private var thumbnailBackgroundColor: Color {
        colorScheme == .dark
            ? Color(UIColor.systemGray4)
            : Color(UIColor.systemGray5)
    }

    /// Inset for photo/PNG inside the fixed outer frame (frame size unchanged).
    private var imageContentPadding: CGFloat {
        size * 0.16
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(thumbnailBackgroundColor)

            thumbnailContent
        }
        .aspectRatio(GoalThumbnailMetrics.aspectRatio, contentMode: .fit)
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(
            color: .black.opacity(GoalThumbnailMetrics.shadowOpacity),
            radius: GoalThumbnailMetrics.shadowRadius,
            x: 0,
            y: GoalThumbnailMetrics.shadowY
        )
    }

    @ViewBuilder
    private var thumbnailContent: some View {
        if let uiImage = resolvedUIImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .padding(imageContentPadding)
        } else if let iconSystemName {
            Image(systemName: iconSystemName)
                .font(.system(size: size * 0.28, weight: .medium))
                .foregroundStyle(Color.blue.opacity(colorScheme == .dark ? 0.95 : 0.85))
        } else {
            Image(systemName: "photo")
                .font(.system(size: size * 0.28, weight: .medium))
                .foregroundStyle(Color.blue.opacity(colorScheme == .dark ? 0.7 : 0.55))
        }
    }
}

struct GoalsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var goalsStore: GoalsStore
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var showingAddGoal = false
    @State private var editingGoal: KidGoal?
    @State private var detailGoal: KidGoal?
    @State private var selectedKidID: UUID?

    private var kids: [FamilyKid] { familyStore.kids }

    private var selectedKid: FamilyKid? {
        guard let selectedKidID else { return nil }
        return kids.first(where: { $0.id == selectedKidID })
    }

    private var visibleGoals: [KidGoal] {
        guard let selectedKidID else { return goalsStore.goals }
        return goalsStore.goals(for: selectedKidID)
    }

    var body: some View {
        goalsNavigationStack
            .onAppear {
                syncSelectedKid()
            }
            .onChange(of: kids.map(\.id)) { _, _ in
                syncSelectedKid()
            }
    }

    private var goalsNavigationStack: some View {
        NavigationStack {
            goalsZStackWithChrome
                .background(Color(.systemGroupedBackground))
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingAddGoal) {
                    addGoalSheet
                }
                .sheet(item: $editingGoal) { goal in
                    editGoalSheet(goal: goal)
                }
                .sheet(item: $detailGoal) { goal in
                    GoalDetailSheet(
                        goal: goal,
                        kid: kid(for: goal.kidId)
                    )
                    .environmentObject(currencyManager)
                    .environmentObject(languageManager)
                }
        }
    }

    private var goalsZStackWithChrome: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                pageHeader
                if kids.isEmpty {
                    emptyKidsState
                } else {
                    kidSelector
                    goalsContent
                }
            }
            addGoalFloatingButton
        }
    }

    private var addGoalFloatingButton: some View {
        Button {
            showingAddGoal = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.appGreen)
        }
        .veckoToolbarActionStyle()
        .padding(.top, 6)
        .padding(.trailing, 20)
        .disabled(kids.isEmpty)
    }

    private var addGoalSheet: some View {
        AddGoalView(mode: .add(defaultKidId: selectedKid?.id)) { goal in
            goalsStore.addGoal(goal)
            let kidName = familyStore.kids.first(where: { $0.id == goal.kidId })?.name ?? languageManager.text(.unknownKid)
            historyStore.recordGoalAdded(kidId: goal.kidId, kidName: kidName, goalTitle: goal.title, targetAmount: goal.targetAmount)
        }
        .environmentObject(familyStore)
        .environmentObject(currencyManager)
        .environmentObject(languageManager)
    }

    private func editGoalSheet(goal: KidGoal) -> some View {
        AddGoalView(mode: .edit(goal), onSave: { updated in
            goalsStore.updateGoal(updated)
        }, onDelete: {
            goalsStore.removeGoal(id: goal.id)
        })
        .environmentObject(familyStore)
        .environmentObject(currencyManager)
        .environmentObject(languageManager)
    }

    private var pageHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.goalsTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(languageManager.text(.goalsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
         .padding(.top, 15)
         .padding(.bottom, 6)
    }

    private var goalsFilterChipIdleBackground: Color {
        if colorScheme == .light {
            Color(UIColor.systemGray5)
        } else {
            Color(UIColor.secondarySystemBackground)
        }
    }

    private func syncSelectedKid() {
        let ids = Set(kids.map(\.id))
        if let selectedKidID, ids.contains(selectedKidID) {
            return
        }
        selectedKidID = nil
    }

    private var kidSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button {
                    selectedKidID = nil
                } label: {
                    Text(languageManager.text(.goalsAll))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedKidID == nil ? Color.blue.opacity(0.18) : goalsFilterChipIdleBackground)
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(kids) { kid in
                    Button {
                        selectedKidID = kid.id
                    } label: {
                        HStack(spacing: 5) {
                            KidStoredIconView(
                                iconName: kid.icon,
                                customImageData: kid.customImageData,
                                size: 18,
                                symbolAccentColor: kid.iconColor
                            )
                            Text(kid.name)
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedKidID == kid.id ? Color.blue.opacity(0.18) : goalsFilterChipIdleBackground)
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

    private var emptyGoalsTitle: String {
        if let kid = selectedKid {
            String(
                format: languageManager.text(.goalsNoGoalsForKidTitleFormat),
                locale: languageManager.locale,
                arguments: [kid.name]
            )
        } else {
            languageManager.text(.goalsNoGoalsTitle)
        }
    }

    private var emptyGoalsSubtitle: String {
        if let kid = selectedKid {
            String(
                format: languageManager.text(.goalsNoGoalsForKidSubtitleFormat),
                locale: languageManager.locale,
                arguments: [kid.name]
            )
        } else {
            languageManager.text(.goalsNoGoalsSubtitle)
        }
    }

    private var goalsContent: some View {
        Group {
            if visibleGoals.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image("goal")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .opacity(0.85)
                    Text(emptyGoalsTitle)
                        .font(.headline)
                    Text(emptyGoalsSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(visibleGoals) { goal in
                            goalListRow(goal: goal)
                        }
                    }
                    .padding()
                    .padding(.bottom, 70)
                }
            }
        }
    }

    @ViewBuilder
    private func goalListRow(goal: KidGoal) -> some View {
        GoalRowView(
            goal: goal,
            kid: kid(for: goal.kidId),
            onInfo: { detailGoal = goal }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            editingGoal = goal
        }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    goalsStore.removeGoal(id: goal.id)
                } label: {
                    Label(languageManager.text(.goalsDeleteSwipe), systemImage: "trash")
                }
            }
    }

    private var emptyKidsState: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text(languageManager.text(.goalsNoKidsTitle))
                .font(.headline)
            Text(languageManager.text(.goalsNoKidsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func kid(for id: UUID) -> FamilyKid? {
        kids.first(where: { $0.id == id })
    }
}

/// Shared goal progress colors: blue under 30%, orange 30–70%, green 70%+.
private enum GoalProgressStyling {
    enum Tier: Equatable {
        case neutralBlue
        case warmOrange
        case green
    }

    static func tier(for progress: Double) -> Tier {
        if progress < 0.3 { return .neutralBlue }
        if progress < 0.7 { return .warmOrange }
        return .green
    }

    static func percentColor(for progress: Double) -> Color {
        switch tier(for: progress) {
        case .neutralBlue:
            return Color(red: 0.26, green: 0.48, blue: 0.78)
        case .warmOrange:
            return Color(red: 0.92, green: 0.48, blue: 0.12)
        case .green:
            return Color.appGreen
        }
    }
}

private enum GoalTimeToGoLabel {
    static func text(
        goal: KidGoal,
        kid: FamilyKid?,
        language: AppLanguage,
        locale: Locale,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> String? {
        guard goal.targetAmount > 0 else { return nil }
        let balance = max(0, kid?.currentBalance ?? 0)

        if balance >= goal.targetAmount {
            return AppStringCatalog.string(.goalsTimeToGoReached, language: language)
        }

        guard let kid else { return nil }
        let remaining = goal.targetAmount - balance

        guard kid.weeklyAllowance > 0 else {
            return AppStringCatalog.string(.goalsTimeToGoNoAllowance, language: language)
        }

        guard let completionDate = ScheduledAllowanceProjection.completionDate(
            for: kid,
            remaining: remaining,
            from: now,
            calendar: calendar
        ) else {
            return AppStringCatalog.string(.goalsTimeToGoBeyondHorizon, language: language)
        }

        return formattedInterval(
            from: now,
            to: completionDate,
            language: language,
            locale: locale,
            calendar: calendar
        )
    }

    private static func formattedInterval(
        from now: Date,
        to completionDate: Date,
        language: AppLanguage,
        locale: Locale,
        calendar: Calendar
    ) -> String {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: completionDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0

        if days <= 0 {
            return AppStringCatalog.string(.goalsTimeToGoToday, language: language)
        }
        if days == 1 {
            return AppStringCatalog.string(.goalsTimeToGoOneDay, language: language)
        }
        if days < 7 {
            return String(
                format: AppStringCatalog.string(.goalsTimeToGoDaysFormat, language: language),
                locale: locale,
                arguments: [days]
            )
        }

        let weeks = max(1, (days + 6) / 7)
        if days < 45 {
            if weeks == 1 {
                return AppStringCatalog.string(.goalsTimeToGoOneWeek, language: language)
            }
            return String(
                format: AppStringCatalog.string(.goalsTimeToGoWeeksFormat, language: language),
                locale: locale,
                arguments: [weeks]
            )
        }

        let months = max(1, (days + 14) / 30)
        if months == 1 {
            return AppStringCatalog.string(.goalsTimeToGoOneMonth, language: language)
        }
        return String(
            format: AppStringCatalog.string(.goalsTimeToGoMonthsFormat, language: language),
            locale: locale,
            arguments: [months]
        )
    }
}

private struct GoalDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let goal: KidGoal
    let kid: FamilyKid?

    private var progress: Double {
        let balance = max(0, kid?.currentBalance ?? 0)
        guard goal.targetAmount > 0 else { return 0 }
        return min(1, balance / goal.targetAmount)
    }

    private var progressPercentText: String {
        String(
            format: languageManager.text(.goalsPercentCompleteFormat),
            locale: languageManager.locale,
            arguments: [Int((progress * 100).rounded())]
        )
    }

    private var timeToGoLabel: String? {
        GoalTimeToGoLabel.text(
            goal: goal,
            kid: kid,
            language: languageManager.language,
            locale: languageManager.locale
        )
    }

    private var kidPossessiveGoalTitle: String? {
        guard let name = kid?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return nil
        }
        return String(
            format: languageManager.text(.goalsKidPossessiveGoalFormat),
            locale: languageManager.locale,
            arguments: [name]
        )
    }

    private var balanceLine: String {
        currencyManager.formatAmount(kid?.currentBalance ?? 0)
            + " / "
            + currencyManager.formatAmount(goal.targetAmount)
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(spacing: 14) {
                    GoalThumbnailView(
                        imageData: goal.imageData,
                        iconSystemName: goal.iconSystemName,
                        size: 88,
                        cornerRadius: GoalThumbnailMetrics.cornerRadius
                    )

                    Text(goal.title)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)

                    if let kidPossessiveGoalTitle {
                        HStack(spacing: 12) {
                            if let kid {
                                KidStoredIconView(
                                    iconName: kid.icon,
                                    customImageData: kid.customImageData,
                                    size: 48,
                                    symbolAccentColor: kid.iconColor
                                )
                            }
                            Text(kidPossessiveGoalTitle)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Text(progressPercentText)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(GoalProgressStyling.percentColor(for: progress))
                        .multilineTextAlignment(.center)

                    Text(balanceLine)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    if let timeToGoLabel {
                        Text(timeToGoLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(progress >= 1 ? Color.appGreen : .secondary)
                            .multilineTextAlignment(.center)
                    }
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
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.visible)
    }
}

private struct GoalRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let goal: KidGoal
    let kid: FamilyKid?
    let onInfo: () -> Void

    private var progress: Double {
        let balance = max(0, kid?.currentBalance ?? 0)
        guard goal.targetAmount > 0 else { return 0 }
        return min(1, balance / goal.targetAmount)
    }

    private var progressColorTier: GoalProgressStyling.Tier {
        GoalProgressStyling.tier(for: progress)
    }

    private var progressPercentText: String {
        "\(Int((progress * 100).rounded()))%"
    }

    private var kidPossessiveGoalTitle: String? {
        guard let name = kid?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return nil
        }
        return String(
            format: languageManager.text(.goalsKidPossessiveGoalFormat),
            locale: languageManager.locale,
            arguments: [name]
        )
    }

    private var progressPercentForeground: Color {
        GoalProgressStyling.percentColor(for: progress)
    }

    private var progressTrackGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.secondary.opacity(colorScheme == .dark ? 0.22 : 0.12),
                Color.secondary.opacity(colorScheme == .dark ? 0.34 : 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var progressFillGradient: LinearGradient {
        switch progressColorTier {
        case .neutralBlue:
            return LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.65, blue: 0.95).opacity(0.78),
                    Color(red: 0.22, green: 0.45, blue: 0.78).opacity(0.95),
                    Color(red: 0.18, green: 0.38, blue: 0.72)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .warmOrange:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.78, blue: 0.45).opacity(0.95),
                    Color(red: 0.98, green: 0.55, blue: 0.2),
                    Color(red: 0.88, green: 0.42, blue: 0.08)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .green:
            return LinearGradient(
                colors: [
                    Color.appGreen.opacity(0.68),
                    Color.appGreen.opacity(0.92),
                    Color.appGreen
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var progressHighCompletionGlow: (color: Color, radius: CGFloat) {
        guard progressColorTier == .green else {
            return (.clear, 0)
        }
        let intensity = min(1, (progress - 0.7) / 0.3)
        let opacity = 0.22 + 0.38 * intensity
        let radius: CGFloat = 4 + 6 * intensity
        return (Color.appGreen.opacity(opacity), radius)
    }

    private let progressPercentReserveWidth: CGFloat = 48

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            GoalThumbnailView(
                imageData: goal.imageData,
                iconSystemName: goal.iconSystemName,
                size: GoalThumbnailMetrics.listSize
            )

            VStack(alignment: .leading, spacing: 8) {
                if let kidPossessiveGoalTitle {
                    HStack(spacing: 8) {
                        if let kid {
                            kidProfileBadge(kid: kid)
                        }
                        Text(kidPossessiveGoalTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.trailing, progressPercentReserveWidth)
                }

                Text(goal.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, progressPercentReserveWidth)

                GeometryReader { geometry in
                    let fillWidth = max(0, geometry.size.width * progress)
                    let glow = progressHighCompletionGlow
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(progressTrackGradient)
                        Capsule()
                            .fill(progressFillGradient)
                            .frame(width: fillWidth)
                            .shadow(
                                color: progressColorTier == .green ? glow.color : .clear,
                                radius: progressColorTier == .green ? glow.radius : 0,
                                x: 0,
                                y: 0
                            )
                    }
                }
                .frame(height: 9)
            }
            .frame(minHeight: 84, alignment: .top)

            Button(action: onInfo) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(languageManager.text(.goalsDetailInfoAccessibility))
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(alignment: .topTrailing) {
            Text(progressPercentText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(progressPercentForeground)
                .padding(.top, 14)
                .padding(.trailing, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color(.systemGray4) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }

    @ViewBuilder
    private func kidProfileBadge(kid: FamilyKid) -> some View {
        KidStoredIconView(
            iconName: kid.icon,
            customImageData: kid.customImageData,
            size: 28,
            symbolAccentColor: kid.iconColor
        )
        .overlay(
            Circle()
                .strokeBorder(Color(.systemBackground), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}

private struct AddGoalView: View {
    enum Mode {
        case add(defaultKidId: UUID?)
        case edit(KidGoal)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager

    let mode: Mode
    let onSave: (KidGoal) -> Void
    let onDelete: (() -> Void)?

    @State private var selectedKidIDs: Set<UUID>
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var selectedImage: UIImage?
    @State private var selectedIcon: String?
    @State private var showingAssetPicker = false
    @State private var attemptedSave = false
    @State private var showingDeleteConfirm = false

    init(mode: Mode, onSave: @escaping (KidGoal) -> Void, onDelete: (() -> Void)? = nil) {
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete

        switch mode {
        case .add(let defaultKidId):
            var initialKidIDs = Set<UUID>()
            if let defaultKidId {
                initialKidIDs.insert(defaultKidId)
            }
            _selectedKidIDs = State(initialValue: initialKidIDs)
            _title = State(initialValue: "")
            _targetAmount = State(initialValue: "")
            _selectedImage = State(initialValue: nil)
            _selectedIcon = State(initialValue: nil)
        case .edit(let goal):
            _selectedKidIDs = State(initialValue: [goal.kidId])
            _title = State(initialValue: goal.title)
            _targetAmount = State(initialValue: String(format: "%.2f", goal.targetAmount))
            _selectedIcon = State(initialValue: goal.iconSystemName)
            if let data = goal.imageData, let image = UIImage(data: data) {
                _selectedImage = State(initialValue: image)
            } else {
                _selectedImage = State(initialValue: nil)
            }
        }
    }

    private var kids: [FamilyKid] { familyStore.kids }

    private var allKidIDs: Set<UUID> {
        Set(kids.map(\.id))
    }

    private var allSelected: Bool {
        !allKidIDs.isEmpty && selectedKidIDs == allKidIDs
    }

    private var selectedKids: [FamilyKid] {
        kids.filter { selectedKidIDs.contains($0.id) }
    }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isAmountValid: Bool {
        (Double(targetAmount) ?? 0) > 0
    }

    private var isKidValid: Bool {
        !selectedKidIDs.isEmpty
    }

    private var isVisualValid: Bool {
        selectedImage != nil || selectedIcon != nil
    }

    private var isValid: Bool {
        isTitleValid && isAmountValid && isKidValid && isVisualValid
    }

    private var isKidSelectionLocked: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: navigationTitle,
                    leadingTitle: languageManager.text(.commonCancel),
                    trailingTitle: languageManager.text(.commonSave),
                    onLeading: { dismiss() },
                    onTrailing: { saveGoal() }
                )
                Form {
                Section(languageManager.text(.goalsGoalName)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.14))
                        KidCenteredTextInputRow(
                            text: $title,
                            isValid: isTitleValid,
                            showErrorAppearance: attemptedSave,
                            placeholderOK: languageManager.text(.goalsGoalTitlePlaceholder),
                            placeholderError: languageManager.text(.goalsGoalTitleRequired)
                        )
                        .frame(minHeight: 48)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                Section(languageManager.text(.goalsCost)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.14))
                        KidAllowanceInputRow(
                            text: $targetAmount,
                            symbol: currencyManager.getCurrencySymbol(),
                            isValid: isAmountValid,
                            showErrorAppearance: attemptedSave,
                            placeholderOK: "0.00",
                            placeholderError: languageManager.text(.goalsTargetRequired)
                        )
                        .frame(minHeight: 48)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .onChange(of: targetAmount) { _, newValue in
                    targetAmount = sanitizeNumericInput(newValue)
                }

                Section(languageManager.text(.goalsSectionPhoto)) {
                    HStack(spacing: 12) {
                        GoalThumbnailView(
                            previewImage: selectedImage,
                            iconSystemName: selectedIcon,
                            size: 60,
                            cornerRadius: 10
                        )

                        Button(attemptedSave && !isVisualValid ? languageManager.text(.goalsPhotoRequired) : languageManager.text(.goalsAddPhoto)) {
                            showingAssetPicker = true
                        }
                        .foregroundStyle(attemptedSave && !isVisualValid ? .red : .blue)
                    }
                }

                Section {
                    Button {
                        if allSelected {
                            selectedKidIDs.removeAll()
                        } else {
                            selectedKidIDs = allKidIDs
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(languageManager.text(.familySelectAll))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: allSelected ? "checkmark.square.fill" : "square")
                                .foregroundStyle(allSelected ? .blue : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .kidsSelectionListSeparatorInsets()

                    ForEach(kids) { kid in
                        Button {
                            if selectedKidIDs.contains(kid.id) {
                                selectedKidIDs.remove(kid.id)
                            } else {
                                selectedKidIDs.insert(kid.id)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                KidStoredIconView(
                                    iconName: kid.icon,
                                    customImageData: kid.customImageData,
                                    size: 28,
                                    symbolAccentColor: kid.iconColor
                                )
                                Text(kid.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: selectedKidIDs.contains(kid.id) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(selectedKidIDs.contains(kid.id) ? .blue : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .kidsSelectionListSeparatorInsets()
                    }

                    if !selectedKids.isEmpty {
                        SelectedKidsOverlappingAvatars(kids: selectedKids)
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 12, trailing: 8))
                            .kidsSelectionListSeparatorInsets()
                            .listRowSeparator(.hidden, edges: .bottom)
                    }
                } header: {
                    Text(languageManager.text(.goalsSelectKid))
                } footer: {
                    if attemptedSave && !isKidValid {
                        Text(languageManager.text(.goalsKidRequired))
                            .foregroundStyle(.red)
                    }
                }
                .disabled(isKidSelectionLocked)
                .opacity(isKidSelectionLocked ? 0.55 : 1)

                if case .edit = mode, onDelete != nil {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirm = true
                        } label: {
                            Text(languageManager.text(.goalsDeleteFromDetail))
                        }
                    }
                }
            }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(languageManager.text(.goalsDeleteGoalConfirmTitle), isPresented: $showingDeleteConfirm) {
                Button(languageManager.text(.commonCancel), role: .cancel) { }
                Button(languageManager.text(.goalsDeleteSwipe), role: .destructive) {
                    confirmDeleteGoal()
                }
            } message: {
                Text(languageManager.text(.goalsDeleteGoalConfirmMessage))
            }
            .sheet(isPresented: $showingAssetPicker) {
                GoalAssetPickerView(
                    selectedImage: $selectedImage,
                    selectedIcon: $selectedIcon
                )
                .environmentObject(languageManager)
            }
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .add: return languageManager.text(.goalsNavNew)
        case .edit: return languageManager.text(.goalsNavEdit)
        }
    }

    private func saveGoal() {
        attemptedSave = true
        guard isValid, let amount = Double(targetAmount) else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageData = GoalImageEncoding.data(from: selectedImage)

        switch mode {
        case .add:
            for kidId in selectedKidIDs {
                let goal = KidGoal(
                    id: UUID(),
                    kidId: kidId,
                    title: trimmedTitle,
                    targetAmount: amount,
                    imageData: imageData,
                    iconSystemName: selectedIcon,
                    createdAt: Date()
                )
                onSave(goal)
            }
        case .edit(let existing):
            let goal = KidGoal(
                id: existing.id,
                kidId: existing.kidId,
                title: trimmedTitle,
                targetAmount: amount,
                imageData: imageData,
                iconSystemName: selectedIcon,
                createdAt: existing.createdAt
            )
            onSave(goal)
        }
        dismiss()
    }

    private func confirmDeleteGoal() {
        onDelete?()
        dismiss()
    }

    private func sanitizeNumericInput(_ input: String) -> String {
        var result = ""
        var hasDecimalSeparator = false

        for character in input {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !hasDecimalSeparator {
                hasDecimalSeparator = true
                result.append(character)
            }
        }

        return result
    }
}

private struct GoalImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: () -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: GoalImagePicker

        init(parent: GoalImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageSelected()
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private struct GoalAssetPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedImage: UIImage?
    @Binding var selectedIcon: String?
    @State private var selectedTab = 0
    @State private var showingImagePicker = false

    private let icons = [
        "person.fill", "star.fill", "book.fill", "gamecontroller.fill", "figure.run", "paintbrush.fill",
        "soccerball", "music.note", "trophy.fill", "heart.fill", "gift.fill", "graduationcap.fill", "target"
    ]
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.goalsAddPhoto),
                    trailingTitle: languageManager.text(.commonDone),
                    onTrailing: { dismiss() }
                )
                Picker(languageManager.text(.pickerSelection), selection: $selectedTab) {
                    Text(languageManager.text(.iconPickerIcons)).tag(0)
                    Text(languageManager.text(.iconPickerPhotos)).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                    selectedImage = nil
                                    dismiss()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.12))
                                            .frame(width: 58, height: 58)
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundColor(selectedIcon == icon ? .white : .blue)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Spacer()

                        GoalThumbnailView(
                            previewImage: selectedImage,
                            size: 120,
                            cornerRadius: GoalThumbnailMetrics.cornerRadius
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: GoalThumbnailMetrics.cornerRadius, style: .continuous)
                                .stroke(selectedImage != nil ? Color.blue : Color.clear, lineWidth: 3)
                        )

                        Button(selectedImage == nil ? languageManager.text(.iconPickerSelectImage) : languageManager.text(.iconPickerChangeImage)) {
                            showingImagePicker = true
                        }
                        .buttonStyle(.bordered)

                        Spacer()
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingImagePicker) {
                GoalImagePicker(selectedImage: $selectedImage, onImageSelected: {
                    selectedIcon = nil
                })
            }
        }
    }
}

#Preview {
    GoalsView()
        .environmentObject(LanguageManager())
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(GoalsStore())
        .environmentObject(HistoryStore())
}
