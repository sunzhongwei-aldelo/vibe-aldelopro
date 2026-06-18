//
//  AldeloHeaderUserAvatarClusterView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderUserAvatarClusterView
//
// 【作用】
// A 族「工作台栏」(`AldeloDashboardHeaderView`) 右侧的当前登录员工簇原子：
// 圆形头像（取姓名首字母）+ 可选「姓名 + 打卡时间」明细。
//
// 【设计要点】
// - 头像：品牌蓝实心圆 `AppColors.theme`，内嵌姓名首字母（大写），白字。
// - 明细：仅当 `showsDetails == true` 且为 iPad（Regular）时显示——
//   第一行姓名（`textPrimary`），第二行 "Clocked in HH:mm"（`textSecondary`）。
// - iPhone（Compact）下永远只显示纯头像（节省横向空间）。
// - 头像尺寸：iPad 32 / iPhone 28。
//
// 【使用案例】
// ```swift
// // 1) 纯头像（不显示姓名/打卡）
// AldeloHeaderUserAvatarClusterView(serverName: "Zhang San", clockInTime: "12:25 PM")
//
// // 2) 显示完整明细（仅 iPad 生效）
// AldeloHeaderUserAvatarClusterView(
//     serverName: "Zhang San",
//     clockInTime: "12:25 PM",
//     showsDetails: true
// )
//
// // 首字母自动取姓名第一个字符并大写："zhang san" → "Z"
// ```

struct AldeloHeaderUserAvatarClusterView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 员工姓名（用于取首字母 + 明细行显示）。
    let serverName: String
    /// 打卡时间文本（如 "12:25 PM"）。
    let clockInTime: String
    /// 是否显示姓名 + 打卡时间明细（默认 false = 纯头像；且仅 iPad 显示明细）。
    var showsDetails: Bool = false

    private var isCompact: Bool { hSizeClass == .compact }

    /// 头像内首字母（取姓名首字符并大写）。
    private var initial: String {
        String(serverName.prefix(1)).uppercased()
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // 圆形头像 + 首字母
            Circle()
                .fill(AppColors.theme)
                .frame(width: avatarSize, height: avatarSize)
                .overlay(
                    Text(initial)
                        .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.white100)
                )

            // 姓名 + 打卡明细（仅 iPad 且开启时）
            if showsDetails && !isCompact {
                VStack(alignment: .leading, spacing: 2) {
                    Text(serverName)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Text("Clocked in \(clockInTime)")
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private var avatarSize: CGFloat { isCompact ? 28 : 32 }
}
