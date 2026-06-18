import SwiftUI
import Combine

// MARK: - 小费输入视图模型


// MARK: - Input Mode

/// 小费输入页面的状态管理器
/// 负责百分比↔金额换算、预设选项高亮、金额校验等逻辑
enum GratuityInputMode: String, CaseIterable {
    case amount = "Amount"
    case percentage = "Percentage"
}

// MARK: - Gratuity Result

struct GratuityResult {
    let amount: Decimal
    let percentage: Decimal?
}

// MARK: - ViewModel

@MainActor
final class GratuityInputViewModel: ObservableObject {
    // MARK: - Published State

    @Published var inputMode: GratuityInputMode = .amount
    @Published private(set) var rawInput: String = ""

    let purchaseAmount: Decimal
    private let existingGratuity: Decimal?

    // MARK: - Quick Presets

    var amountPresets: [Decimal] { [5, 10, 20] }
    var percentagePresets: [Int] { [5, 10, 20, 30] }

    // MARK: - Computed

    var displayText: String {
        switch inputMode {
        case .amount:
            let formatted = formatAsCurrency(rawInput)
            return "$\(formatted)"
        case .percentage:
            return rawInput.isEmpty ? "0%" : "\(rawInput)%"
        }
    }

    var gratuityAmount: Decimal {
        switch inputMode {
        case .amount:
            return decimalFromRaw(rawInput)
        case .percentage:
            let pct = Decimal(string: rawInput) ?? 0
            return purchaseAmount * pct / 100
        }
    }

    var totalAmount: Decimal {
        purchaseAmount + gratuityAmount
    }

    var formattedPurchase: String {
        formatDecimalAsCurrency(purchaseAmount)
    }

    var formattedGratuity: String {
        formatDecimalAsCurrency(gratuityAmount)
    }

    var formattedTotal: String {
        formatDecimalAsCurrency(totalAmount)
    }

    var hasInput: Bool {
        !rawInput.isEmpty
    }

    // MARK: - Init

    init(purchaseAmount: Decimal, existingGratuity: Decimal? = nil) {
        self.purchaseAmount = purchaseAmount
        self.existingGratuity = existingGratuity
        if let existing = existingGratuity, existing > 0 {
            let cents = NSDecimalNumber(decimal: existing * 100).intValue
            self.rawInput = String(cents)
        }
    }

    // MARK: - Input Actions

    func appendDigit(_ digit: String) {
        switch inputMode {
        case .amount:
            guard rawInput.count < 7 else { return }
            rawInput += digit
        case .percentage:
            guard rawInput.count < 3 else { return }
            rawInput += digit
        }
    }

    func deleteLastDigit() {
        guard !rawInput.isEmpty else { return }
        rawInput.removeLast()
    }

    func clearInput() {
        rawInput = ""
    }

    func selectPresetAmount(_ amount: Decimal) {
        let cents = NSDecimalNumber(decimal: amount * 100).intValue
        rawInput = String(cents)
    }

    func selectPresetPercentage(_ pct: Int) {
        rawInput = String(pct)
    }

    func switchMode(_ mode: GratuityInputMode) {
        guard mode != inputMode else { return }
        rawInput = ""
        inputMode = mode
    }

    func buildResult() -> GratuityResult {
        switch inputMode {
        case .amount:
            return GratuityResult(amount: gratuityAmount, percentage: nil)
        case .percentage:
            let pct = Decimal(string: rawInput) ?? 0
            return GratuityResult(amount: gratuityAmount, percentage: pct)
        }
    }

    // MARK: - Private Helpers

    private func decimalFromRaw(_ raw: String) -> Decimal {
        guard let intVal = Int(raw) else { return 0 }
        return Decimal(intVal) / 100
    }

    private func formatAsCurrency(_ raw: String) -> String {
        guard !raw.isEmpty else { return "0.00" }
        let intVal = Int(raw) ?? 0
        let dollars = intVal / 100
        let cents = intVal % 100
        return String(format: "%d.%02d", dollars, cents)
    }

    private func formatDecimalAsCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

