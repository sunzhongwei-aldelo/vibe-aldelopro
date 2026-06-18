//
//  CurrencyFormatter.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/16.
//

import Foundation

/// 价格输入的格式化与货币符号工具（纯逻辑，无副作用）。
///
/// 设计为 `nonisolated` 静态函数集合（与 `FieldValidator` 风格一致），
/// 可在任意上下文调用，便于在 View 的 binding 闭包与 ViewModel 中复用。
///
/// 职责：
/// - `currencySymbol`：货币符号取自 iOS 系统 `Locale.current`，取不到时回退美元 `"$"`。
/// - `sanitize`：实时过滤输入（仅数字 + 单个小数点，小数最多 2 位）。
/// - `padToTwoDecimals`：失焦补齐两位小数（`"5"` → `"5.00"`、`"5.1"` → `"5.10"`）。
/// - `string(from:)`：`Decimal` → 两位小数字符串（不含货币符号）。
enum CurrencyFormatter {

    /// 当前货币符号：iOS 系统 `Locale.current`，取不到时回退美元 `"$"`。
    nonisolated static var currencySymbol: String {
        Locale.current.currencySymbol ?? "$"
    }

    /// 实时过滤价格输入：仅保留数字与单个小数点，小数部分最多 2 位。
    /// 用于 TextField 的输入约束（`onChange` / binding 的 `set`）。
    ///
    /// - Parameter maxValue: 可选金额上限。解析后若超过上限，返回封顶值（补齐两位）。
    /// - Note: 保留输入中间态——`"5."`、`"5.0"` 原样返回，**不**塌缩为 `"5"`，
    ///   以免 TextField 绑定时尾随小数点被吞掉而无法继续输入。
    /// - Note: 前导 0——整数部分为单个 `0` 后继续输入数字时自动插入小数点
    ///   （`"05"` → `"0.5"`、`"00"` → `"0.0"`、`"008"` → `"0.08"`），单个 `"0"` 保持不变。
    ///   符合「0 开头即进入小数输入」的金额录入习惯。
    nonisolated static func sanitize(_ input: String, max maxValue: Decimal? = nil) -> String {
        var filtered = input.filter { $0.isNumber || $0 == "." }
        // 前导 0：整数部分为 "0" 后直接跟数字（尚无小数点）时，自动插入小数点。
        if filtered.contains(".") == false && filtered.hasPrefix("0") && filtered.count > 1 {
            filtered = "0." + filtered.dropFirst()
        }
        let parts = filtered.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let result: String
        if parts.count == 2 {
            let intPart = String(parts[0])
            let decPart = String(parts[1].prefix(2))   // 小数最多 2 位
            result = intPart + "." + decPart
        } else {
            result = filtered
        }
        // 上限保护：超过 maxValue 时封顶（补齐两位）。
        if let maxValue, let value = Decimal(string: result), value > maxValue {
            return string(from: maxValue)
        }
        return result
    }

    /// 失焦补齐：非空数字补足两位小数；空串保持空（交给 placeholder），非法串原样返回。
    nonisolated static func padToTwoDecimals(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "" }
        guard let value = Decimal(string: trimmed) else { return input }
        return string(from: value)
    }

    /// `Decimal` → 两位小数字符串（不含货币符号、无千分位），如 `5` → `"5.00"`。
    nonisolated static func string(from value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter.string(from: value as NSDecimalNumber) ?? "0.00"
    }
}
