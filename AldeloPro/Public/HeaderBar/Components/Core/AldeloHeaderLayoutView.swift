//
//  AldeloHeaderLayoutView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderLayoutView
//
// 顶栏「三段式插槽布局引擎」。负责把 leading / center / trailing 三段内容
// 按平台排布，并处理 iPhone 竖屏的降级：
//
//   • iPad（Regular）：单行三栏。leading 左对齐、center 居中(高布局优先级)、trailing 右对齐。
//   • iPhone（Compact）：
//       - 默认单行：leading … trailing（center 省略），适用于 B/C/D 族。
//       - 两行模式 isTwoRowOnCompact=true：行1 = leading … trailing；行2 = center 全宽。
//         适用于 A 族——AI 搜索作为主角下沉第二行，最易发现且无需额外状态机。
//
// 该引擎只排布、不渲染具体业务内容（业务在 Atoms / façade）。

struct AldeloHeaderLayoutView<Leading: View, Center: View, Trailing: View>: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let isTwoRowOnCompact: Bool
    /// iPad 单行布局下 center 的固定宽度比例（相对整条 header 宽度）。
    /// 例：391.0/1440.0 → AI 搜索框按设计稿等比缩放居中显示。nil = 占满中间剩余空间。
    private let centerWidthRatio: CGFloat?
    private let leading: Leading
    private let center: Center
    private let trailing: Trailing

    init(
        isTwoRowOnCompact: Bool = false,
        centerWidthRatio: CGFloat? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder center: () -> Center,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.isTwoRowOnCompact = isTwoRowOnCompact
        self.centerWidthRatio = centerWidthRatio
        self.leading = leading()
        self.center = center()
        self.trailing = trailing()
    }

    private var isCompact: Bool { hSizeClass == .compact }

    var body: some View {
        if isCompact {
            compactLayout
        } else {
            regularLayout
        }
    }

    // MARK: iPad：单行三栏
    //
    // 用左右 Spacer 把 leading 推到最左、trailing 推到最右，center 夹在中间：
    //   • center 有内容（A 族 AI 框）：被两个 Spacer 居中，自身 maxWidth:.infinity 铺开剩余空间；
    //   • center 为 EmptyView（C/D 族）：两个 Spacer 合并成中间留白，
    //     从而 leading 仍靠左、trailing 仍靠右（修复此前 EmptyView 不撑开导致整组居中的回归）。
    // leading / trailing 给 layoutPriority(1)，保证不被压缩/截断。

    @ViewBuilder
    private var regularLayout: some View {
        if let ratio = centerWidthRatio {
            // 固定比例居中模式（A 族 AI 框）：center 作为整条 header 的居中 overlay，
            // 与 leading/trailing 解耦 → 无论左右宽度是否相等，center 都相对整条 header 绝对居中。
            HStack(spacing: Spacing.md) {
                leading
                Spacer(minLength: Spacing.md)
                trailing
            }
            .overlay {
                GeometryReader { geo in
                    center
                        .frame(width: geo.size.width * ratio)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                // overlay 不参与命中两侧按钮区域：AI 框居中、宽度受限，两侧留给 leading/trailing。
                .allowsHitTesting(true)
            }
        } else {
            // 默认模式（C/D 族）：左右 Spacer 把 leading 推左、trailing 推右，center 夹中间。
            HStack(spacing: Spacing.md) {
                leading
                    .layoutPriority(1)
                Spacer(minLength: Spacing.md)
                center
                Spacer(minLength: Spacing.md)
                trailing
                    .layoutPriority(1)
            }
        }
    }

    // MARK: iPhone：单行 / 两行

    private var compactLayout: some View {
        Group {
            if isTwoRowOnCompact {
                VStack(spacing: Spacing.xs) {
                    HStack(spacing: Spacing.sm) {
                        leading
                        Spacer(minLength: Spacing.xs)
                        trailing
                    }
                    center
                        .frame(maxWidth: .infinity)
                }
            } else {
                HStack(spacing: Spacing.sm) {
                    leading
                    Spacer(minLength: Spacing.xs)
                    trailing
                }
            }
        }
    }
}
