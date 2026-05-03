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
