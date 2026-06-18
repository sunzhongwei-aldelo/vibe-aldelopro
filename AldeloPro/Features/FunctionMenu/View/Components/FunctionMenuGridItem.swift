import SwiftUI

// MARK: - 功能菜单单个网格项
/// 显示一个功能入口：圆角矩形彩色图标 + 功能名称
/// 图标 80x80，iPad 标题 18pt medium，iPhone 标题 16pt regular

struct FunctionMenuGridItem: View {
    let item: FunctionMenuItem
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                iconView
                titleView
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 图标视图（80x80 圆角矩形）

    private var iconView: some View {
        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
            .fill(iconColor)
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: item.icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(AppColors.white100)
            )
    }

    // MARK: - 标题视图

    private var titleView: some View {
        Text(item.title)
            .font(hSizeClass == .regular ? AppFont.tabletH5Medium : AppFont.tabletBody5Regular)
            .foregroundColor(titleColor)
            .lineLimit(1)
    }

    // MARK: - 自适应颜色

    /// 标题颜色：暗黑模式白色，浅色模式黑色
    private var titleColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }

    // MARK: - 图标背景色映射（全部取自 DesignTokens）

    private var iconColor: Color {
        switch item.type {
        case .pos:           return AppColors.errorNormal       // 红色
        case .floorPlans:    return AppColors.successNormal     // 绿色
        case .products:      return AppColors.warningNormal     // 橙色
        case .employees:     return AppColors.successDark       // 深绿
        case .customer:      return AppColors.primaryNormal     // 蓝色
        case .marketing:     return AppColors.primaryDark       // 深蓝
        case .inventory:     return AppColors.successNormal     // 绿色
        case .reports:       return AppColors.warningNormal     // 橙色
        case .devices:       return AppColors.textMuted         // 灰色
        case .integrations:  return AppColors.primaryNormal     // 蓝色
        case .marketplace:   return AppColors.primaryDark       // 深蓝
        case .dashboard:     return AppColors.successDark       // 深绿
        case .ePayConnect:   return AppColors.chartCat7         // 粉红
        case .support:       return AppColors.successNormal     // 绿色
        case .settings:      return AppColors.textMuted         // 灰色
        case .timeCard:      return AppColors.warningNormal     // 橙色
        }
    }
}
