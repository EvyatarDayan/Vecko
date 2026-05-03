//
//  LanguageManager.swift
//  Vecko
//

import Combine
import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case swedish = "sv"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"

    var id: String { rawValue }

    /// Order for the language picker: Swedish first (product requirement), then the rest.
    static var pickerOrder: [AppLanguage] {
        [.swedish, .english, .spanish, .french, .german]
    }

    var localeIdentifier: String {
        switch self {
        case .english: return "en_US"
        case .swedish: return "sv_SE"
        case .spanish: return "es_ES"
        case .french: return "fr_FR"
        case .german: return "de_DE"
        }
    }

    var locale: Locale { Locale(identifier: localeIdentifier) }

    var flagEmoji: String {
        switch self {
        case .english: return "🇺🇸"
        case .swedish: return "🇸🇪"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        }
    }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .swedish: return "Svenska"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        }
    }

    private static let storageKey = "app.language"

    static var stored: AppLanguage {
        guard let raw = UserDefaults.standard.string(forKey: storageKey) else {
            return .swedish
        }
        return AppLanguage(rawValue: raw) ?? .swedish
    }

    func persist() {
        UserDefaults.standard.set(rawValue, forKey: Self.storageKey)
    }
}

final class LanguageManager: ObservableObject {
    @Published private(set) var language: AppLanguage

    init(language: AppLanguage = .stored) {
        self.language = language
    }

    var locale: Locale { language.locale }

    func setLanguage(_ newValue: AppLanguage) {
        guard newValue != language else { return }
        language = newValue
        newValue.persist()
        objectWillChange.send()
    }

    func text(_ key: AppStringKey) -> String {
        AppStringCatalog.string(key, language: language)
    }
}
