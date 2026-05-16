import Foundation
import SwiftUI
import Combine

final class CurrencyManager: ObservableObject {
    @Published var defaultCurrency: String {
        didSet {
            UserDefaults.standard.set(defaultCurrency, forKey: "defaultCurrency")
        }
    }

    init() {
        self.defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "SEK"
    }

    func getCurrencySymbol() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = defaultCurrency
        return formatter.currencySymbol ?? defaultCurrency
    }

    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.groupingSize = 3
        formatter.secondaryGroupingSize = 3
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let numberText = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        return "\(numberText) \(defaultCurrency)"
    }

    func flagForCurrency(_ currency: String) -> String {
        switch currency {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "GBP": return "🇬🇧"
        case "JPY": return "🇯🇵"
        case "CAD": return "🇨🇦"
        case "AUD": return "🇦🇺"
        case "CHF": return "🇨🇭"
        case "CNY": return "🇨🇳"
        case "SEK": return "🇸🇪"
        case "NZD": return "🇳🇿"
        case "MXN": return "🇲🇽"
        case "SGD": return "🇸🇬"
        case "HKD": return "🇭🇰"
        case "NOK": return "🇳🇴"
        case "KRW": return "🇰🇷"
        case "TRY": return "🇹🇷"
        case "RUB": return "🇷🇺"
        case "INR": return "🇮🇳"
        case "BRL": return "🇧🇷"
        case "ZAR": return "🇿🇦"
        case "ILS": return "🇮🇱"
        case "AED": return "🇦🇪"
        case "SAR": return "🇸🇦"
        case "PLN": return "🇵🇱"
        case "THB": return "🇹🇭"
        case "IDR": return "🇮🇩"
        case "CZK": return "🇨🇿"
        case "HUF": return "🇭🇺"
        case "CLP": return "🇨🇱"
        case "PHP": return "🇵🇭"
        case "MYR": return "🇲🇾"
        case "COP": return "🇨🇴"
        case "RON": return "🇷🇴"
        case "VND": return "🇻🇳"
        case "EGP": return "🇪🇬"
        case "UAH": return "🇺🇦"
        case "ARS": return "🇦🇷"
        case "QAR": return "🇶🇦"
        case "KWD": return "🇰🇼"
        case "BDT": return "🇧🇩"
        case "NGN": return "🇳🇬"
        case "MAD": return "🇲🇦"
        case "PKR": return "🇵🇰"
        case "DKK": return "🇩🇰"
        case "BGN": return "🇧🇬"
        case "HRK": return "🇭🇷"
        case "RSD": return "🇷🇸"
        case "ISK": return "🇮🇸"
        case "LKR": return "🇱🇰"
        case "TND": return "🇹🇳"
        case "JOD": return "🇯🇴"
        case "OMR": return "🇴🇲"
        case "BHD": return "🇧🇭"
        case "LBP": return "🇱🇧"
        case "KHR": return "🇰🇭"
        case "MMK": return "🇲🇲"
        case "LAK": return "🇱🇦"
        case "MNT": return "🇲🇳"
        case "NPR": return "🇳🇵"
        case "KZT": return "🇰🇿"
        case "UZS": return "🇺🇿"
        case "GEL": return "🇬🇪"
        case "AMD": return "🇦🇲"
        case "AZN": return "🇦🇿"
        case "BYN": return "🇧🇾"
        case "MDL": return "🇲🇩"
        case "TJS": return "🇹🇯"
        case "TMT": return "🇹🇲"
        case "KGS": return "🇰🇬"
        case "AFN": return "🇦🇫"
        case "IRR": return "🇮🇷"
        case "IQD": return "🇮🇶"
        case "YER": return "🇾🇪"
        case "SYP": return "🇸🇾"
        case "LYD": return "🇱🇾"
        case "SDG": return "🇸🇩"
        case "ETB": return "🇪🇹"
        case "KES": return "🇰🇪"
        case "UGX": return "🇺🇬"
        case "TZS": return "🇹🇿"
        case "GHS": return "🇬🇭"
        case "XOF": return "🇨🇮"
        case "XAF": return "🇨🇲"
        case "ZMW": return "🇿🇲"
        case "MWK": return "🇲🇼"
        case "BWP": return "🇧🇼"
        case "NAD": return "🇳🇦"
        case "MUR": return "🇲🇺"
        case "SCR": return "🇸🇨"
        case "MVR": return "🇲🇻"
        case "BND": return "🇧🇳"
        case "KYD": return "🇰🇾"
        case "BBD": return "🇧🇧"
        case "JMD": return "🇯🇲"
        case "TTD": return "🇹🇹"
        case "GYD": return "🇬🇾"
        case "SRD": return "🇸🇷"
        case "FJD": return "🇫🇯"
        case "WST": return "🇼🇸"
        case "TOP": return "🇹🇴"
        case "VUV": return "🇻🇺"
        case "SBD": return "🇸🇧"
        case "PGK": return "🇵🇬"
        case "KID": return "🇰🇮"
        case "TVD": return "🇹🇻"
        case "NIO": return "🇳🇮"
        case "HNL": return "🇭🇳"
        case "GTQ": return "🇬🇹"
        case "BZD": return "🇧🇿"
        case "SVC": return "🇸🇻"
        case "CRC": return "🇨🇷"
        case "PAB": return "🇵🇦"
        case "PYG": return "🇵🇾"
        case "UYU": return "🇺🇾"
        case "BOB": return "🇧🇴"
        case "PEN": return "🇵🇪"
        case "ECU": return "🇪🇨"
        case "VEF": return "🇻🇪"
        default: return "🇺🇸"
        }
    }
}

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedCurrency: String
    @State private var searchText = ""

    private let allCurrencies: [(String, String, String)] = [
        ("USD", "🇺🇸", "US Dollar"),
        ("EUR", "🇪🇺", "Euro"),
        ("GBP", "🇬🇧", "British Pound"),
        ("JPY", "🇯🇵", "Japanese Yen"),
        ("CAD", "🇨🇦", "Canadian Dollar"),
        ("AUD", "🇦🇺", "Australian Dollar"),
        ("CHF", "🇨🇭", "Swiss Franc"),
        ("CNY", "🇨🇳", "Chinese Yuan"),
        ("SEK", "🇸🇪", "Swedish Krona"),
        ("NZD", "🇳🇿", "New Zealand Dollar"),
        ("MXN", "🇲🇽", "Mexican Peso"),
        ("SGD", "🇸🇬", "Singapore Dollar"),
        ("HKD", "🇭🇰", "Hong Kong Dollar"),
        ("NOK", "🇳🇴", "Norwegian Krone"),
        ("KRW", "🇰🇷", "South Korean Won"),
        ("TRY", "🇹🇷", "Turkish Lira"),
        ("RUB", "🇷🇺", "Russian Ruble"),
        ("INR", "🇮🇳", "Indian Rupee"),
        ("BRL", "🇧🇷", "Brazilian Real"),
        ("ZAR", "🇿🇦", "South African Rand"),
        ("ILS", "🇮🇱", "Israeli Shekel"),
        ("AED", "🇦🇪", "UAE Dirham"),
        ("SAR", "🇸🇦", "Saudi Riyal"),
        ("PLN", "🇵🇱", "Polish Zloty"),
        ("THB", "🇹🇭", "Thai Baht"),
        ("IDR", "🇮🇩", "Indonesian Rupiah"),
        ("CZK", "🇨🇿", "Czech Koruna"),
        ("HUF", "🇭🇺", "Hungarian Forint"),
        ("CLP", "🇨🇱", "Chilean Peso"),
        ("PHP", "🇵🇭", "Philippine Peso"),
        ("MYR", "🇲🇾", "Malaysian Ringgit"),
        ("COP", "🇨🇴", "Colombian Peso"),
        ("RON", "🇷🇴", "Romanian Leu"),
        ("VND", "🇻🇳", "Vietnamese Dong"),
        ("EGP", "🇪🇬", "Egyptian Pound"),
        ("UAH", "🇺🇦", "Ukrainian Hryvnia"),
        ("ARS", "🇦🇷", "Argentine Peso"),
        ("QAR", "🇶🇦", "Qatari Riyal"),
        ("KWD", "🇰🇼", "Kuwaiti Dinar"),
        ("BDT", "🇧🇩", "Bangladeshi Taka"),
        ("NGN", "🇳🇬", "Nigerian Naira"),
        ("MAD", "🇲🇦", "Moroccan Dirham"),
        ("PKR", "🇵🇰", "Pakistani Rupee")
    ]

    private var filteredCurrencies: [(String, String, String)] {
        if searchText.isEmpty {
            return allCurrencies
        }
        return allCurrencies.filter { currency in
            currency.0.localizedCaseInsensitiveContains(searchText)
                || currency.1.localizedCaseInsensitiveContains(searchText)
                || currency.2.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VeckoPlainSheetBar(
                    title: languageManager.text(.currencyNavTitle),
                    leadingTitle: languageManager.text(.commonCancel),
                    trailingTitle: languageManager.text(.commonDone),
                    onLeading: { dismiss() },
                    onTrailing: { dismiss() }
                )
                List(filteredCurrencies, id: \.0) { currency in
                Button {
                    selectedCurrency = currency.0
                    dismiss()
                } label: {
                    HStack {
                        Text(currency.1)
                            .font(.title2)
                        Text(currency.0)
                            .font(.headline)
                        Text(currency.2)
                            .foregroundColor(.gray)
                        Spacer()
                        if currency.0 == selectedCurrency {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .searchable(text: $searchText, prompt: languageManager.text(.currencySearchPrompt))
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    CurrencyPickerView(selectedCurrency: .constant("USD"))
        .environmentObject(LanguageManager())
}
