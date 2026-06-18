//
//  BottomActionBar.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - Layout Mode

enum BottomActionBarLayout {
    /// 按钮固定宽度、整体水平居中（默认）
    case centered
    /// 按钮拉伸填满可用宽度（带响应式左右间距）
    case stretched
}

// MARK: - BottomActionBar

/// 通用底部操作栏组件
/// 支持自定义按钮数量/颜色/样式，内置响应式左右间距（iPad 大间距，iPhone 小间距）
struct BottomActionBar: View {

    let buttons: [ButtonConfig]
    let layout: BottomActionBarLayout

    @Environment(\.horizontalSizeClass) private var hSizeClass

    init(
        buttons: [ButtonConfig],
        layout: BottomActionBarLayout = .centered
    ) {
        self.buttons = buttons
        self.layout = layout
    }

    var body: some View {
        GeometryReader { geo in
            let isCompact = hSizeClass == .compact
            // iPad: 按钮组占 50% 宽度，两侧各留 25%
            // iPhone: 按钮组占 80% 宽度，两侧各留 10%
            let buttonGroupWidth = isCompact
                ? geo.size.width * 0.8
                : geo.size.width * 0.5

            HStack {
                Spacer()

                HStack(spacing: Spacing.md) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { _, config in
                        Button(action: config.action) {
                            Text(config.title)
                                .font(AppFont.tabletH4Medium)
                                .foregroundColor(config.textColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: Spacing.xxxxl)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                        .fill(config.bgColor)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                        .stroke(config.showStroke ? AppColors.line : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(config.isDisabled)
                        .opacity(config.isDisabled ? 0.5 : 1.0)
                    }
                }
                .frame(width: buttonGroupWidth)

                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: Spacing.xxxxl + Spacing.lg * 2)
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Button Configuration

extension BottomActionBar {
    struct ButtonConfig {
        let title: String
        let style: Style
        var isDisabled: Bool = false
        let action: () -> Void

        enum Style {
            case primary       // Blue bg, white text
            case secondary     // White bg, gray stroke, black text
            case warning       // Red bg, white text
        }

        var bgColor: Color {
            switch style {
            case .primary: return AppColors.buttonPrimaryBg
            case .secondary: return AppColors.card
            case .warning: return AppColors.errorNormal
            }
        }

        var textColor: Color {
            switch style {
            case .primary: return AppColors.buttonPrimaryText
            case .secondary: return AppColors.textPrimary
            case .warning: return AppColors.buttonPrimaryText
            }
        }

        var showStroke: Bool {
            style == .secondary
        }
    }
}

// MARK: - Preview

#Preview("2 Buttons - iPad") {
    VStack {
        Spacer()
        BottomActionBar(buttons: [
            .init(title: "Clear All", style: .secondary, action: {}),
            .init(title: "Done", style: .primary, action: {})
        ])
    }
    .background(AppColors.pageBg)
}

#Preview("3 Buttons") {
    VStack {
        Spacer()
        BottomActionBar(buttons: [
            .init(title: "Cancel", style: .secondary, action: {}),
            .init(title: "Delete", style: .warning, action: {}),
            .init(title: "Confirm", style: .primary, action: {})
        ])
    }
    .background(AppColors.pageBg)
}
