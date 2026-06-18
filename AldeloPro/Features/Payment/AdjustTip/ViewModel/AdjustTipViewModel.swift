//
//  AdjustTipViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import Foundation

// MARK: - 输入模式

/// Adjust Tip 的输入模式：按金额或按百分比
enum TipInputMode: String, CaseIterable {
    case amount = "Amount"
    case percentage = "Percentage"
}

// MARK: - 提交结果

/// Adjust Tip 提交时的结果数据
struct AdjustTipResult {
    /// 小费金额（美元）
    let tipAmount: Decimal
    /// 百分比值（仅百分比模式有值）
    let percentage: Decimal?
}

// MARK: - AdjustTipViewModel

/// Adjust Tip 弹窗的状态管理
///
/// 管理数字键盘输入、Amount/Percentage 模式切换、快捷预设选择，
/// 以及百分比模式下的金额计算（Purchase + Tip = Total）。
///
/// 金额输入规则：以"分"为单位累加数字，显示时自动格式化为 $X.XX
/// 百分比输入规则：直接输入整数百分比（最多 3 位）
@Observable
final class AdjustTipViewModel {

    // MARK: - 状态

    /// 当前输入模式
    var inputMode: TipInputMode = .amount

    /// 原始输入字符串（金额模式为分的整数，百分比模式为百分比整数）
    private(set) var rawInput: String = ""

    /// 订单消费金额（用于百分比计算）
    let purchaseAmount: Decimal

    // MARK: - 快捷预设

    /// 金额模式的快捷选项（美元）
    let amountPresets: [Decimal] = [5, 10, 20]

    /// 百分比模式的快捷选项
    let percentagePresets: [Int] = [5, 10, 20, 30]

    // MARK: - 计算属性

    /// 输入框显示文本（格式化后）
    var displayText: String {
        switch inputMode {
        case .amount:
            return "$\(formatAsCurrency(rawInput))"
        case .percentage:
            return rawInput.isEmpty ? "0%" : "\(rawInput)%"
        }
    }

    /// 计算得到的小费金额
    var tipAmount: Decimal {
        switch inputMode {
        case .amount:
            return decimalFromRaw(rawInput)
        case .percentage:
            let pct = Decimal(string: rawInput) ?? 0
            return purchaseAmount * pct / 100
        }
    }

    /// 总金额 = 消费 + 小费
    var totalAmount: Decimal {
        purchaseAmount + tipAmount
    }

    /// 格式化的消费金额
    var formattedPurchase: String { formatDecimal(purchaseAmount) }

    /// 格式化的小费金额
    var formattedTip: String { formatDecimal(tipAmount) }

    /// 格式化的总金额
    var formattedTotal: String { formatDecimal(totalAmount) }

    /// 是否有有效输入（用于控制 Confirm 按钮状态）
    var hasInput: Bool { !rawInput.isEmpty }

    // MARK: - Init

    init(purchaseAmount: Decimal) {
        self.purchaseAmount = purchaseAmount
    }

    // MARK: - 数字键盘操作

    /// 追加一个数字
    func appendDigit(_ digit: String) {
        switch inputMode {
        case .amount:
            guard rawInput.count < 7 else { return } // 最大 $99,999.99
            rawInput += digit
        case .percentage:
            guard rawInput.count < 3 else { return } // 最大 999%
            rawInput += digit
        }
    }

    /// 删除最后一位
    func deleteLastDigit() {
        guard !rawInput.isEmpty else { return }
        rawInput.removeLast()
    }

    /// 清空输入
    func clearInput() {
        rawInput = ""
    }

    // MARK: - 快捷预设操作

    /// 选择预设金额（如 $5.00 → rawInput = "500"）
    func selectPresetAmount(_ amount: Decimal) {
        let cents = NSDecimalNumber(decimal: amount * 100).intValue
        rawInput = String(cents)
    }

    /// 选择预设百分比（如 10% → rawInput = "10"）
    func selectPresetPercentage(_ pct: Int) {
        rawInput = String(pct)
    }

    // MARK: - 模式切换

    /// 切换输入模式（会清空当前输入）
    func switchMode(_ mode: TipInputMode) {
        guard mode != inputMode else { return }
        rawInput = ""
        inputMode = mode
    }

    // MARK: - 提交

    /// 构建提交结果
    func buildResult() -> AdjustTipResult {
        switch inputMode {
        case .amount:
            return AdjustTipResult(tipAmount: tipAmount, percentage: nil)
        case .percentage:
            let pct = Decimal(string: rawInput) ?? 0
            return AdjustTipResult(tipAmount: tipAmount, percentage: pct)
        }
    }

    // MARK: - 私有格式化

    private func decimalFromRaw(_ raw: String) -> Decimal {
        guard let intVal = Int(raw) else { return 0 }
        return Decimal(intVal) / 100
    }

    private func formatAsCurrency(_ raw: String) -> String {
        guard !raw.isEmpty else { return "0.00" }
        let intVal = Int(raw) ?? 0
        return String(format: "%d.%02d", intVal / 100, intVal % 100)
    }

    private func formatDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
