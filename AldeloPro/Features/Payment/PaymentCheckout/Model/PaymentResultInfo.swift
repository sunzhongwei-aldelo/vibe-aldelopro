import Foundation

// MARK: - 支付方式
/// 区分现金和信用卡两种支付结果
enum PaymentMethod: Hashable {
    /// 现金支付：应付、实收、找零
    case cash(balanceDue: Decimal, tenderedAmount: Decimal, changeDue: Decimal)
    /// 信用卡授权：已授权金额
    case credit(approvedAmount: Decimal)
}

// MARK: - 支付结果信息
/// 封装支付完成后的结果数据
struct PaymentResultInfo: Hashable {
    /// 支付方式及金额
    let method: PaymentMethod
    /// 是否已授权成功
    let isApproved: Bool

    /// 便捷获取已授权/已付金额（用于 Tip 页面显示）
    var approvedAmount: Decimal {
        switch method {
        case .cash(let balance, _, _):
            return balance
        case .credit(let amount):
            return amount
        }
    }

    /// 页面标题
    var title: String {
        switch method {
        case .cash: return "Cash Payment"
        case .credit: return "Credit Auth"
        }
    }
}
