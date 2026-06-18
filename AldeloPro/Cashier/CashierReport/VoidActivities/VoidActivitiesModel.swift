import SwiftUI

// MARK: - Void Activities Data

struct VoidActivitiesData {
    let title: String
    let items: [VoidActivityItem]
    let totalAmount: Double

    var totalFormatted: String {
        String(format: "$%.2f", totalAmount)
    }
}

// MARK: - Void Action Type

enum VoidActionType {
    case voidItem
    case voidOrder

    var displayText: String {
        switch self {
        case .voidItem: return "Void Item"
        case .voidOrder: return "Void Order"
        }
    }

    var badgeColor: Color {
        switch self {
        case .voidItem: return AppColors.primaryNormal
        case .voidOrder: return AppColors.successNormal
        }
    }
}

// MARK: - Void Activity Item

struct VoidActivityItem: Identifiable {
    let id: String
    let orderNumber: String
    let voidAction: VoidActionType
    let voidItemName: String
    let itemQty: Int
    let subTotal: Double
    let employee: String
    let manager: String
    let voidReason: String

    var subTotalFormatted: String {
        String(format: "$%.2f", subTotal)
    }
}

// MARK: - Mock Data

extension VoidActivitiesData {
    static let mock = VoidActivitiesData(
        title: "Void Activities",
        items: [
            VoidActivityItem(
                id: "1", orderNumber: "787-261", voidAction: .voidItem,
                voidItemName: "Grilled Chicken", itemQty: 1, subTotal: 10.00,
                employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void"
            ),
            VoidActivityItem(
                id: "2", orderNumber: "787-221", voidAction: .voidItem,
                voidItemName: "Grilled Chicken", itemQty: 1, subTotal: 10.00,
                employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void"
            ),
            VoidActivityItem(
                id: "3", orderNumber: "787-123", voidAction: .voidOrder,
                voidItemName: "All Items", itemQty: 4, subTotal: 100.00,
                employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void"
            ),
            VoidActivityItem(
                id: "4", orderNumber: "787-775", voidAction: .voidOrder,
                voidItemName: "All Items", itemQty: 10, subTotal: 100.00,
                employee: "Mike Smith", manager: "Manager A", voidReason: "System Auto Void"
            )
        ],
        totalAmount: 10200.00
    )
}
