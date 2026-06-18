import SwiftUI

// MARK: - Tip 选项卡片
/// 截图对照：高度约 120pt，圆角 16pt
/// 选中态：浅蓝背景 + 蓝色虚线描边
/// 未选中态：白色背景 + 浅灰描边
struct TipOptionCard: View {
    let option: TipOption
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(option.displayTitle)
                    .font(hSizeClass == .regular ? AppFont.tabletH2Medium : AppFont.tabletH3Medium)
                    .foregroundColor(titleColor)
                if let subtitle = option.displaySubtitle {
                    Text(subtitle)
                        .font(hSizeClass == .regular ? AppFont.tabletBody3Regular : AppFont.tabletBody4Regular)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: hSizeClass == .regular ? 120 : 80)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: Color {
        if isSelected { return AppColors.primaryLight }
        return colorScheme == .dark ? AppColors.card : AppColors.white100
    }

    private var borderColor: Color {
        isSelected ? AppColors.optionSelectedStroke : AppColors.optionUnselectedStroke
    }

    private var titleColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }
}
