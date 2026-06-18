import SwiftUI

// MARK: - 共享右侧状态栏
/// 跨页面共享的右侧操作栏，包含订单类型、订单入口和操作按钮
/// 在功能菜单、点餐页、分账页中保持一致，页面切换时不重建

struct SharedRightStatusBar: View {
    var body: some View {
        HStack(spacing: Spacing.md) {
            inStorePill      // 订单类型标签（如 In-Store）
            ordersButton     // 订单入口
            actionButton     // 操作按钮
        }
    }

    // MARK: - 订单类型标签

    private var inStorePill: some View {
        Text("In-Store")
            .font(AppFont.tabletCaption1Regular)
            .foregroundColor(AppColors.white100)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(AppColors.primaryNormal)
            .clipShape(Capsule())
    }

    // MARK: - 订单入口按钮

    private var ordersButton: some View {
        Button(action: {}) {
            Text("Orders")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 操作按钮

    private var actionButton: some View {
        Button(action: {}) {
            Text("Action")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .buttonStyle(.plain)
    }
}
