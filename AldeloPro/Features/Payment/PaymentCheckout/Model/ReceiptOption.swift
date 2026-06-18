import Foundation

// MARK: - 收据选项
/// 用户可选择的收据发送方式
enum ReceiptOption: String, CaseIterable, Identifiable {
    case email = "Email Receipt"
    case print = "Print Receipt"
    case text = "Text Receipt"
    case none = "No Receipt"

    var id: String { rawValue }

    /// 对应的 SF Symbol 图标名
    var iconName: String {
        switch self {
        case .email: return "envelope"
        case .print: return "printer"
        case .text: return "iphone"
        case .none: return "xmark.rectangle"
        }
    }

    /// 是否为 "不需要收据" 选项（使用蓝色实心按钮样式）
    var isNoReceipt: Bool { self == .none }
}
