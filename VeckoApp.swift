//
//  VeckoApp.swift
//  Vecko
//
//  Created by EVYATAR DAYAN on 2026-04-24.
//

import SwiftUI

@main
struct VeckoApp: App {
    @StateObject private var currencyManager = CurrencyManager()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(currencyManager)
                .environmentObject(languageManager)
        }
    }
}
