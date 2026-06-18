//
//  StepperCounterRow.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 步进计数器原子组件

/// 通用加减步进器：[ - ] | 数值 | [ + ]
/// 外框胶囊长条块，背景 pageBg，按钮间有分割线
struct StepperCounterRow: View {
    @Binding var value: Int
    let isPad: Bool
    /// 最小值（默认 1）
    var minimum: Int = 1
    /// 最大值（默认 99）
    var maximum: Int = 99

    var body: some View {
        HStack(spacing: 0) {
            // 减号按钮
            Button(action: { if value > minimum { value -= 1 } }) {
                Text("-")
                    .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 56 : 44, height: isPad ? 56 : 44)
            }
            .disabled(value <= minimum)

            // 分割线
            Rectangle()
                .fill(AppColors.line)
                .frame(width: 1, height: isPad ? 36 : 28)

            // 中央数值
            Text("\(value)")
                .font(isPad ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: isPad ? 120 : 80, height: isPad ? 56 : 44)

            // 分割线
            Rectangle()
                .fill(AppColors.line)
                .frame(width: 1, height: isPad ? 36 : 28)

            // 加号按钮
            Button(action: { if value < maximum { value += 1 } }) {
                Text("+")
                    .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: isPad ? 56 : 44, height: isPad ? 56 : 44)
            }
            .disabled(value >= maximum)
        }
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
        .overlay(
            RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }
}
