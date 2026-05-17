//
//  ContentView.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var languageManager: LanguageManager
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("welcome.dontShowAgain") private var dontShowWelcome = false
    @State private var selectedTab: Int = 2
    @State private var showWelcome = false
    @State private var didEvaluateWelcome = false
    @State private var didSetInitialTab = false
    @StateObject private var familyStore = FamilyStore()
    @StateObject private var activityStore = ActivityStore()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var goalsStore = GoalsStore()
    private let processingTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    private let menuHeight: CGFloat = 40
    private let menuButtonSpacing: CGFloat = -40

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case 0:
                            InsightsView()
                        case 1:
                            FamilyView()
                        case 2:
                            HomeView()
                        case 3:
                            GoalsView()
                        case 4:
                            SettingsView()
                        default:
                            HomeView()
                        }
                    }
                    .environmentObject(familyStore)
                    .environmentObject(activityStore)
                    .environmentObject(historyStore)
                    .environmentObject(goalsStore)
                    .frame(width: geometry.size.width, height: geometry.size.height - menuHeight)
                    .clipped()

                    ZStack(alignment: .bottom) {
                        VStack(spacing: 0) {
                            UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 20)
                                .fill(Color(.systemBackground))
                                .frame(width: geometry.size.width, height: menuHeight)
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -3)

                            Rectangle()
                                .fill(Color(.systemBackground))
                                .frame(width: geometry.size.width)
                                .frame(height: geometry.safeAreaInsets.bottom)
                        }

                        HStack(spacing: menuButtonSpacing) {
                            TabBarButton(
                                icon: "square.grid.2x2.fill",
                                label: languageManager.text(.tabInsights),
                                isSelected: selectedTab == 0,
                                action: { selectedTab = 0 }
                            )

                            TabBarButton(
                                icon: "clock.arrow.circlepath",
                                label: languageManager.text(.tabFamily),
                                isSelected: selectedTab == 1,
                                action: { selectedTab = 1 }
                            )

                            TabBarButton(
                                icon: "house.fill",
                                label: languageManager.text(.tabHome),
                                isSelected: selectedTab == 2,
                                action: { selectedTab = 2 }
                            )

                            TabBarButton(
                                icon: "target",
                                label: languageManager.text(.tabGoals),
                                isSelected: selectedTab == 3,
                                action: { selectedTab = 3 }
                            )

                            TabBarButton(
                                icon: "gearshape.fill",
                                label: languageManager.text(.tabSettings),
                                isSelected: selectedTab == 4,
                                action: { selectedTab = 4 }
                            )
                        }
                        .frame(width: geometry.size.width, height: menuHeight)
                    }
                    .zIndex(1)
                }
            }
        }
        .onAppear {
            if !didSetInitialTab {
                selectedTab = familyStore.kids.isEmpty ? 1 : 2
                didSetInitialTab = true
            }
            if !didEvaluateWelcome {
                didEvaluateWelcome = true
                showWelcome = !dontShowWelcome
            }
            processAutomations()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                processAutomations()
            }
        }
        .onReceive(processingTimer) { _ in
            guard scenePhase == .active else { return }
            processAutomations()
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeSliderView { dontShowAgain in
                dontShowWelcome = dontShowAgain
                showWelcome = false
            }
            .environmentObject(languageManager)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func processAutomations() {
        familyStore.processScheduledAllowanceIfNeeded(activityStore: activityStore, historyStore: historyStore)
        familyStore.processMonthlyInterestIfNeeded(activityStore: activityStore, historyStore: historyStore)
    }
}

private struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)

                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -30)
            .padding(.bottom, 6)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(true)
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .environmentObject(CurrencyManager())
        .environmentObject(LanguageManager())
}
