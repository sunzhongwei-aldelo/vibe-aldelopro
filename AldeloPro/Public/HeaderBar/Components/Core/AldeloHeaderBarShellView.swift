//
//  AldeloHeaderBarShellView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderBarShellView
//
// 顶栏「物理底壳」——所有横切关注点在此收口一次，上层 façade 与原子无需重复：
//   • 高度：按 AldeloHeaderHeight 在 iPad(regular)/iPhone(compact) 间切换
//   • 背景：统一 AppColors.card（Asset，自动适配 Dark Mode，禁止手写 if colorScheme）
//   • 分割线：底部 1pt AppColors.line
//   • 宽度："特殊长度"——.fill 全宽 / .inset(leading:) 仅覆盖右内容列
//   • 水平内边距：iPad Spacing.lg / iPhone Spacing.md
//
// 用法：façade 把组装好的内容塞进 content，shell 负责把它放进正确尺寸的壳里。

struct AldeloHeaderBarShellView<Content: View>: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let height: AldeloHeaderHeight
    private let width: AldeloHeaderWidth
    private let background: Color
    private let content: Content

    init(
        height: AldeloHeaderHeight,
        width: AldeloHeaderWidth = .fill,
        background: Color = AppColors.card,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.width = width
        self.background = background
        self.content = content()
    }

    /// 是否 iPhone（Compact）布局。
    private var isCompact: Bool { hSizeClass == .compact }

    /// 当前生效高度。
    private var resolvedHeight: CGFloat {
        isCompact ? height.compact : height.regular
    }

    /// 水平内边距：Token 隔离——iPad 用 lg、iPhone 用 md。
    private var horizontalPadding: CGFloat {
        isCompact ? Spacing.md : Spacing.lg
    }

    var body: some View {
        content
            .padding(.horizontal, horizontalPadding)
            .frame(height: resolvedHeight)
            .frame(maxWidth: .infinity)
            // inset 模式：左侧让出固定宽度给通顶面板（weweqeqw 场景）。
            .padding(.leading, width.leadingInset)
            .background(background)
            .overlay(alignment: .bottom) {
                AppColors.line.frame(height: 1)
            }
    }
}
