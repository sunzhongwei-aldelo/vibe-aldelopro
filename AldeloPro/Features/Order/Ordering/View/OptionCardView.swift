//
//  OptionCardView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 选项卡片视图


/// 菜品规格/加料/口味等选项的单个卡片组件
/// 选中态高亮蓝框，未选中态灰色边框
struct OptionCardView: View {
    let name: String
    let price: Decimal?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                HStack {
                    Text(name)
                        .font(AppFont.tabletH6Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.primaryNormal)
                    }
                }
                if let price {
                    Text(formatPrice(price))
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 61)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        isSelected ? AppColors.primaryNormal : AppColors.line,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview("Option - Selected with Price") {
    OptionCardView(name: "6 Inches", price: 8.00, isSelected: true) { }
        .frame(width: 200)
        .padding()
}

#Preview("Option - Unselected") {
    OptionCardView(name: "Hand-Tossed", price: nil, isSelected: false) { }
        .frame(width: 200)
        .padding()
}

