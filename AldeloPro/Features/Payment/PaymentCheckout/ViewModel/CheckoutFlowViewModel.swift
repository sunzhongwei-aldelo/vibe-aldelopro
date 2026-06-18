import Foundation
import CoreGraphics

// MARK: - 结账流程主 ViewModel
/// 驱动整个结账流程的状态机
/// 流程顺序：PaymentResult → TipAndSign → Feedback → Receipt
/// 所有倒计时统一 10s，倒计时到 0 自动前进，点击可暂停
@Observable
final class CheckoutFlowViewModel {
    // MARK: - 配置（注入）
    private let config: CheckoutFlowConfig
    private let paymentInfo: PaymentResultInfo

    // MARK: - 流程状态
    private(set) var currentStep: CheckoutFlowStep = .paymentResult
    private(set) var countdownRemaining: Int = 10
    private(set) var isCountdownPaused: Bool = false

    // MARK: - Tip + 签名状态
    var selectedTip: TipOption? = nil
    var hasSignature: Bool = false
    var signatureStrokes: [[CGPoint]] = []

    // MARK: - 反馈状态
    var feedbackRating: FeedbackRating? = nil

    // MARK: - 收据状态
    var selectedReceipt: ReceiptOption? = nil

    // MARK: - 私有
    private var countdownTimer: Timer?

    // MARK: - 初始化

    init(config: CheckoutFlowConfig, paymentInfo: PaymentResultInfo) {
        self.config = config
        self.paymentInfo = paymentInfo
    }

    // MARK: - 计算属性

    /// 获取流程配置（供视图读取）
    var flowConfig: CheckoutFlowConfig { config }

    /// 获取支付结果信息
    var payment: PaymentResultInfo { paymentInfo }

    /// 小费选项列表（根据配置生成）
    var tipOptions: [TipOption] {
        let amount = paymentInfo.approvedAmount
        return config.tipPercentages.map { pct in
            let tipAmount = amount * Decimal(pct) / 100
            return .percentage(pct, amount: tipAmount)
        }
    }

    /// Continue 按钮是否可用（Tip+Sign 页）
    var canContinueTipSign: Bool {
        let tipReady = !config.showTip || selectedTip != nil
        let signReady = !config.showSignature || hasSignature
        return tipReady && signReady
    }

    /// 当前步骤是否需要显示倒计时
    var showCountdown: Bool {
        currentStep == .paymentResult || currentStep == .receipt
    }

    // MARK: - 流程控制

    /// 前进到下一步
    /// 流程固定顺序：paymentResult → tipAndSign → feedback → receipt
    func advanceToNextStep() {
        stopCountdown()

        switch currentStep {
        case .paymentResult:
            // 支付成功后 → 进入 Tip/Sign（如果配置了）
            if config.showTip || config.showSignature {
                currentStep = .tipAndSign
            } else if config.showFeedback {
                currentStep = .feedback
            } else if config.showReceiptSelection {
                currentStep = .receipt
                startCountdown()
            }

        case .tipAndSign:
            // Tip/Sign 完成后 → 进入反馈（如果配置了）
            if config.showFeedback {
                currentStep = .feedback
            } else if config.showReceiptSelection {
                currentStep = .receipt
                startCountdown()
            }

        case .feedback:
            // 反馈完成后 → 进入收据选择
            if config.showReceiptSelection {
                currentStep = .receipt
                startCountdown()
            }

        case .receipt:
            // 收据选择后 → 流程结束
            dismiss()
        }
    }

    // MARK: - 倒计时

    /// 启动 10 秒倒计时
    func startCountdown() {
        countdownRemaining = 10
        isCountdownPaused = false
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, !self.isCountdownPaused else { return }
            if self.countdownRemaining > 0 {
                self.countdownRemaining -= 1
            } else {
                self.stopCountdown()
                self.advanceToNextStep()
            }
        }
    }

    /// 停止倒计时
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isCountdownPaused = false
    }

    /// 切换暂停/恢复（用户点击倒计时胶囊时调用）
    func toggleCountdownPause() {
        isCountdownPaused.toggle()
    }

    /// 清除签名
    func clearSignature() {
        signatureStrokes.removeAll()
        hasSignature = false
    }

    /// 结束流程（由外部处理 dismiss 逻辑）
    private func dismiss() {
        stopCountdown()
    }

    deinit {
        countdownTimer?.invalidate()
    }
}
