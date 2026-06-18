//
//  AldeloHeaderCloseButton.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderCloseButton
//
// 【作用】
// C 族「配置 / 弹窗栏」(`AldeloModalHeaderView`) 右上角的关闭叉号按钮原子。
// 用于「标题 LEFT + 关闭 X RIGHT」的弹窗式头栏（如 Delivery Detail、Set Gratuity）。
//
// 【设计要点】
// - 纯图标（xmark），无底色，点击即 dismiss。
// - iPad（Regular）尺寸 32×32 / 字号偏大；iPhone（Compact）28×28。
// - 颜色用 `AppColors.textPrimary`（随 Dark Mode 自适应）。
//
// 【使用案例】
// ```swift
// // 通过 AldeloModalHeaderView 的 onClose 间接使用：
// AldeloModalHeaderView(title: "Delivery Detail", onClose: { dismiss() })
//
// // 也可单独使用：
// AldeloHeaderCloseButton(onClose: { dismiss() })
// ```

struct AldeloHeaderCloseButton: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let onClose: () -> Void

    private var isCompact: Bool { hSizeClass == .compact }

    var body: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: size, height: size)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var size: CGFloat { isCompact ? 28 : 32 }
}
