//
//  QuickChipsFlowLayout.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 快捷标签流式布局

/// 支持自动折行的药丸标签矩阵
/// 当标签横向溢出可用宽度时，自动折行到下一行渲染
/// 点击任意标签将其文本追加到备注输入框
struct QuickChipsFlowLayout: View {
    /// 可用的快捷标签文本数组
    let chips: [String]
    /// 是否为 iPad 环境
    let isPad: Bool
    /// 标签点击回调
    let onChipTap: (String) -> Void

    var body: some View {
        // 使用自定义 Layout 协议实现流式折行
        NoteChipsFlowLayout(spacing: isPad ? Spacing.sm : Spacing.xs) {
            ForEach(chips, id: \.self) { chip in
                chipButton(chip)
            }
        }
    }

    // MARK: - 单个标签药丸

    /// 白底黑字胶囊按钮，带灰色细线边框
    private func chipButton(_ text: String) -> some View {
        Button(action: { onChipTap(text) }) {
            Text(text)
                .font(isPad ? AppFont.tabletButton4Medium : AppFont.mobileBody1Medium)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, isPad ? Spacing.md : Spacing.sm)
                .padding(.vertical, isPad ? Spacing.xs : Spacing.xxs)
                .background(AppColors.card)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 流式折行布局引擎

/// 自定义 Layout：水平排列子视图，当宽度不够时自动换行
struct NoteChipsFlowLayout: Layout {
    /// 元素之间的间距
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    /// 计算所有子视图的位置（流式折行逻辑核心）
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // 当前行放不下时换行
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        let totalHeight = currentY + lineHeight
        return ArrangeResult(
            positions: positions,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }

    /// 布局计算结果
    private struct ArrangeResult {
        let positions: [CGPoint]
        let size: CGSize
    }
}

// MARK: - Preview

#Preview("iPad - 快捷标签流") {
    QuickChipsFlowLayout(
        chips: ["No Cilantro", "Don't Add Chili Peppers", "Add More Sugar"],
        isPad: true,
        onChipTap: { _ in }
    )
    .padding(Spacing.xl)
    .background(AppColors.card)
}

#Preview("iPhone - 标签折行") {
    QuickChipsFlowLayout(
        chips: ["No Cilantro", "Don't Add Chili Peppers", "Add More Sugar", "Extra Lemon"],
        isPad: false,
        onChipTap: { _ in }
    )
    .padding(Spacing.lg)
    .frame(width: 320)
    .background(AppColors.card)
}
