import Foundation

// MARK: - 结账流程步骤
/// 有限状态机驱动的步骤枚举
/// 容器视图根据当前步骤切换展示内容
enum CheckoutFlowStep: Hashable {
    /// 支付结果展示（现金找零 / 信用卡授权成功）
    case paymentResult
    /// 小费选择 + 签名（根据配置组合展示）
    case tipAndSign
    /// 满意度反馈（👍 / 👎）
    case feedback
    /// 收据选择（Email / Print / Text / No Receipt）
    case receipt
}

// MARK: - 满意度评分
enum FeedbackRating: Hashable {
    case thumbsUp
    case thumbsDown
}
