//
//  HomeView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-25.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var familyStore: FamilyStore
    @EnvironmentObject var languageManager: LanguageManager

    @AppStorage("home.selectedKidID") private var selectedKidIDRaw: String = ""
    @State private var cardFlipAngle: Double = 0

    private var kids: [KidAllowance] {
        familyStore.kids.map(KidAllowance.init(from:))
    }

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private var selectedKid: KidAllowance? {
        if let selectedKidID, let matchedKid = kids.first(where: { $0.id == selectedKidID }) {
            return matchedKid
        }
        return kids.first
    }

    private var selectedKidID: UUID? {
        UUID(uuidString: selectedKidIDRaw)
    }

    private var familyTotalBalance: Double {
        kids.reduce(0) { $0 + $1.currentBalance }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    headerSection
                    summaryCard
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                if kids.isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                } else {
                    kidsListSection
                        .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            syncSelectionIfNeeded()
            triggerCardEntranceAnimation()
        }
        .onChange(of: familyStore.kids.map(\.id)) { _, _ in
            syncSelectionIfNeeded()
        }
        .onChange(of: selectedKidIDRaw) { _, _ in
            triggerCardEntranceAnimation()
        }
    }

    private func syncSelectionIfNeeded() {
        let ids = Set(kids.map(\.id))
        if let selectedKidID, ids.contains(selectedKidID) {
            return
        }
        persistSelectedKidID(kids.first?.id)
    }

    private func persistSelectedKidID(_ id: UUID?) {
        selectedKidIDRaw = id?.uuidString ?? ""
    }

    private func triggerCardEntranceAnimation() {
        cardFlipAngle = -90
        withAnimation(.easeInOut(duration: 0.45)) {
            cardFlipAngle = 0
        }
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(languageManager.text(.homeFamilyOverview))
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(String(format: languageManager.text(.homeKidsCountFormat), locale: languageManager.locale, arguments: [kids.count]))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(selectedKid?.name ?? languageManager.text(.homeNoKidSelected))
                        .font(.system(size: isIPad ? 12 : 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))

                    Text(languageManager.text(.homeAllowanceCard))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.bottom, 10)
                }

                Spacer()

                Image("wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }

            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 2) {
                    Text(balanceTitle)
                        .font(.system(size: isIPad ? 22 : 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))

                    Text(currencyManager.formatAmount(selectedKid?.currentBalance ?? 0))
                        .font(.system(size: isIPad ? 42 : 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 10)

            Text("**** **** **** \(selectedKid?.cardLast4 ?? "0000")")
                .font(.system(size: isIPad ? 16 : 12, weight: .medium, design: .monospaced))
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 6)

            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(allowanceFrequencyTitle)
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))

                    Text(currencyManager.formatAmount(selectedKid?.weeklyAllowance ?? 0))
                        .font(.system(size: isIPad ? 12 : 10, weight: .semibold))
                        .foregroundColor(.black)
                }

                Spacer()

                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: -5)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(languageManager.text(.homeCardBrand))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black)
                        .offset(x: -2)
                }
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, isIPad ? 20 : 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.6, blue: 0.2),
                    Color(red: 0.9, green: 0.7, blue: 0.3),
                    Color(red: 0.7, green: 0.5, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .overlay(alignment: .top) {
            cardPhotoOverlay
                .allowsHitTesting(false)
        }
        .frame(maxWidth: isIPad ? 450 : .infinity)
        .rotation3DEffect(
            .degrees(cardFlipAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.7
        )
        .opacity(abs(cardFlipAngle) > 80 ? 0 : 1)
    }

    @ViewBuilder
    private var cardPhotoOverlay: some View {
        if let data = selectedKid?.customImageData, let uiImage = UIImage(data: data) {
            VStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isIPad ? 180 : 180, height: isIPad ? 180 : 180)
                    .clipShape(Circle())
                    .opacity(0.1)
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity)
        }
    }

    private var kidsListSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text(languageManager.text(.homeTotalBalance))
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(currencyManager.formatAmount(familyTotalBalance))
                        .font(.headline)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(.systemGroupedBackground))

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(kids) { kid in
                        KidAllowanceRowView(
                            kid: kid,
                            isSelected: selectedKidID == kid.id
                        )
                        .onTapGesture {
                            persistSelectedKidID(kid.id)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 70)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text(languageManager.text(.homeNoKidsTitle))
                .font(.headline)
            Text(languageManager.text(.homeNoKidsSubtitleFamily))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var balanceTitle: String {
        if let name = selectedKid?.name, !name.isEmpty {
            return String(format: languageManager.text(.homeBalanceNamedFormat), locale: languageManager.locale, arguments: [name])
        }
        return languageManager.text(.homeCurrentBalance)
    }

}

private struct KidAllowance: Identifiable {
    let id: UUID
    let name: String
    let weeklyAllowance: Double
    let depositFrequency: DepositFrequency
    let currentBalance: Double
    let icon: String
    let cardLast4: String
    let customImageData: Data?

    init(from kid: FamilyKid) {
        self.id = kid.id
        self.name = kid.name
        self.weeklyAllowance = kid.weeklyAllowance
        self.depositFrequency = kid.depositFrequency
        self.currentBalance = kid.currentBalance
        self.icon = kid.icon
        self.cardLast4 = KidAllowance.last4Digits(from: kid.id)
        self.customImageData = kid.customImageData
    }

    private static func last4Digits(from id: UUID) -> String {
        let digits = id.uuidString.filter(\.isNumber)
        if digits.count >= 4 {
            return String(digits.suffix(4))
        }
        return "0000"
    }
}

private struct KidAllowanceRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let kid: KidAllowance
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            if let data = kid.customImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: kid.icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(kid.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(
                    String(
                        format: languageManager.text(.allowanceLineFormat),
                        locale: languageManager.locale,
                        arguments: [
                            AppStringCatalog.displayDepositFrequency(kid.depositFrequency, language: languageManager.language),
                            currencyManager.formatAmount(kid.weeklyAllowance)
                        ]
                    )
                )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currencyManager.formatAmount(kid.currentBalance))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(kid.currentBalance < 0 ? .appRed : .appGreen)

                Text(languageManager.text(.homeCurrent))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            isSelected
            ? Color.appGreen.opacity(colorScheme == .dark ? 0.2 : 0.1)
            : (colorScheme == .dark ? Color(.systemGray6) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected
                    ? Color.appGreen.opacity(0.6)
                    : (colorScheme == .dark ? Color(.systemGray4) : Color.clear),
                    lineWidth: 1
                )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }

    private var iconColor: Color {
        switch kid.name.lowercased() {
        case "noa":
            return .pink
        case "liam":
            return .blue
        case "maya":
            return .purple
        case "daniel":
            return .green
        default:
            return .gray
        }
    }
}

private extension HomeView {
    var allowanceFrequencyTitle: String {
        let frequency = selectedKid?.depositFrequency ?? .weekly
        return AppStringCatalog.displayDepositFrequency(frequency, language: languageManager.language)
    }
}

#Preview {
    HomeView()
        .environmentObject(CurrencyManager())
        .environmentObject(FamilyStore())
        .environmentObject(LanguageManager())
}
