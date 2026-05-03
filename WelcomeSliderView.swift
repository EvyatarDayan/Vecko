//
//  WelcomeSliderView.swift
//  Vecko
//

import SwiftUI

struct WelcomeSliderView: View {
    struct Slide: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let icon: String
    }

    let onDone: (Bool) -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @State private var currentIndex = 0
    @State private var dontShowAgain = false

    private var slides: [Slide] {
        [
            Slide(
                id: 0,
                title: languageManager.text(.welcomeTitle1),
                subtitle: languageManager.text(.welcomeSubtitle1),
                icon: "hand.wave.fill"
            ),
            Slide(
                id: 1,
                title: languageManager.text(.welcomeTitle2),
                subtitle: languageManager.text(.welcomeSubtitle2),
                icon: "calendar.badge.plus"
            ),
            Slide(
                id: 2,
                title: languageManager.text(.welcomeTitle3),
                subtitle: languageManager.text(.welcomeSubtitle3),
                icon: "chart.line.uptrend.xyaxis"
            ),
            Slide(
                id: 3,
                title: languageManager.text(.welcomeTitle4),
                subtitle: languageManager.text(.welcomeSubtitle4),
                icon: "target"
            ),
            Slide(
                id: 4,
                title: languageManager.text(.welcomeTitle5),
                subtitle: languageManager.text(.welcomeSubtitle5),
                icon: "chart.pie.fill"
            )
        ]
    }

    var body: some View {
        ZStack {
            Color.appGreen
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top section: app icon
                VStack {
                    Spacer()
                    Image("kidIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Center section: slide content
                TabView(selection: $currentIndex) {
                    ForEach(slides) { slide in
                        VStack(spacing: 14) {
                            Image(systemName: slide.icon)
                                .font(.system(size: 46, weight: .semibold))
                                .foregroundColor(.white)

                            Text(slide.title)
                                .font(.system(size: 34, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)

                            Text(slide.subtitle)
                                .font(.system(size: 21, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.95))
                                .padding(.horizontal, 30)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom section: checkbox, dots, and action button
                VStack(spacing: 14) {
                    Button {
                        dontShowAgain.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            Text(languageManager.text(.welcomeDontShowAgain))
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.white)
                        .opacity(currentIndex == slides.count - 1 ? 1 : 0)
                    }
                    .buttonStyle(.plain)
                    .disabled(currentIndex != slides.count - 1)

                    HStack(spacing: 8) {
                        ForEach(slides.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }

                    Button {
                        if currentIndex < slides.count - 1 {
                            withAnimation(.easeInOut) {
                                currentIndex += 1
                            }
                        } else {
                            onDone(dontShowAgain)
                        }
                    } label: {
                        Text(currentIndex < slides.count - 1 ? languageManager.text(.welcomeNext) : languageManager.text(.welcomeGetStarted))
                            .font(.headline)
                            .foregroundColor(Color.appGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    WelcomeSliderView { _ in }
        .environmentObject(LanguageManager())
}
