//
//  EditPriceSettingView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 修改餐品单价表单

/// 页面 1：商品价格修改 + 数量步进器 + 备注
/// 仅渲染左侧表单内容，右侧键盘由容器提供
/// 价格采用金融收银级分位递进键入（Cent-Shifting），由容器状态机驱动
struct EditPriceSettingView: View {
    /// 格式化后的价格显示文本（如 "7.30"），由容器计算传入
    let priceDisplayText: String
    @Binding var quantity: Int
    @Binding var note: String
    let originalPrice: String
    let isPad: Bool
    var focusedField: FocusState<OrderSettingsField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.xl : Spacing.lg) {
            // 价格输入区
            priceSection
            // 数量步进器区
            quantitySection
            // 备注输入区
            noteSection
        }
    }

    // MARK: - 价格输入（只读显示，由右侧 Numpad 驱动）

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            // 标题行：New Price | Original: $5.00
            HStack {
                Text("New Price")
                    .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("Original: \(originalPrice)")
                    .font(isPad ? AppFont.tabletCaption1Regular : AppFont.mobileCaption1Regular)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // 价格显示框（点击聚焦以接收 Numpad 输入）
            Button(action: { focusedField.wrappedValue = .price }) {
                HStack {
                    Text("$")
                        .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(priceDisplayText)
                        .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, isPad ? Spacing.md : Spacing.sm)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                .overlay(
                    RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                        .stroke(
                            focusedField.wrappedValue == .price ? AppColors.theme : AppColors.line,
                            lineWidth: focusedField.wrappedValue == .price ? 1.5 : 1
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 数量步进器

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            Text("Qty to Apply New Price On")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            StepperCounterRow(value: $quantity, isPad: isPad)
        }
    }

    // MARK: - 备注输入

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            Text("Note")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 多行文本编辑器
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("Price Change Reason (Optional)")
                        .font(isPad ? AppFont.tabletBody3Regular : AppFont.mobileBody2Regular)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                }
                TextEditor(text: $note)
                    .font(isPad ? AppFont.tabletBody3Regular : AppFont.mobileBody2Regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xs)
            }
            .frame(minHeight: isPad ? 100 : 80)
            .background(AppColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
        }
    }
}
