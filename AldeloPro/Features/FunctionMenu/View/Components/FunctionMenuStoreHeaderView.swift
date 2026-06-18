import SwiftUI

// MARK: - 功能菜单门店头部视图
/// 显示门店图标、名称、营业状态徽章和门店ID
/// 支持传入自定义图标，暗黑模式下门店名称为白色

struct FunctionMenuStoreHeaderView: View {
    let storeName: String       // 门店名称
    let storeId: String         // 门店 ID
    let isOpen: Bool            // 营业状态
    var storeIcon: Image        // 门店图标（可自定义传入）

    @Environment(\.colorScheme) private var colorScheme

    init(
        storeName: String,
        storeId: String,
        isOpen: Bool = true,
        storeIcon: Image = Image(systemName: "building.2.fill")
    ) {
        self.storeName = storeName
        self.storeId = storeId
        self.isOpen = isOpen
        self.storeIcon = storeIcon
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            storeIconView
            storeInfoView
        }
    }

    // MARK: - 门店图标（圆角矩形）

    private var storeIconView: some View {
        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
            .fill(AppColors.successNormal)
            .frame(width: 40, height: 40)
            .overlay(
                storeIcon
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.white100)
            )
    }

    // MARK: - 门店信息（名称 + 状态 + ID）

    private var storeInfoView: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            // 门店名称
            Text(storeName)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(storeNameColor)
                .lineLimit(1)

            HStack(spacing: Spacing.xs) {
                // 营业状态徽章（绿色=营业，红色=打烊）
                statusBadge
                // 门店 ID（浅灰色）
                Text("ID: \(storeId)")
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - 营业状态徽章

    private var statusBadge: some View {
        Text(isOpen ? "Open" : "Close")
            .font(AppFont.tabletCaption2Regular)
            .foregroundColor(AppColors.white100)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 2)
            .background(isOpen ? AppColors.successNormal : AppColors.errorNormal)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    // MARK: - 自适应颜色

    /// 门店名称颜色：暗黑模式白色，浅色模式黑色
    private var storeNameColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }
}
