import SwiftUI

// MARK: - 结账流程容器视图
/// 状态机驱动页面切换
/// 流程：PaymentResult → TipAndSign → Feedback → Receipt
struct CheckoutFlowContainerView: View {
    @State private var viewModel: CheckoutFlowViewModel
    @State private var signatureViewModel = SignatureCanvasViewModel()

    // MARK: - 初始化

    init(config: CheckoutFlowConfig, paymentInfo: PaymentResultInfo) {
        _viewModel = State(initialValue: CheckoutFlowViewModel(
            config: config,
            paymentInfo: paymentInfo
        ))
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .paymentResult:
                paymentResultContent
            case .tipAndSign:
                tipAndSignContent
            case .feedback:
                feedbackContent
            case .receipt:
                receiptContent
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .onAppear {
            viewModel.startCountdown()
        }
    }

    // MARK: - 支付结果页

    @ViewBuilder
    private var paymentResultContent: some View {
        switch viewModel.payment.method {
        case .cash(let balance, let tendered, let change):
            CashPaymentResultView(
                balanceDue: balance,
                tenderedAmount: tendered,
                changeDue: change,
                countdownSeconds: viewModel.countdownRemaining,
                isPaused: viewModel.isCountdownPaused,
                onTogglePause: { viewModel.toggleCountdownPause() },
                onDone: { viewModel.advanceToNextStep() }
            )
        case .credit(let amount):
            CreditAuthResultView(
                approvedAmount: amount,
                showReceiptButtons: viewModel.flowConfig.showReceiptOnPayment,
                countdownSeconds: viewModel.countdownRemaining,
                isPaused: viewModel.isCountdownPaused,
                onTogglePause: { viewModel.toggleCountdownPause() },
                onDone: { viewModel.advanceToNextStep() },
                onReceipt: { viewModel.advanceToNextStep() },
                onNoReceipt: {
                    viewModel.selectedReceipt = ReceiptOption.none
                    viewModel.advanceToNextStep()
                }
            )
        }
    }

    // MARK: - Tip + 签名页

    private var tipAndSignContent: some View {
        TipSignPageView(
            config: viewModel.flowConfig,
            approvedAmount: viewModel.payment.approvedAmount,
            tipOptions: viewModel.tipOptions,
            selectedTip: $viewModel.selectedTip,
            hasSignature: $viewModel.hasSignature,
            signatureViewModel: signatureViewModel,
            canContinue: viewModel.canContinueTipSign,
            onContinue: { viewModel.advanceToNextStep() }
        )
    }

    // MARK: - 反馈页

    private var feedbackContent: some View {
        FeedbackRatingView(
            rating: $viewModel.feedbackRating,
            onContinue: { viewModel.advanceToNextStep() }
        )
    }

    // MARK: - 收据选择页

    private var receiptContent: some View {
        ReceiptSelectionView(
            selectedReceipt: $viewModel.selectedReceipt,
            countdownSeconds: viewModel.countdownRemaining,
            isPaused: viewModel.isCountdownPaused,
            onTogglePause: { viewModel.toggleCountdownPause() },
            onDone: { viewModel.advanceToNextStep() }
        )
    }
}

// MARK: - Preview

#Preview("Cash → Full Flow") {
    CheckoutFlowContainerView(
        config: .default,
        paymentInfo: PaymentResultInfo(
            method: .cash(balanceDue: 98.00, tenderedAmount: 100.00, changeDue: 2.00),
            isApproved: true
        )
    )
}

#Preview("Credit → Tip Only") {
    CheckoutFlowContainerView(
        config: .tipOnly,
        paymentInfo: PaymentResultInfo(
            method: .credit(approvedAmount: 115.00),
            isApproved: true
        )
    )
}

#Preview("Credit → Signature Only") {
    CheckoutFlowContainerView(
        config: .signatureOnly,
        paymentInfo: PaymentResultInfo(
            method: .credit(approvedAmount: 115.00),
            isApproved: true
        )
    )
}
