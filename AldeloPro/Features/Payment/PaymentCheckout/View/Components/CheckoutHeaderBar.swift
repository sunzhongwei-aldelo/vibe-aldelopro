import SwiftUI

// MARK: - 结账页面顶部栏
/// 左侧标题 + 右侧 "✅ Approved: $xxx" 状态
/// 用于 Tip/Sign 页和 Signature Only 页
struct CheckoutHeaderBar: View {
    /// 左侧标题文字
    let title: String
    /// 已授权金额（右侧显示）
    let approvedAmount: Decimal?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(titleColor)

            Spacer()

            if let amount = approvedAmount {
                approvedBadge(amount: amount)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - 子视图

    /// 右侧 "✅ Approved: $115.00"
    private func approvedBadge(amount: Decimal) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.successNormal)
                .font(.system(size: 18))
            Text("Approved:")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.successNormal)
            Text(formatCurrency(amount))
                .font(AppFont.tabletH4Medium)
                .foregroundColor(titleColor)
        }
    }

    // MARK: - 辅助

    private var titleColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}
