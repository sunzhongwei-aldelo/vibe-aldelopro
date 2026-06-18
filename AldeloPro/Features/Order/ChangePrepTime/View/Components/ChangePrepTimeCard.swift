//
//  ChangePrepTimeCard.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/08.
//

import SwiftUI

// MARK: - 备餐时间选项卡片

/// 双行结构的时间选项卡片组件
/// 上半部分：显示时长标签（如 "10 min"）
/// 下半部分：显示计算后的目标时间（如 "10:10 AM"）
/// 选中态：蓝色边框 + 淡蓝背景 + 蓝色文字
struct ChangePrepTimeGridCard: View {
    /// 时间选项数据
    let option: PrepTimeOption
    /// 格式化后的目标时间文本
    let formattedTime: String
    /// 是否为当前选中状态
    let isSelected: Bool
    /// 点击回调
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // 上半部分：时长标签
                durationSection
                // 中间分割线
                Divider()
                    .background(dividerColor)
                // 下半部分：目标时间
                timeSection
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .fill(cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 上半区域（时长标签）

    /// 显示备餐时长文本（如 "10 min", "15 min"）
    private var durationSection: some View {
        Text(option.label)
            .font(AppFont.tabletH2Medium)
            .foregroundColor(isSelected ? AppColors.theme : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
    }

    // MARK: - 下半区域（目标时间）

    /// 显示预计完成时间（如 "10:10 AM"）
    private var timeSection: some View {
        Text(formattedTime)
            .font(AppFont.tabletBody3Regular)
            .foregroundColor(isSelected ? AppColors.theme : AppColors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
    }

    // MARK: - 样式计算

    /// 卡片背景色：选中态淡蓝，未选中态白色
    private var cardBackground: Color {
        isSelected ? AppColors.theme.opacity(0.06) : AppColors.card
    }

    /// 边框颜色：选中态品牌蓝，未选中态灰线
    private var borderColor: Color {
        isSelected ? AppColors.theme : AppColors.line
    }

    /// 分割线颜色：选中态半透明蓝，未选中态灰线
    private var dividerColor: Color {
        isSelected ? AppColors.theme.opacity(0.2) : AppColors.line
    }
}
