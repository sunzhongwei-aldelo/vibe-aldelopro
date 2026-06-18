//
//  OptionPriceField.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/16.
//

import SwiftUI

/// 价格输入子控件（用于 CreateOptionGroupView 的 Option Item 价 / Extra Price）。
///
/// 关键：TextField **直接绑定自己的真实 `@State text`**，sanitize 放在独立的
/// `.onChange(of: text)` 里重新赋值该 state —— 只有这样 UITextField 缓冲区才会被强制刷新，
/// 非法字符 / 超限值才真正被拦下。computed `Binding` 在 get/set 内改写会被 SwiftUI 编辑期忽略，
/// 导致字母、超长小数漏入（与 AddItemView.unitPrice 同款「真实存储 + onChange」结构对齐）。
///
/// 货币符号作为独立前缀 `Text` 显示（与 AddItemView.unitPriceField 一致），仅在已输入值时出现；
/// 空串时交给 placeholder（Option 价占位 "$ 0.00"，Extra Price 占位文字 "Extra Price"），
/// 避免空的 Extra Price 框出现 "$ Extra Price" 这类怪异占位。
///
/// - 聚焦期：用户自由输入，`text` 实时 sanitize（仅数字 + 单点、≤2 位小数、前导 0 转小数、封顶 maxValue）。
/// - 失焦：补齐两位小数（空串保持空）。
/// - 每次 `text` 变化把解析后的 `Decimal?` 通过 `onValueChange` 回传父级（空 → nil）。
struct OptionPriceField: View {
    let placeholder: String
    let fieldTag: FocusedField
    let maxValue: Decimal
    /// 初始值（来自模型；nil 或 0 → 空串占位）。
    let initialValue: Decimal?
    /// 是否把 0 视为有效值显示（optionItem 的 price 为 0 时显示空；modifier 的 0 是有效填价）。
    let showsZero: Bool
    let focus: FocusState<FocusedField?>.Binding
    /// 解析结果回传：空串 → nil，否则为 Decimal。
    let onValueChange: (Decimal?) -> Void

    @State private var text: String = ""

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // 货币符号前缀：仅在已输入值时显示（空串时交给 placeholder，避免 "$ Extra Price" 这类怪异占位）。
            if text.isEmpty == false {
                Text(CurrencyFormatter.currencySymbol)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
            TextField(placeholder, text: $text)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(.decimalPad)
                .focused(focus, equals: fieldTag)
                .id(fieldTag)
                .onAppear { text = initialDisplay() }
                .onChange(of: text) { _, newValue in
                    // 实时过滤 + 封顶：重新赋值真实 @State，强制 UITextField 刷新（拦下字母/超限）。
                    let sanitized = CurrencyFormatter.sanitize(newValue, max: maxValue)
                    if sanitized != newValue {
                        text = sanitized
                    }
                    onValueChange(sanitized.isEmpty ? nil : Decimal(string: sanitized))
                }
                .onChange(of: focus.wrappedValue) { _, newFocus in
                    // 失焦本字段：补齐两位小数。
                    if newFocus != fieldTag && text.isEmpty == false {
                        let padded = CurrencyFormatter.padToTwoDecimals(text)
                        if padded != text { text = padded }
                    }
                }
        }
    }

    /// 初始显示文本：nil → 空；0 且不显示零 → 空；否则补齐两位。
    private func initialDisplay() -> String {
        guard let v = initialValue else { return "" }
        if v == 0 && showsZero == false { return "" }
        return CurrencyFormatter.string(from: v)
    }
}
