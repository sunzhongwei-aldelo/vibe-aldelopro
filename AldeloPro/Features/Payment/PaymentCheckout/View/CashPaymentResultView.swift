import SwiftUI

// MARK: - 现金支付结果页
/// 截图对照：iPad 内容区左右有较大边距（约30%），iPhone 无额外边距
/// 标题栏白色居中，Done 按钮居中，倒计时右侧
struct CashPaymentResultView: View {
    let balanceDue: Decimal
    let tenderedAmount: Decimal
    let changeDue: Decimal
    let countdownSeconds: Int
    let isPaused: Bool
    let onTogglePause: () -> Void
    let onDone: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 标题栏
                titleBar

                // 内容区
                VStack(spacing: 0) {
                    Spacer()

                    // 金额区（iPad 居中窄，iPhone 全宽）
                    amountSection
                        .padding(.horizontal, contentPadding(for: geometry.size.width))

                    Spacer()
                    Spacer()

                    // 底部
                    CheckoutBottomBar(
                        buttonTitle: "Done",
                        isEnabled: true,
                        showCountdown: true,
                        countdownSeconds: countdownSeconds,
                        isPaused: isPaused,
                        onTogglePause: onTogglePause,
                        onAction: onDone
                    )
                }
                .background(AppColors.pageBg)
            }
        }
    }

    // MARK: - 标题栏

    private var titleBar: some View {
        VStack(spacing: 0) {
            Text("Cash Payment")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(titleColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            Rectangle().fill(AppColors.line).frame(height: 1)
        }
        .background(colorScheme == .dark ? AppColors.card : AppColors.white100)
    }

    // MARK: - 金额

    private var amountSection: some View {
        VStack(spacing: Spacing.lg) {
            PaymentAmountRow(
                label: "Balance Due:",
                amount: formatCurrency(balanceDue)
            )
            PaymentAmountRow(
                label: "Tendered Amount:",
                amount: formatCurrency(tenderedAmount)
            )
            PaymentAmountRow(
                label: "Change Due",
                amount: formatCurrency(changeDue),
                labelFont: AppFont.tabletH3Medium,
                amountFont: AppFont.tabletH2Medium,
                amountColor: AppColors.primaryNormal
            )
        }
    }

    // MARK: - 适配

    /// iPad：左右各留约 30% 空白（内容占 40%）；iPhone：仅留 16pt
    private func contentPadding(for containerWidth: CGFloat) -> CGFloat {
        if hSizeClass == .regular {
            return containerWidth * 0.2
        }
        return Spacing.md
    }

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

// MARK: - Preview

#Preview {
    CashPaymentResultView(
        balanceDue: 98.00, tenderedAmount: 100.00, changeDue: 2.00,
        countdownSeconds: 10, isPaused: false,
        onTogglePause: {}, onDone: {}
    )
}
