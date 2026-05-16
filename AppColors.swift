//
//  AppColors.swift
//  Vecko
//

import SwiftUI
import UIKit

enum AppColors {
    /// Brand green: #14B65B
    static let appGreen = Color(red: 20.0 / 255.0, green: 182.0 / 255.0, blue: 91.0 / 255.0)
    /// Brand red: #E64F59
    static let appRed = Color(red: 230.0 / 255.0, green: 79.0 / 255.0, blue: 89.0 / 255.0)
}

extension Color {
    /// Convenience alias for the app brand green (#14B65B).
    static let appGreen = AppColors.appGreen
    /// Convenience alias for the app brand red (#E64F59).
    static let appRed = AppColors.appRed
}

/// Home allowance credit card — reuse for matching width, corner radius, and shadow.
enum VeckoCreditCardChrome {
    static let cornerRadius: CGFloat = 14
    static let shadowColor = Color.black.opacity(0.4)
    static let shadowRadius: CGFloat = 8
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 4
    /// Matches `HomeView` header stack `.padding()` so the card aligns with the credit card.
    static let horizontalInset: CGFloat = 16
    /// Same as `HomeView.summaryCard` on iPad.
    static let ipadMaxWidth: CGFloat = 450
}

// MARK: - Toolbar / top bar actions (no pill or circle behind text buttons)

enum VeckoToolbarAppearance {
    static func configure() {
        let clear = UIImage()
        let item = UIBarButtonItem.appearance()
        item.setBackgroundImage(clear, for: .normal, barMetrics: .default)
        item.setBackgroundImage(clear, for: .highlighted, barMetrics: .default)
        item.setBackgroundImage(clear, for: .disabled, barMetrics: .default)
        // Do not set `hidesSharedBackground` on `appearance()` — it crashes (only valid on individual items).
    }
}

extension Button {
    /// Plain Save / Cancel / Done / + in navigation bars — no system pill or circle.
    func veckoToolbarActionStyle() -> some View {
        buttonStyle(.borderless)
    }
}

/// Sheet header with plain text actions — avoids iOS 26 toolbar glass circles and label truncation.
struct VeckoPlainSheetBar: View {
    let title: String
    var leadingTitle: String?
    var trailingTitle: String?
    var onLeading: (() -> Void)?
    var onTrailing: (() -> Void)?

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                if let leadingTitle, let onLeading {
                    Button(leadingTitle, action: onLeading)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }

                if let trailingTitle, let onTrailing {
                    Button(trailingTitle, action: onTrailing)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 15)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 8)
                .allowsHitTesting(false)
                .padding(.top, 3)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .padding(.top, 15)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
        .safeAreaPadding(.top, 10)
    }
}

/// Navigation bar toolbar helpers.
enum VeckoToolbar {
    /// Cancel / Save / Done / Close — plain text, full width (do not use `sharedBackgroundVisibility` here; it shrinks each label to “Ca…”).
    @ToolbarContentBuilder
    static func barText<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: () -> Content
    ) -> some ToolbarContent {
        ToolbarItem(placement: placement) {
            content()
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    /// Icon-only bar actions; hides the iOS 26 glass bubble when available.
    @ToolbarContentBuilder
    static func barIcon<Content: View>(
        placement: ToolbarItemPlacement,
        @ViewBuilder content: () -> Content
    ) -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: placement, content: content)
                .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: placement, content: content)
        }
    }
}
