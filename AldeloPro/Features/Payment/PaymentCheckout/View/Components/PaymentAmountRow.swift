import SwiftUI

// MARK: - 金额行
/// 左侧标签 + 右侧金额，支持不同颜色配置
/// 用于 Cash Payment 页的 Balance Due / Tendered / Change Due
struct PaymentAmountRow: View {
    /// 左侧标签文字
    let label: String
    /// 右侧金额文字
    let amount: String
    /// 标签字体
    var labelFont: Font = AppFont.tabletBody3Regular
    /// 金额字体
    var amountFont: Font = AppFont.tabletH4Medium
    /// 金额颜色（可自定义，如找零用蓝色）
    var amountColor: Color = AppColors.textPrimary

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)
                .foregroundColor(labelColor)
            Spacer()
            Text(amount)
                .font(amountFont)
                .foregroundColor(amountColor)
        }
    }

    private var labelColor: Color {
        colorScheme == .dark ? AppColors.textTertiary : AppColors.textMuted
    }
}
