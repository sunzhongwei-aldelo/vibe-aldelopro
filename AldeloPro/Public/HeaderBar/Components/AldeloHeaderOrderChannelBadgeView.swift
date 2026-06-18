//
//  AldeloHeaderOrderChannelBadgeView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderOrderChannelBadgeView
//
// 【作用】
// B 族「交易开单栏」(`AldeloTransactionHeaderView`) 左侧的订单标识原子：
// 渠道色块图标 + 渠道名 + 长订单号 + 大订单号 + 可选桌台徽标。
//
// 【设计要点】
// - 渠道色块：圆角方块，底色为渠道色（取自 DesignTokens 的 orderType* 系列：
//   DineIn 橙 / TakeOut 蓝 / Delivery 黄 / DriveThru 红 / Bar 黄绿 / Retail 青），内嵌白色渠道图标。
// - 文字区：第一行渠道名（如 "Dine In"），第二行长订单号（如 "1200002"，仅 iPad）。
// - 大订单号（如 "#015"）以大字号紧随其后。
// - 桌台徽标：仅 Dine In 且 iPad 显示，灰底圆角，含小图标 + 桌号。
// - iPhone（Compact）降级：隐藏长订单号与桌台徽标，仅保留渠道名 + 大订单号。
//
// 【使用案例】
// ```swift
// // 1) Dine In（堂食，含桌台）
// AldeloHeaderOrderChannelBadgeView(
//     channelTitle: "Dine In",
//     channelColor: AppColors.orderTypeDineIn,
//     channelIcon: "fork.knife",
//     longOrderNo: "1200002",
//     orderNumber: "#015",
//     tableNumber: "01"
// )
//
// // 2) Take Out（外带，无桌台）
// AldeloHeaderOrderChannelBadgeView(
//     channelTitle: "Take Out",
//     channelColor: AppColors.orderTypeTakeOut,
//     channelIcon: "bag.fill",
//     longOrderNo: "1200002",
//     orderNumber: "#016"
// )
// ```
// 注：实际业务中通常不直接用本原子，而是用 `AldeloTransactionHeaderView.dineIn(...)` 等便捷构造。

struct AldeloHeaderOrderChannelBadgeView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 渠道名（如 "Dine In" / "Take Out"）。
    let channelTitle: String
    /// 渠道主题色（取自 AppColors.orderType* 系列）。
    let channelColor: Color
    /// 渠道图标 SF Symbol 名（如 "fork.knife"）。
    let channelIcon: String
    /// 长订单号，如 "1200002"（仅 iPad 显示）。
    let longOrderNo: String
    /// 大号订单号，如 "#015"。
    let orderNumber: String
    /// 桌台号（仅 Dine In 有），如 "01"；nil 则不显示桌台徽标。
    var tableNumber: String? = nil
    /// 桌台徽标前缀图标，默认餐具图标。
    var tableIcon: String = "fork.knife"

    private var isCompact: Bool { hSizeClass == .compact }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            channelBlock

            // 渠道名 + 长订单号
            VStack(alignment: .leading, spacing: 0) {
                Text(channelTitle)
                    .font(isCompact ? AppFont.mobileDisplay3Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
                if !isCompact {
                    Text(longOrderNo)
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // 大订单号
            Text(orderNumber)
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletDisplay7Medium)
                .foregroundColor(AppColors.textPrimary)

            // 桌台徽标（仅 Dine In + iPad）
            if let table = tableNumber, !isCompact {
                tableBadge(table)
            }
        }
    }

    /// 渠道色块：圆角方块 + 白色渠道图标。
    private var channelBlock: some View {
        RoundedRectangle(cornerRadius: isCompact ? AppRadius.Mobile.xs : AppRadius.Tablet.xs)
            .fill(channelColor)
            .frame(width: blockSize, height: blockSize)
            .overlay(
                Image(systemName: channelIcon)
                    .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.white100)
            )
    }

    private var blockSize: CGFloat { isCompact ? 28 : 32 }

    /// 桌台徽标：灰底圆角 + 小图标 + 桌号。
    private func tableBadge(_ table: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: tableIcon)
            Text(table)
        }
        .font(AppFont.tabletH4Medium)
        .foregroundColor(AppColors.textPrimary)
        .padding(.horizontal, Spacing.xs)
        .frame(height: 32)
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }
}
