import Foundation

// MARK: - 结账流程配置
/// 控制结账流程中各步骤的显示与行为
/// 由业务层根据商户设置创建，传入 ViewModel
struct CheckoutFlowConfig {
    /// 是否显示小费选择
    let showTip: Bool
    /// 是否显示签名板
    let showSignature: Bool
    /// 是否显示满意度评分（How did we do?）
    let showFeedback: Bool
    /// 是否显示收据选择页
    let showReceiptSelection: Bool
    /// 是否在支付结果页直接显示 Receipt / No Receipt 按钮
    let showReceiptOnPayment: Bool
    /// 预设小费比例（如 [15, 10, 5]）
    let tipPercentages: [Int]
    /// 自动跳转倒计时秒数
    let countdownSeconds: Int

    // MARK: - 便捷初始化

    /// 默认配置：Tip + 签名 + 反馈 + 收据
    static let `default` = CheckoutFlowConfig(
        showTip: true,
        showSignature: true,
        showFeedback: true,
        showReceiptSelection: true,
        showReceiptOnPayment: false,
        tipPercentages: [15, 10, 5],
        countdownSeconds: 10
    )

    /// 仅 Tip（无签名）
    static let tipOnly = CheckoutFlowConfig(
        showTip: true,
        showSignature: false,
        showFeedback: false,
        showReceiptSelection: true,
        showReceiptOnPayment: false,
        tipPercentages: [15, 10, 5],
        countdownSeconds: 10
    )

    /// 仅签名（无 Tip）
    static let signatureOnly = CheckoutFlowConfig(
        showTip: false,
        showSignature: true,
        showFeedback: false,
        showReceiptSelection: true,
        showReceiptOnPayment: false,
        tipPercentages: [],
        countdownSeconds: 10
    )
}
