import SwiftUI

// MARK: - 功能菜单顶部状态栏布局
/// 包含：左侧门店信息 + 中间语音搜索栏 + 右侧共享操作栏
/// iPad 显示完整三段式布局，iPhone 仅显示门店信息和操作栏

struct FunctionMenuStatusBarLayout: View {
    let storeName: String       // 门店名称
    let storeId: String         // 门店 ID
    let isStoreOpen: Bool       // 营业状态

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        HStack(spacing: Spacing.md) {
            // 左侧：门店信息
            FunctionMenuStoreHeaderView(
                storeName: storeName,
                storeId: storeId,
                isOpen: isStoreOpen
            )

            if hSizeClass == .regular {
                Spacer()
                // 中间：语音搜索栏（仅 iPad 显示）
                searchBar
                Spacer()
            } else {
                Spacer()
            }

            // 右侧：共享操作栏（跨页面保持一致）
            SharedRightStatusBar()
        }
        .frame(height: 56)
        .padding(.horizontal, Spacing.md)
        .background(AppColors.card)
    }

    // MARK: - 语音搜索栏

    private var searchBar: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "mic.fill")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textMuted)
            Text("Hey Aldelo, how can I help?")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.inputPlaceholder)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(AppColors.inputBg)
        .clipShape(Capsule())
    }
}
