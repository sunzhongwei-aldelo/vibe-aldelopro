import SwiftUI

// MARK: - 信用卡授权结果页
/// Approved 居中显示 + 底部按钮
struct CreditAuthResultView: View {
    let approvedAmount: Decimal
    let showReceiptButtons: Bool
    let countdownSeconds: Int
    let isPaused: Bool
    let onTogglePause: () -> Void
    let onDone: () -> Void
    let onReceipt: () -> Void
    let onNoReceipt: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            titleBar

            VStack(spacing: 0) {
                Spacer()

                // Approved 状态
                VStack(spacing: Spacing.lg) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.successNormal)
                        Text("Approved")
                            .font(AppFont.tabletH1Medium)
                            .foregroundColor(AppColors.successNormal)
                    }
                    Text(formatCurrency(approvedAmount))
                        .font(AppFont.tabletDisplay3Semibold)
                        .foregroundColor(amountColor)
                }

                Spacer()
                Spacer()

                // 底部
                if showReceiptButtons {
                    receiptButtons
                } else {
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
            }
            .background(AppColors.pageBg)
        }
    }

    // MARK: - 标题栏

    private var titleBar: some View {
        VStack(spacing: 0) {
            Text("Credit Auth")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(titleColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
            Rectangle().fill(AppColors.line).frame(height: 1)
        }
        .background(colorScheme == .dark ? AppColors.card : AppColors.white100)
    }

    // MARK: - Receipt 双按钮 + 倒计时

    private var receiptButtons: some View {
        HStack(alignment: .center) {
            Color.clear.frame(width: 70, height: 1)
            Spacer()

            HStack(spacing: Spacing.md) {
                Button(action: onNoReceipt) {
                    Text("No Receipt")
                        .font(AppFont.tabletButton4Medium)
                        .foregroundColor(titleColor)
                        .frame(width: 180, height: 56)
                        .background(colorScheme == .dark ? AppColors.card : AppColors.white100)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
                Button(action: onReceipt) {
                    Text("Receipt")
                        .font(AppFont.tabletButton4Medium)
                        .foregroundColor(AppColors.white100)
                        .frame(width: 180, height: 56)
                        .background(AppColors.primaryNormal)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
            }

            Spacer()
            CountdownBadge(seconds: countdownSeconds, isPaused: isPaused, onTogglePause: onTogglePause)
                .frame(width: 70)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }

    // MARK: - 辅助

    private var titleColor: Color { colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary }
    private var amountColor: Color { colorScheme == .dark ? AppColors.white100 : AppColors.textEmphasis }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview("Done") {
    CreditAuthResultView(
        approvedAmount: 115.00, showReceiptButtons: false,
        countdownSeconds: 3, isPaused: false, onTogglePause: {},
        onDone: {}, onReceipt: {}, onNoReceipt: {}
    )
}

#Preview("Receipt Buttons") {
    CreditAuthResultView(
        approvedAmount: 115.00, showReceiptButtons: true,
        countdownSeconds: 3, isPaused: false, onTogglePause: {},
        onDone: {}, onReceipt: {}, onNoReceipt: {}
    )
}
