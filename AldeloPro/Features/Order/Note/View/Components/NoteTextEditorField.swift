//
//  NoteTextEditorField.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 备注文本编辑器组件

/// 带自定义占位符的大面积文本输入域
/// - 空态显示斜体占位符 "Custom Notes About This Item"
/// - 聚焦时外圈高亮 1.5pt 品牌蓝边框
/// - 背景强制填充 AppColors.pageBg 可视灰底色
/// - 高度锁死 120pt（iPad）/ 100pt（iPhone），严禁坍塌
struct NoteTextEditorField: View {
    /// 双向绑定的文本内容
    @Binding var text: String
    /// 是否为 iPad 环境
    let isPad: Bool
    let isOrder: Bool
    /// 输入框聚焦状态
    @FocusState private var isFocused: Bool

    /// 锁定高度：iPad 120pt / iPhone 100pt
    private var lockedHeight: CGFloat {
        isPad ? 120 : 100
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 灰色背景底板（使用 pageBg 确保可见灰色）
            RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                .fill(AppColors.pageBg)

            // 占位符层（文本为空时显示）
            if text.isEmpty {
                Text("Custom Notes About This \(isOrder ? "Order" : "Item")")
                    .font(isPad ? AppFont.tabletBody3Regular : AppFont.mobileBody1Regular)
                    .italic()
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
            }

            // 实际文本编辑器
            TextEditor(text: $text)
                .font(isPad ? AppFont.tabletBody3Regular : AppFont.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.xs)
        }
        // 锁定死高度，严禁坍塌或拉伸
        .frame(height: lockedHeight)
        .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
        .overlay(
            RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                .stroke(
                    isFocused ? AppColors.theme : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Preview

#Preview("iPad - 空态占位符") {
    NoteTextEditorField(text: .constant(""), isPad: true ,isOrder: false)
        .padding(Spacing.xl)
        .background(AppColors.card)
}

#Preview("iPad - 已输入内容") {
    NoteTextEditorField(text: .constant("No ice, extra sugar please"), isPad: true,isOrder: true)
        .padding(Spacing.xl)
        .padding(Spacing.xl)
        .background(AppColors.card)
}
