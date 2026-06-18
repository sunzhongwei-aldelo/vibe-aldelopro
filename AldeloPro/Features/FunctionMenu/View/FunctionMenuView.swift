import SwiftUI

// MARK: - 功能菜单主视图
/// 整个功能菜单页面的容器，包含顶部状态栏、网格内容和底部品牌标识
/// 纯函数式设计：相同输入产生相同输出，无副作用

struct FunctionMenuView: View {
    @State private var viewModel: FunctionMenuViewModel

    init(viewModel: FunctionMenuViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 顶部状态栏（门店信息 + 搜索 + 右侧操作区）
            FunctionMenuStatusBarLayout(
                storeName: viewModel.storeName,
                storeId: viewModel.storeId,
                isStoreOpen: viewModel.isStoreOpen
            )

            // 功能网格（自适应列数，可滚动）
            FunctionMenuGridView(
                items: viewModel.menuItems,
                onItemTap: viewModel.selectMenuItem
            )

            // 底部品牌标识
            brandingFooter
        }
        .background(AppColors.pageBg)
    }

    // MARK: - 底部品牌标识

    private var brandingFooter: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryNormal)
            Text("Aldelo Pro")
                .font(AppFont.tabletH5Medium)
                .foregroundColor(AppColors.textTertiary) // 浅灰色，Asset Catalog 自适应暗黑模式
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - 预览

#Preview {
    FunctionMenuView(viewModel: FunctionMenuViewModel())
}
