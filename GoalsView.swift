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

struct GoalsView: View {
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var goalsStore: GoalsStore
    @EnvironmentObject var historyStore: HistoryStore
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var showingAddGoal = false
    @State private var editingGoal: KidGoal?
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
        NavigationStack {
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
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .padding(10)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 6)
                .padding(.trailing, 16)
                .disabled(kids.isEmpty)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(mode: .add(defaultKidId: selectedKid?.id)) { goal in
                    goalsStore.addGoal(goal)
                    let kidName = familyStore.kids.first(where: { $0.id == goal.kidId })?.name ?? languageManager.text(.unknownKid)
                    historyStore.recordGoalAdded(kidId: goal.kidId, kidName: kidName, goalTitle: goal.title, targetAmount: goal.targetAmount)
                }
                .environmentObject(familyStore)
                .environmentObject(currencyManager)
                .environmentObject(languageManager)
            }
            .sheet(item: $editingGoal) { goal in
                AddGoalView(mode: .edit(goal)) { updated in
                    goalsStore.updateGoal(updated)
                }
                .environmentObject(familyStore)
                .environmentObject(currencyManager)
                .environmentObject(languageManager)
            }
        }
        .onAppear {
            syncSelectedKid()
        }
        .onChange(of: kids.map(\.id)) { _, _ in
            syncSelectedKid()
        }
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
                        .background(selectedKidID == nil ? Color.blue.opacity(0.18) : Color(.secondarySystemBackground))
                        .foregroundStyle(selectedKidID == nil ? Color.blue : Color.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                ForEach(kids) { kid in
                    Button {
                        selectedKidID = kid.id
                    } label: {
                        Text(kid.name)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedKidID == kid.id ? Color.blue.opacity(0.18) : Color(.secondarySystemBackground))
                            .foregroundStyle(selectedKidID == kid.id ? Color.blue : Color.primary)
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

    private var goalsContent: some View {
        Group {
            if visibleGoals.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "target")
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    Text(languageManager.text(.goalsNoGoalsTitle))
                        .font(.headline)
                    Text(languageManager.text(.goalsNoGoalsSubtitle))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Color.appGreen)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(visibleGoals) { goal in
                            GoalRowView(goal: goal, kid: kid(for: goal.kidId))
                                .onTapGesture {
                                    editingGoal = goal
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        goalsStore.removeGoal(id: goal.id)
                                    } label: {
                                        Label(languageManager.text(.goalsDeleteSwipe), systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                    .padding(.bottom, 70)
                }
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

private struct GoalRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let goal: KidGoal
    let kid: FamilyKid?

    private var progress: Double {
        let balance = max(0, kid?.currentBalance ?? 0)
        guard goal.targetAmount > 0 else { return 0 }
        return min(1, balance / goal.targetAmount)
    }

    var body: some View {
        HStack(spacing: 14) {
            if let data = goal.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if let icon = goal.iconSystemName {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 84, height: 84)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(.blue)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 84, height: 84)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(goal.title)
                    .font(.headline)
                    .lineLimit(1)

                ProgressView(value: progress)
                    .tint(progress >= 1 ? .green : .blue)

                HStack {
                    Text(String(format: languageManager.text(.goalsPercentCompleteFormat), locale: languageManager.locale, arguments: [Int((progress * 100).rounded())]))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(currencyManager.formatAmount(kid?.currentBalance ?? 0) + " / " + currencyManager.formatAmount(goal.targetAmount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color(.systemGray4) : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
    }
}

private struct AddGoalView: View {
    enum Mode {
        case add(defaultKidId: UUID?)
        case edit(KidGoal)
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager

    let mode: Mode
    let onSave: (KidGoal) -> Void

    @State private var selectedKidId: UUID?
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var selectedImage: UIImage?
    @State private var selectedIcon: String?
    @State private var showingAssetPicker = false
    @State private var attemptedSave = false

    private var kids: [FamilyKid] { familyStore.kids }

    private var isTitleValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isAmountValid: Bool {
        (Double(targetAmount) ?? 0) > 0
    }

    private var isKidValid: Bool {
        selectedKidId != nil
    }

    private var isVisualValid: Bool {
        selectedImage != nil || selectedIcon != nil
    }

    private var isValid: Bool {
        isTitleValid && isAmountValid && isKidValid && isVisualValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(languageManager.text(.goalsSectionGoal)) {
                    Picker(languageManager.text(.goalsPickerKid), selection: $selectedKidId) {
                        ForEach(kids) { kid in
                            Text(kid.name).tag(Optional(kid.id))
                        }
                    }
                    .tint(attemptedSave && !isKidValid ? .red : .blue)

                    TextField(
                        "",
                        text: $title,
                        prompt: Text(attemptedSave && !isTitleValid ? languageManager.text(.goalsGoalTitleRequired) : languageManager.text(.goalsGoalTitlePlaceholder))
                            .foregroundColor(attemptedSave && !isTitleValid ? .red : .secondary)
                    )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(currencyManager.getCurrencySymbol())
                            .foregroundStyle(attemptedSave && !isAmountValid ? .red : .secondary)
                        TextField(
                            "",
                            text: $targetAmount,
                            prompt: Text(attemptedSave && !isAmountValid ? languageManager.text(.goalsTargetRequired) : languageManager.text(.goalsTargetPlaceholder))
                                .foregroundColor(attemptedSave && !isAmountValid ? .red : .secondary)
                        )
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(.primary)
                            .onChange(of: targetAmount) { _, newValue in
                                targetAmount = sanitizeNumericInput(newValue)
                            }
                    }
                }

                Section(languageManager.text(.goalsSectionPhoto)) {
                    HStack(spacing: 12) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if let selectedIcon {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: selectedIcon)
                                        .foregroundStyle(.blue)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundStyle(.blue)
                                )
                        }

                        Button(attemptedSave && !isVisualValid ? languageManager.text(.goalsPhotoRequired) : languageManager.text(.goalsAddPhoto)) {
                            showingAssetPicker = true
                        }
                        .foregroundStyle(attemptedSave && !isVisualValid ? .red : .blue)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(languageManager.text(.commonCancel)) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(languageManager.text(.commonSave)) { saveGoal() }
                }
            }
            .onAppear {
                switch mode {
                case .add(let defaultKidId):
                    if let defaultKidId, kids.contains(where: { $0.id == defaultKidId }) {
                        selectedKidId = defaultKidId
                    } else {
                        selectedKidId = kids.first?.id
                    }
                case .edit(let goal):
                    selectedKidId = kids.contains(where: { $0.id == goal.kidId }) ? goal.kidId : kids.first?.id
                    title = goal.title
                    targetAmount = String(format: "%.2f", goal.targetAmount)
                    selectedIcon = goal.iconSystemName
                    if let data = goal.imageData {
                        selectedImage = UIImage(data: data)
                    }
                }
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
        guard let selectedKidId, let amount = Double(targetAmount), amount > 0 else { return }
        guard selectedImage != nil || selectedIcon != nil else { return }
        let id: UUID
        let createdAt: Date
        switch mode {
        case .add:
            id = UUID()
            createdAt = Date()
        case .edit(let existing):
            id = existing.id
            createdAt = existing.createdAt
        }
        let goal = KidGoal(
            id: id,
            kidId: selectedKidId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: amount,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            iconSystemName: selectedIcon,
            createdAt: createdAt
        )
        onSave(goal)
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
        NavigationView {
            VStack(spacing: 0) {
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

                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue, lineWidth: 3))
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 58))
                                .foregroundColor(.gray)
                        }

                        Button(selectedImage == nil ? languageManager.text(.iconPickerSelectImage) : languageManager.text(.iconPickerChangeImage)) {
                            showingImagePicker = true
                        }
                        .buttonStyle(.bordered)

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(languageManager.text(.goalsAddPhoto))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.text(.commonDone)) {
                        dismiss()
                    }
                }
            }
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
