//
//  OrderTypeOptionCard.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 订单类型选项卡片

/// 2x3 网格中的单个订单渠道卡片
/// 选中态：蓝色边框 + 半透明蓝底
/// 未选中态：灰色边框 + 白底
struct OrderTypeOptionCard: View {
    let orderType: OrderType
    let isSelected: Bool
    let isPad: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: isPad ? Spacing.md : Spacing.sm) {
                // 左侧彩色图标容器
                iconView
                // 右侧文字标签
                Text(orderType.rawValue)
                    .font(isPad ? AppFont.tabletH4Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, isPad ? Spacing.md : Spacing.sm)
            .padding(.vertical, isPad ? Spacing.md : Spacing.sm)
            .frame(maxWidth: .infinity, minHeight: isPad ? 64 : 52)
            .background(isSelected ? AppColors.theme.opacity(0.08) : AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
            .overlay(
                RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                    .stroke(isSelected ? AppColors.theme : AppColors.line,
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 图标视图

    private var iconView: some View {
        RoundedRectangle(cornerRadius: isPad ? 10 : 8)
            .fill(iconColor)
            .frame(width: isPad ? 44 : 36, height: isPad ? 44 : 36)
            .overlay(
                Image(systemName: iconName)
                    .font(.system(size: isPad ? 20 : 16, weight: .medium))
                    .foregroundStyle(.white)
            )
    }

    /// 根据订单类型返回对应图标背景颜色
    private var iconColor: Color {
        switch orderType {
        case .dineIn: return AppColors.orderTypeDineIn
        case .takeOut: return AppColors.orderTypeTakeOut
        case .bar: return AppColors.orderTypeBar
        case .delivery: return AppColors.orderTypeDelivery
        case .retail: return AppColors.orderTypeRetail
        case .driveThru: return AppColors.orderTypeDriveThru
        }
    }

    /// 根据订单类型返回对应 SF Symbol 图标名
    private var iconName: String {
        switch orderType {
        case .dineIn: return "fork.knife"
        case .takeOut: return "bag.fill"
        case .bar: return "wineglass.fill"
        case .delivery: return "bicycle"
        case .retail: return "cart.fill"
        case .driveThru: return "car.fill"
        }
    }
}
