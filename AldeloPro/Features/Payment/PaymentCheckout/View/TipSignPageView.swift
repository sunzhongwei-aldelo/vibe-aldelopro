import SwiftUI

// MARK: - Tip + 签名组合页
/// 签名区自动扩展填满剩余空间，Continue 按钮固定在底部
/// 按钮与签名区间距 = Spacing.md（与标题到内容间距一致）
struct TipSignPageView: View {
    let config: CheckoutFlowConfig
    let approvedAmount: Decimal
    let tipOptions: [TipOption]

    @Binding var selectedTip: TipOption?
    @Binding var hasSignature: Bool
    @Bindable var signatureViewModel: SignatureCanvasViewModel
    let canContinue: Bool
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            // 顶部信息栏
            CheckoutHeaderBar(
                title: headerTitle,
                approvedAmount: approvedAmount
            )

            // 内容区：签名自动扩展，按钮固定底部
            VStack(spacing: Spacing.md) {
                if config.showTip {
                    TipOptionsGrid(
                        options: tipOptions,
                        selectedTip: $selectedTip
                    )
                }

                if config.showSignature {
                    SignaturePadView(
                        canvasViewModel: signatureViewModel,
                        hasSignature: $hasSignature
                    )
                    .frame(maxHeight: .infinity)
                    .frame(minHeight: signatureMinHeight)
                }

                // Continue 按钮（间距 = Spacing.md，与标题到内容一致）
                CheckoutBottomBar(
                    buttonTitle: "Continue",
                    isEnabled: canContinue,
                    showCountdown: false,
                    onAction: onContinue
                )
            }
            .padding(.horizontal, contentPadding)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)
        }
        .background(AppColors.pageBg)
    }

    // MARK: - 适配

    private var headerTitle: String {
        config.showTip ? "Please Select Tip Option" : "Please Sign Here"
    }

    /// 签名区最小高度
    private var signatureMinHeight: CGFloat {
        hSizeClass == .regular ? 160 : 120
    }

    /// iPad 有左右边距，iPhone 无
    private var contentPadding: CGFloat {
        hSizeClass == .regular ? Spacing.xl : Spacing.md
    }
}

// MARK: - Preview

#Preview("Tip + Signature") {
    @Previewable @State var tip: TipOption? = nil
    @Previewable @State var hasSig = false
    TipSignPageView(
        config: .default,
        approvedAmount: 115.00,
        tipOptions: [.percentage(15, amount: 17.25), .percentage(10, amount: 11.50), .percentage(5, amount: 5.75)],
        selectedTip: $tip, hasSignature: $hasSig,
        signatureViewModel: SignatureCanvasViewModel(),
        canContinue: false, onContinue: {}
    )
}

#Preview("Signature Only") {
    @Previewable @State var tip: TipOption? = nil
    @Previewable @State var hasSig = false
    TipSignPageView(
        config: .signatureOnly,
        approvedAmount: 115.00,
        tipOptions: [],
        selectedTip: $tip, hasSignature: $hasSig,
        signatureViewModel: SignatureCanvasViewModel(),
        canContinue: false, onContinue: {}
    )
}

