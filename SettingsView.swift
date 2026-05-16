//
//  SettingsView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-24.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("home.selectedKidID") private var homeSelectedKidIDRaw: String = ""
    @AppStorage("welcome.dontShowAgain") private var dontShowWelcome = false
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var goalsStore: GoalsStore
    @EnvironmentObject var activityStore: ActivityStore
    @EnvironmentObject var historyStore: HistoryStore

    @State private var showingCurrency = false
    @State private var showingLanguage = false
    @State private var showingHelpSupport = false
    @State private var showingTermsPrivacy = false
    @State private var showingAbout = false
    @State private var showingExportAlert = false
    @State private var exportAlertMessage = ""
    @State private var showingClearDataAlert = false
    @State private var showingDeleteTypingPrompt = false
    @State private var deleteConfirmationText = ""
    @State private var exportFileURL: URL?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageHeader

                Form {
                    Section {
                        EmptyView()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    Section(languageManager.text(.settingsSectionPreferences)) {
                        settingsButtonRow(
                            icon: "dollarsign.circle.fill",
                            iconColor: .green,
                            title: languageManager.text(.settingsCurrencyTitle),
                            subtitle: languageManager.text(.settingsCurrencySubtitle),
                            trailingText: "\(currencyManager.flagForCurrency(currencyManager.defaultCurrency)) \(currencyManager.defaultCurrency)"
                        ) {
                            showingCurrency = true
                        }

                        settingsButtonRow(
                            icon: "globe",
                            iconColor: .blue,
                            title: languageManager.text(.settingsLanguageTitle),
                            subtitle: languageManager.text(.settingsLanguageSubtitle),
                            trailingText: "\(languageManager.language.flagEmoji) \(languageManager.language.nativeName)"
                        ) {
                            showingLanguage = true
                        }

                        HStack(spacing: 12) {
                            Image(systemName: "moon.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.text(.settingsDarkModeTitle))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(languageManager.text(.settingsDarkModeSubtitle))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                                .scaleEffect(0.72, anchor: .trailing)
                        }
                    }

                    Section(languageManager.text(.settingsSectionData)) {
                        settingsButtonRow(
                            icon: "square.and.arrow.up.fill",
                            iconColor: .blue,
                            title: languageManager.text(.settingsExportTitle),
                            subtitle: languageManager.text(.settingsExportSubtitle),
                            trailingText: nil
                        ) {
                            exportDataToPDF()
                        }

                        settingsButtonRow(
                            icon: "trash.fill",
                            iconColor: .red,
                            title: languageManager.text(.settingsClearTitle),
                            subtitle: languageManager.text(.settingsClearSubtitle),
                            trailingText: nil,
                            titleColor: .red
                        ) {
                            showingClearDataAlert = true
                        }
                    }

                    Section(languageManager.text(.settingsSectionSupport)) {
                        settingsButtonRow(
                            icon: "questionmark.circle.fill",
                            iconColor: .blue,
                            title: languageManager.text(.settingsHelpTitle),
                            subtitle: languageManager.text(.settingsHelpSubtitle),
                            trailingText: nil
                        ) {
                            showingHelpSupport = true
                        }

                        settingsButtonRow(
                            icon: "lock.shield.fill",
                            iconColor: .green,
                            title: languageManager.text(.settingsTermsTitle),
                            subtitle: languageManager.text(.settingsTermsSubtitle),
                            trailingText: nil
                        ) {
                            showingTermsPrivacy = true
                        }

                        settingsButtonRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: languageManager.text(.settingsAboutTitle),
                            subtitle: languageManager.text(.settingsAboutSubtitle),
                            trailingText: nil
                        ) {
                            showingAbout = true
                        }
                    }

                    Section {
                        Text("")
                            .frame(height: 30)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCurrency) {
                CurrencyPickerView(selectedCurrency: $currencyManager.defaultCurrency)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingLanguage) {
                LanguagePickerView()
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingHelpSupport) {
                VeckoHelpSupportView()
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingTermsPrivacy) {
                VeckoTermsPrivacyView()
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingAbout) {
                VeckoAboutView()
                    .environmentObject(languageManager)
            }
            .sheet(
                isPresented: Binding(
                    get: { exportFileURL != nil },
                    set: { if !$0 { exportFileURL = nil } }
                )
            ) {
                if let exportFileURL {
                    ShareSheet(activityItems: [exportFileURL])
                }
            }
            .alert(languageManager.text(.settingsExportAlertTitle), isPresented: $showingExportAlert) {
                Button(languageManager.text(.commonOK), role: .cancel) { }
            } message: {
                Text(exportAlertMessage)
            }
            .alert("Are you sure? all data will be deleted, this cannot be undone!", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    deleteConfirmationText = ""
                    showingDeleteTypingPrompt = true
                }
            } message: {
                Text("")
            }
            .alert("Type \"Delete\" to complete this action", isPresented: $showingDeleteTypingPrompt) {
                TextField("Delete", text: $deleteConfirmationText)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                Button("Cancel", role: .cancel) { }
                Button("Done") {
                    guard isDeleteConfirmationValid else { return }
                    clearAllData()
                }
                .disabled(!isDeleteConfirmationValid)
            } message: {
                Text("")
            }
        }
    }

    private var isDeleteConfirmationValid: Bool {
        deleteConfirmationText.compare("delete", options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }

    private func exportDataToPDF() {
        do {
            let data = try buildExportPDFData()
            let fileName = "Vecko_Export_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).pdf"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: url, options: .atomic)
            exportFileURL = url
        } catch {
            exportAlertMessage = "Failed to export PDF: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }

    private func buildExportPDFData() throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4-ish
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)

        var currentY: CGFloat = 40
        let leftMargin: CGFloat = 30
        let rightMargin: CGFloat = 30
        let maxY: CGFloat = pageRect.height - 40

        func startPage() {
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            currentY = 40
        }

        func drawText(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 8) {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]
            let width = pageRect.width - leftMargin - rightMargin
            let bounds = (text as NSString).boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            )
            if currentY + bounds.height > maxY {
                startPage()
            }
            (text as NSString).draw(
                in: CGRect(x: leftMargin, y: currentY, width: width, height: ceil(bounds.height)),
                withAttributes: attrs
            )
            currentY += ceil(bounds.height) + spacingAfter
        }

        let titleBlue = UIColor.systemBlue

        startPage()
        drawText("Vecko Export", font: .boldSystemFont(ofSize: 24), color: titleBlue, spacingAfter: 4)
        drawText("Generated: \(Date().formatted(date: .abbreviated, time: .shortened))", font: .systemFont(ofSize: 12), color: .darkGray, spacingAfter: 16)

        // Family section
        drawText("Kids (\(familyStore.kids.count))", font: .boldSystemFont(ofSize: 16), color: titleBlue, spacingAfter: 6)
        if familyStore.kids.isEmpty {
            drawText("No kids.", font: .systemFont(ofSize: 12), color: .darkGray, spacingAfter: 12)
        } else {
            for kid in familyStore.kids {
                let line = "• \(kid.name) | Balance: \(currencyManager.formatAmount(kid.currentBalance)) | Allowance: \(currencyManager.formatAmount(kid.weeklyAllowance)) | Interest: \(kid.monthlyInterestPercent)%"
                drawText(line, font: .systemFont(ofSize: 12), spacingAfter: 4)
            }
            currentY += 8
        }

        // Goals section
        drawText("Goals (\(goalsStore.goals.count))", font: .boldSystemFont(ofSize: 16), color: titleBlue, spacingAfter: 6)
        if goalsStore.goals.isEmpty {
            drawText("No goals.", font: .systemFont(ofSize: 12), color: .darkGray, spacingAfter: 12)
        } else {
            for goal in goalsStore.goals {
                let kid = familyStore.kids.first(where: { $0.id == goal.kidId })
                let kidName = kid?.name ?? languageManager.text(.unknownKid)
                let balance = max(0, kid?.currentBalance ?? 0)
                let progress: Double = goal.targetAmount > 0 ? min(1, balance / goal.targetAmount) : 0
                let percent = Int((progress * 100).rounded())
                let percentLabel = String(
                    format: languageManager.text(.goalsPercentCompleteFormat),
                    locale: languageManager.locale,
                    arguments: [percent]
                )
                let line = "• \(goal.title) | Kid: \(kidName) | Target: \(currencyManager.formatAmount(goal.targetAmount)) | \(percentLabel)"
                drawText(line, font: .systemFont(ofSize: 12), spacingAfter: 4)
            }
            currentY += 8
        }

        // Activity section
        drawText("Transactions (\(activityStore.transactions.count))", font: .boldSystemFont(ofSize: 16), color: titleBlue, spacingAfter: 6)
        if activityStore.transactions.isEmpty {
            drawText("No transactions.", font: .systemFont(ofSize: 12), color: .darkGray, spacingAfter: 12)
        } else {
            for tx in activityStore.transactions.sorted(by: { $0.date > $1.date }).prefix(200) {
                let sign = tx.isDeposit ? "+" : "-"
                let line = "• \(tx.kidName) | \(sign)\(currencyManager.formatAmount(tx.amount)) | \(tx.note) | \(tx.date.formatted(date: .abbreviated, time: .shortened))"
                drawText(line, font: .systemFont(ofSize: 12), spacingAfter: 4)
            }
            currentY += 8
        }

        // History section
        drawText("History (\(historyStore.entries.count))", font: .boldSystemFont(ofSize: 16), color: titleBlue, spacingAfter: 6)
        if historyStore.entries.isEmpty {
            drawText("No history.", font: .systemFont(ofSize: 12), color: .darkGray, spacingAfter: 12)
        } else {
            for entry in historyStore.entries.prefix(200) {
                let line = "• \(entry.title) — \(entry.detail) | \(entry.date.formatted(date: .abbreviated, time: .shortened))"
                drawText(line, font: .systemFont(ofSize: 12), spacingAfter: 4)
            }
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }

    private func clearAllData() {
        familyStore.clearAllKids()
        goalsStore.clearAllGoals()
        activityStore.clearAllTransactions()
        historyStore.clearAllHistory()
        homeSelectedKidIDRaw = ""
        dontShowWelcome = false
    }

    private var pageHeader: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.settingsTitle))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(languageManager.text(.settingsSubtitle))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 6)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func settingsButtonRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        trailingText: String?,
        titleColor: Color = .primary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(titleColor)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer()

                if let trailingText {
                    Text(trailingText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct LanguagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.languagePickerTitle),
                    trailingTitle: languageManager.text(.commonDone),
                    onTrailing: { dismiss() }
                )
                ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                List {
                    Section {
                        ForEach(AppLanguage.pickerOrder) { language in
                            Button {
                                languageManager.setLanguage(language)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(language.flagEmoji)
                                        .font(.title3)

                                    Text(language.nativeName)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    if language == languageManager.language {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                            .font(.body.weight(.semibold))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .scrollContentBackground(.hidden)
            }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(CurrencyManager())
        .environmentObject(LanguageManager())
        .environmentObject(FamilyStore())
        .environmentObject(GoalsStore())
        .environmentObject(ActivityStore())
        .environmentObject(HistoryStore())
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
