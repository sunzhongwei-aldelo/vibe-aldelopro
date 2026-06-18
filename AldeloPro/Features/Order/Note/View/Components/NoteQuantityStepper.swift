//
//  NoteQuantityStepper.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 备注数量步进器

/// 控制当前备注套用商品件数的加减计数器
/// 设计规格：[ - ] (独立小方块) | 宽中央数值区(灰底圆角) | [ + ] (独立小方块)
/// 三个元素分离排布，非一体连续条
struct NoteQuantityStepper: View {
    /// 双向绑定的数量值
    @Binding var quantity: Int
    /// 是否为 iPad 环境
    let isPad: Bool
    /// 最小值（默认 1）
    var minimum: Int = 1
    /// 最大值（默认 99）
    var maximum: Int = 99

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            // 顶置标题
            Text("Qty to Apply Notes On")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 步进器三段式布局：减号 | 宽数值区 | 加号
            HStack(spacing: isPad ? Spacing.sm : Spacing.xs) {
                // 减号按钮（独立方块）
                Button(action: { if quantity > minimum { quantity -= 1 } }) {
                    Image(systemName: "minus")
                        .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                        .foregroundStyle(quantity > minimum ? AppColors.textPrimary : AppColors.textSecondary)
                        .frame(width: isPad ? 48 : 40, height: isPad ? 48 : 40)
                        .background(AppColors.pageBg)
                        .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                                .stroke(AppColors.line, lineWidth: 1)
                        )
                }
                .disabled(quantity <= minimum)

                // 中央宽数值区（灰底圆角矩形）
                Text("\(quantity)")
                    .font(isPad ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 160 : 100, height: isPad ? 48 : 40)
                    .background(AppColors.pageBg)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                            .stroke(AppColors.line, lineWidth: 1)
                    )

                // 加号按钮（独立方块）
                Button(action: { if quantity < maximum { quantity += 1 } }) {
                    Image(systemName: "plus")
                        .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                        .foregroundStyle(quantity < maximum ? AppColors.textPrimary : AppColors.textSecondary)
                        .frame(width: isPad ? 48 : 40, height: isPad ? 48 : 40)
                        .background(AppColors.pageBg)
                        .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                                .stroke(AppColors.line, lineWidth: 1)
                        )
                }
                .disabled(quantity >= maximum)
            }
        }
    }
}

// MARK: - Preview

#Preview("iPad - 步进器") {
    NoteQuantityStepper(quantity: .constant(5), isPad: true)
        .padding(Spacing.xl)
        .background(AppColors.card)
}

#Preview("iPhone - 步进器 (Dark)") {
    NoteQuantityStepper(quantity: .constant(3), isPad: false)
        .padding(Spacing.lg)
        .background(AppColors.card)
        .preferredColorScheme(.dark)
}
