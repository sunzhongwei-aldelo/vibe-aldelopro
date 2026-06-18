//
//  GuestCheckItemRow.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 客单菜品行


/// 已点菜品列表中的单行组件
/// 展示菜品名称、规格、数量、单价，支持左滑删除
struct GuestCheckItemRow: View {
    let item: OrderItem
    let isSelected: Bool
    /// 选中态点击价格旁的编辑按钮时触发（弹出改价弹窗）
    var onEditPrice: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // Main row: name, spec, qty, price
            HStack(alignment: .top) {
                Text(item.name)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let holdTime = item.holdDateTime {
                    HoldBadge(time: holdTime)
                }
            }
            
            HStack(spacing: Spacing.xs) {
                Text(item.spec)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                if isSelected {
                    editPriceButton
                }

                Spacer()

                Text("\u{00D7} \(item.quantity)")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                Text(formatPrice(item.totalPrice))
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 60, alignment: .trailing)
            }

            // Note and portion details only shown when selected
//            if isSelected {
                if let note = item.modifier {
                    Text(note)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.primaryNormal)
                }

                if let details = item.portionDetails {
                    ForEach(details, id: \.self) { detail in
                        Text(detail)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.primaryNormal)
                    }
                }

                if let itemNote = item.itemNote {
                    Text(itemNote)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.errorNormal)
                }
//            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    /// 选中态显示的「单价 + 铅笔」改价入口（对应 editPrice.svg：纯文字 + 细线铅笔，无框无背景）
    private var editPriceButton: some View {
        Button(action: onEditPrice) {
            HStack(spacing: Spacing.xs) {
                Text(formatPrice(item.unitPrice))
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                Image(.frame2)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(AppColors.textSecondary)
            }
            .contentShape(Rectangle())
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

#Preview("Item Row - Selected") {
    GuestCheckItemRow(
        item: OrderItem(
            id: "3", menuItemId: "pizza1", name: "Pizza", spec: "6 inches",
            quantity: 1, unitPrice: 5.00, totalPrice: 5.00,
            modifier: nil,
            itemNote: nil, portionDetails: [
                "1st 1/4: Normal, Lemon, Fruit Pieces",
                "2nd 1/4: Normal, Lemon",
                "3rd 1/4: Half Sugar, Lemon",
                "4th 1/4: Normal, Lemon, Beef"
            ], guest: 1,
            holdDateTime: 10,
            course: nil
            
        ),
        isSelected: true
    )
    .background(AppColors.primaryLight)
    .frame(width: 450)
}

#Preview("Item Row - With Note") {
    GuestCheckItemRow(
        item: OrderItem(
            id: "2", menuItemId: "d4", name: "Wine", spec: "Bottle",
            quantity: 1, unitPrice: 5.00, totalPrice: 5.00,
            modifier: "Lafite,Vintage 1992",
            itemNote: "I need to sober up early,I need to sober up early,I need to sober up early",
            portionDetails: nil, guest: 1
        ),
        isSelected: true
    )
    .background(AppColors.primaryLight)
    .frame(width: 450)
}

#Preview("Item Row - Unselected") {
    GuestCheckItemRow(
        item: OrderItem(
            id: "1", menuItemId: "d1", name: "Orange Juice", spec: "Small Cup",
            quantity: 5, unitPrice: 5.00, totalPrice: 25.00,
            modifier: nil, itemNote: nil, portionDetails: nil, guest: 1
        ),
        isSelected: false
    )
    .frame(width: 450)
}

