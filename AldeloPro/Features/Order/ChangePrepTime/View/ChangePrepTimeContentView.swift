//
//  ChangePrepTimeContentView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/08.
//

import SwiftUI

// MARK: - 自定义备餐时间主页面

/// 修改备餐时间的完整页面容器
/// 自适应网格布局：iPad/横屏 5 列，iPhone 竖屏 3 列
/// 包含顶部导航栏 + 时间选项网格
struct ChangePrepTimeContentView: View {
    @State private var viewModel: ChangePrepTimeViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(viewModel: ChangePrepTimeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// 网格列数：Compact 环境 3 列，Regular 环境 5 列
    private var columnCount: Int {
        horizontalSizeClass == .compact ? 3 : 5
    }

    /// 网格列定义
    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: Spacing.md),
            count: columnCount
        )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 顶部导航栏（迁移至通用 AldeloModalHeaderView，含 AI 中心搜索条）
                AldeloModalHeaderView(
                    leadingIcon: "clock",
                    title: "Custom Prep Time",
                    actions: [
                        .back({ viewModel.goBack() }),
                        .primary("Confirm", action: { viewModel.confirm() })
                    ],
                    aiState: .idle
                )

                Divider().foregroundColor(AppColors.line)

                // 时间选项网格内容区
                gridContent(screenWidth: geometry.size.width)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pageBg)
    }

    // MARK: - 网格内容

    /// 可滚动的时间选项网格
    private func gridContent(screenWidth: CGFloat) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // 提示文本
                Text("Select a prep time")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textSecondary)

                // 自适应网格（每个卡片显示时长+目标时间）
                LazyVGrid(columns: gridColumns, spacing: Spacing.md) {
                    ForEach(viewModel.options) { option in
                        ChangePrepTimeGridCard(
                            option: option,
                            formattedTime: viewModel.formattedTime(for: option),
                            isSelected: viewModel.isSelected(option),
                            onTap: { viewModel.selectOption(option) }
                        )
                    }
                }
            }
            .padding(.horizontal, gridPadding(for: screenWidth))
            .padding(.top, Spacing.lg)
        }
    }

    // MARK: - 自适应边距

    /// 根据屏幕宽度计算网格水平内边距
    /// iPad 按 Figma 1440px 基准等比缩放，iPhone 使用固定值
    private func gridPadding(for screenWidth: CGFloat) -> CGFloat {
        if horizontalSizeClass == .compact {
            return Spacing.lg
        }
        // iPad: 按 Figma 设计稿 1440px 基准等比计算
        return (170.0 / 1440.0) * screenWidth
    }
}

// MARK: - Preview 预览

#Preview("自定义备餐时间") {
    ChangePrepTimeContentView(
        viewModel: ChangePrepTimeViewModel(
            baseTime: {
                var cal = Calendar.current
                cal.timeZone = .current
                return cal.date(
                    from: DateComponents(hour: 10, minute: 0)
                ) ?? Date()
            }()
        )
    )
}
