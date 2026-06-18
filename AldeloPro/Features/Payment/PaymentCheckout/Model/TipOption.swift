import Foundation

// MARK: - 小费选项
/// 表示用户可选择的小费类型
enum TipOption: Hashable, Identifiable {
    /// 固定百分比（如 15%），附带计算后的金额
    case percentage(Int, amount: Decimal)
    /// 不给小费
    case noTip
    /// 自定义金额
    case custom(Decimal)

    var id: String {
        switch self {
        case .percentage(let pct, _): return "pct_\(pct)"
        case .noTip: return "no_tip"
        case .custom(let amt): return "custom_\(amt)"
        }
    }

    /// 显示标题（如 "15%"、"No Tip"、"Custom"）
    var displayTitle: String {
        switch self {
        case .percentage(let pct, _): return "\(pct)%"
        case .noTip: return "No Tip"
        case .custom: return "Custom"
        }
    }

    /// 显示副标题金额（如 "+$5.00"）
    var displaySubtitle: String? {
        switch self {
        case .percentage(_, let amount):
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            formatter.minimumFractionDigits = 2
            return "+\(formatter.string(from: amount as NSDecimalNumber) ?? "")"
        case .noTip, .custom:
            return nil
        }
    }
}
