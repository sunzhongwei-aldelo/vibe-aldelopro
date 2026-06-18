//
//  AldeloHeaderWebOrderChipView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderWebOrderChipView
//
// 【作用】
// A 族「工作台栏」(`AldeloDashboardHeaderView`) 右侧的「Web Order」（网络订单）入口药丸原子。
//
// 【设计要点】
// - 紧凑形态（无文字）：浅红圆角容器内 = 蓝色文档图标 + 红色圆形数量徽标（如 9）。
// - 数量 >99 时显示 "99+"，避免徽标被长数字撑破。
// - 容器底色 `AppColors.errorLight`（浅红），图标 `AppColors.theme`（蓝），徽标 `AppColors.errorNormal`（红）。
// - iPhone（Compact）下整体尺寸略缩（容器 30 / 徽标 18），iPad（Regular）为 34 / 20。
// - 可选 `onTap` 点击回调，进入网络订单列表。
//
// 【使用案例】
// ```swift
// // 1) 基础用法：显示待处理网络订单数
// AldeloHeaderWebOrderChipView(count: 9)
//
// // 2) 带点击跳转
// AldeloHeaderWebOrderChipView(count: pendingWebOrders) {
//     router.push(.webOrderList)
// }
//
// // 3) 超过 99 自动显示 "99+"
// AldeloHeaderWebOrderChipView(count: 256)   // 徽标显示 "99+"
//
// // 注意：count <= 0 时调用方通常应直接不渲染本组件（见 AldeloDashboardHeaderView 的 if 判断）
// ```

struct AldeloHeaderWebOrderChipView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 待处理网络订单数量。
    let count: Int
    /// 点击回调（进入网络订单列表）。
    var onTap: (() -> Void)? = nil

    private var isCompact: Bool { hSizeClass == .compact }

    /// 徽标显示文本：>99 显示 "99+"。
    private var countText: String {
        count > 99 ? "99+" : "\(count)"
    }

    private var iconFont: Font {
        isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: Spacing.xs) {
                // 蓝色文档图标
                Image(systemName: "doc.text.fill")
                    .font(iconFont)
                    .foregroundColor(AppColors.theme)

                // 红色圆形数量徽标
                Text(countText)
                    .font(isCompact ? AppFont.mobileBody2Medium : AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.white100)
                    .padding(.horizontal, Spacing.xxs)
                    .frame(minWidth: badgeSize, minHeight: badgeSize)
                    .background(AppColors.errorNormal)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, Spacing.xs)
            .frame(height: containerHeight)
            .background(AppColors.errorLight)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var badgeSize: CGFloat { isCompact ? 18 : 20 }
    private var containerHeight: CGFloat { isCompact ? 30 : 34 }
}
