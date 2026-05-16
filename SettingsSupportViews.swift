//
//  SettingsSupportViews.swift
//  Vecko
//

import SwiftUI
import UIKit

// MARK: - Support contact (update before App Store release)

private enum VeckoSupportContact {
    /// Inbox for Help & Support mailto links.
    static let supportEmail = "abashelariprod@gmail.com"
    /// Shown as text; optional marketing or docs site.
    static let websiteDisplay = "https://abashelari.com"

    static var mailtoURL: URL? {
        URL(string: "mailto:\(supportEmail)")
    }

    static var websiteURL: URL? {
        URL(string: websiteDisplay)
    }
}

// MARK: - Help & Support (layout matches reference design)

struct VeckoHelpSupportView: View {
    @EnvironmentObject var languageManager: LanguageManager

    @State private var fullName = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var description = ""
    @State private var showForm = false
    @State private var showError = false
    @State private var alertKind: HelpAlertKind = .none

    private enum HelpAlertKind {
        case none
        case sent
        case mailFailed
    }

    private var allFieldsFilled: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: showForm
                        ? languageManager.text(.settingsSupportNavContact)
                        : languageManager.text(.settingsSupportBackHeaderHelp),
                    trailingTitle: languageManager.text(.commonClose),
                    onTrailing: { dismiss() }
                )

                Group {
                    if showForm {
                        Form {
                            Section(header: Text(languageManager.text(.settingsSupportSectionFullName))) {
                                TextField(languageManager.text(.settingsSupportPlaceholderFullName), text: $fullName)
                            }

                            Section(header: Text(languageManager.text(.settingsSupportSectionYourEmail))) {
                                TextField(languageManager.text(.settingsSupportPlaceholderYourEmail), text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                            }

                            Section(header: Text(languageManager.text(.settingsSupportSectionSubject))) {
                                TextField("", text: $subject)
                                    .onChange(of: subject) { _, newValue in
                                        if newValue.count > 100 {
                                            subject = String(newValue.prefix(100))
                                        }
                                    }
                                HStack {
                                    Spacer()
                                    Text("\(subject.count)/100")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Section(header: Text(languageManager.text(.settingsSupportSectionDescription))) {
                                TextEditor(text: $description)
                                    .frame(height: 120)
                                    .onChange(of: description) { _, newValue in
                                        if newValue.count > 400 {
                                            description = String(newValue.prefix(400))
                                        }
                                    }
                                HStack {
                                    Spacer()
                                    Text("\(description.count)/400")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            if showError && !allFieldsFilled {
                                Section {
                                    Text(languageManager.text(.settingsSupportAllRequired))
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                            }

                            Section {
                                Button {
                                    if allFieldsFilled {
                                        showError = false
                                        sendSupportMail()
                                    } else {
                                        showError = true
                                    }
                                } label: {
                                    Text(languageManager.text(.settingsSupportSend))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(allFieldsFilled ? Color.green : Color.gray)
                                        .cornerRadius(12)
                                }
                                .disabled(!allFieldsFilled)
                            }
                            .listRowBackground(Color.clear)
                        }
                } else {
                    VStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .center, spacing: 32) {
                            VStack(alignment: .center, spacing: 16) {
                                Text(languageManager.text(.settingsSupportIntroTitle))
                                    .font(.title3)
                                    .fontWeight(.bold)

                                Text(languageManager.text(.settingsSupportIntroLine1))
                                    .font(.body)

                                Text(languageManager.text(.settingsSupportIntroLine2))
                                    .font(.body)

                                Text(languageManager.text(.settingsSupportIntroLine3))
                                    .font(.body)

                                Divider()
                                    .padding(.vertical, 8)
                                    .padding(.top, 32)
                                    .padding(.bottom, 32)

                                if let mailURL = VeckoSupportContact.mailtoURL {
                                    HStack(spacing: 0) {
                                        Spacer(minLength: 0)
                                        Text("\(languageManager.text(.settingsSupportEmailLabel)): ")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Link(destination: mailURL) {
                                            Text(VeckoSupportContact.supportEmail)
                                                .font(.subheadline)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }

                                if let webURL = VeckoSupportContact.websiteURL {
                                    HStack(spacing: 0) {
                                        Spacer(minLength: 0)
                                        Text("\(languageManager.text(.settingsSupportWebsiteLabel)): ")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Link(destination: webURL) {
                                            Text(VeckoSupportContact.websiteDisplay)
                                                .font(.subheadline)
                                                .multilineTextAlignment(.center)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }

                                Divider()
                                    .padding(.vertical, 8)
                                    .padding(.top, 32)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)

                            Text(languageManager.text(.settingsSupportOr))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)

                            Button {
                                showForm = true
                            } label: {
                                Text(languageManager.text(.settingsSupportContactForm))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 32)
                            }

                            Text(languageManager.text(.settingsSupportAimRespond))
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.vertical, 32)
                }
            }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .interactiveDismissDisabled(false)
            .alert(helpAlertTitle, isPresented: Binding(
                get: { alertKind != .none },
                set: { if !$0 { alertKind = .none } }
            )) {
                Button(languageManager.text(.commonOK), role: .cancel) {
                    let wasSent = alertKind == .sent
                    alertKind = .none
                    if wasSent {
                        showForm = false
                    }
                }
            } message: {
                Text(helpAlertMessage)
            }
        }
    }

    private var helpAlertTitle: String {
        switch alertKind {
        case .mailFailed:
            return languageManager.text(.settingsSheetHelpTitle)
        case .sent, .none:
            return languageManager.text(.settingsSupportAlertSentTitle)
        }
    }

    private var helpAlertMessage: String {
        switch alertKind {
        case .sent:
            return languageManager.text(.settingsSupportAlertSentMessage)
        case .mailFailed:
            return String(format: languageManager.text(.settingsSupportAlertMailFail), VeckoSupportContact.supportEmail)
        case .none:
            return ""
        }
    }

    private func sendSupportMail() {
        guard allFieldsFilled else {
            showError = true
            return
        }
        showError = false

        let body = """
        From: \(fullName)
        Reply email: \(email)

        \(description)
        """
        guard var components = URLComponents(string: "mailto:\(VeckoSupportContact.supportEmail)") else {
            alertKind = .mailFailed
            return
        }
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        guard let url = components.url else {
            alertKind = .mailFailed
            return
        }
        UIApplication.shared.open(url) { success in
            DispatchQueue.main.async {
                alertKind = success ? .sent : .mailFailed
            }
        }
    }
}

// MARK: - Terms, Privacy & Disclaimer

struct VeckoTermsPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.settingsSheetTermsTitle),
                    trailingTitle: languageManager.text(.commonClose),
                    onTrailing: { dismiss() }
                )
                Picker(selection: $selectedTab) {
                    Text(languageManager.text(.settingsLegalTabTerms)).tag(0)
                    Text(languageManager.text(.settingsLegalTabPrivacy)).tag(1)
                    Text(languageManager.text(.settingsLegalTabDisclaimer)).tag(2)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    Text(contentText)
                        .font(.body)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
        }
    }

    private var contentText: String {
        switch selectedTab {
        case 0: return VeckoLegalEnglish.termsOfUse
        case 1: return VeckoLegalEnglish.privacyPolicy
        default: return VeckoLegalEnglish.disclaimer
        }
    }
}

private enum VeckoLegalEnglish {
    static let termsOfUse = """
    TERMS OF USE

    Last Updated: May 13, 2026

    Welcome to Vecko. These Terms of Use (“Terms”) govern your access to and use of the Vecko mobile application (“App”). By using the App, you agree to these Terms.

    1. ACCEPTANCE OF TERMS
    By downloading, installing, or using Vecko, you acknowledge that you have read and agree to these Terms and our Privacy Policy.

    2. DESCRIPTION OF SERVICE
    Vecko is a family finance helper for tracking kids’ allowances, balances, savings goals, deposits, withdrawals, optional simple monthly interest, activity history, and insights. Features include local data storage, PDF export of your records, optional photos for goals, and interface preferences such as language and dark mode.

    3. NO FINANCIAL OR BANKING SERVICES
    Vecko does not hold money, move real funds, or connect to bank accounts. Balances and amounts shown in the App are informational records you manage yourself. Vecko is not a bank, payment service, or regulated financial institution.

    4. USER ACCOUNTS
    You may use the App without creating an account. Vecko is designed to work primarily with data stored on your device.

    5. ACCEPTABLE USE
    You agree to use the App only for lawful purposes. You agree not to attempt to reverse engineer, interfere with, or misuse the App in a way that could harm its operation or other users’ devices.

    6. INTELLECTUAL PROPERTY
    The App, its design, and related materials are protected by applicable intellectual property laws.

    7. LIMITATION OF LIABILITY
    The App is provided “as is” without warranties of any kind to the maximum extent permitted by law. We are not liable for indirect, incidental, or consequential damages arising from your use of the App.

    8. CHANGES TO TERMS
    We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the updated Terms.

    9. CONTACT
    For questions about these Terms, use Help & Support in the App settings.
    """

    static let privacyPolicy = """
    PRIVACY POLICY

    Last Updated: May 13, 2026

    This Privacy Policy explains how Vecko handles information when you use the App.

    1. LOCAL-FIRST DESIGN
    Vecko stores allowance, goal, transaction, history, and related preferences on your device. There is no sign-in account required to use the core features described in the App.

    2. PHOTOS AND MEDIA
    If you choose to attach photos to goals or kids, those images are stored as part of your local app data on the device.

    3. EXPORT
    When you export data (for example to PDF), files are created locally and shared only through the system share sheet you control.

    4. NOTIFICATIONS
    Vecko does not require push notifications for its core allowance-tracking features. If optional notifications are added in the future, they will be described in the App and system permission prompts.

    5. ANALYTICS AND SALE OF DATA
    Vecko is not designed to sell your personal information. Data you enter stays on your device unless you explicitly export or share it.

    6. CHILDREN AND FAMILIES
    Vecko is intended for parents and guardians managing household allowance information. You are responsible for how you use and supervise the App in your family.

    7. SECURITY
    Protection of your information depends on your device security (passcode, biometrics, backups, and device access). Follow good device security practices.

    8. CHANGES TO THIS POLICY
    We may update this Privacy Policy from time to time. The “Last Updated” date will be revised when material changes are made.

    9. CONTACT
    For privacy questions, contact us through Help & Support in the App settings.
    """

    static let disclaimer = """
    DISCLAIMER

    Last Updated: May 13, 2026

    1. NO WARRANTY
    Vecko is provided “as is” and “as available” without warranties of any kind, to the fullest extent permitted by law.

    2. ACCURACY
    Amounts, schedules, and summaries depend on the information you enter. You are responsible for verifying balances and decisions that affect real money outside the App.

    3. LIMITATION OF LIABILITY
    To the fullest extent permitted by law, Vecko and its developers shall not be liable for indirect, incidental, special, consequential, or punitive damages arising from use of the App.

    4. NOT PROFESSIONAL ADVICE
    Vecko is a personal organization tool and does not provide legal, tax, investment, or financial planning advice.

    5. DEVICE AND BACKUPS
    You are responsible for maintaining backups if you need to preserve your data. Clearing app data or uninstalling the App may remove locally stored information.

    6. ACCEPTANCE
    By using Vecko, you acknowledge that you have read and agree to this Disclaimer.
    """
}

// MARK: - About

private enum AboutAbashelariCopy {
    /// Studio section (unchanged wording).
    static let paragraph1 = "At ABASHELARI, we believe in creating software that makes everyday life simpler, smarter, and more enjoyable. Our mission is to develop innovative digital solutions that blend creativity with technology, offering users tools that are intuitive, reliable, and engaging."

    static let paragraph2 = "Whether it's educational apps, lifestyle tools, or entertainment experiences, ABASHELARI is dedicated to delivering high-quality products that inspire learning, spark curiosity, and bring value to people around the world."

    static let paragraph3 = "Driven by passion and guided by innovation, ABASHELARI is committed to continuous improvement and to building software that connects people with what matters most."
}

struct VeckoAboutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager

    private var versionString: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return String(format: languageManager.text(.settingsAboutVersionFormat), short, build)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.settingsAboutTitle),
                    trailingTitle: languageManager.text(.commonClose),
                    onTrailing: { dismiss() }
                )
                ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(languageManager.text(.settingsSheetAboutTitle))
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(languageManager.text(.settingsAboutBody))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }

                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("About ABASHELARI")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(AboutAbashelariCopy.paragraph1)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Text(AboutAbashelariCopy.paragraph2)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Text(AboutAbashelariCopy.paragraph3)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }

                    Text(versionString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
