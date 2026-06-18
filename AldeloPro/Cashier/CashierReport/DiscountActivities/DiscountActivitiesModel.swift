import Foundation

// MARK: - Discount Activities Data

struct DiscountActivitiesData {
    let title: String
    let sections: [DiscountSection]
    let totalAmount: Double

    var totalFormatted: String {
        let absValue = abs(totalAmount)
        let formatted = String(format: "$%.2f", absValue)
        return totalAmount < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Discount Section (expandable)

struct DiscountSection: Identifiable {
    let id: String
    let name: String
    let discountCount: Int
    let discountsTotal: Double
    let orders: [DiscountOrderRow]

    var discountsTotalFormatted: String {
        let absValue = abs(discountsTotal)
        let formatted = String(format: "$%.2f", absValue)
        return discountsTotal < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Discount Order Row

struct DiscountOrderRow: Identifiable {
    let id: String
    let orderNumber: String
    let discountAmount: Double

    var discountAmountFormatted: String {
        let absValue = abs(discountAmount)
        let formatted = String(format: "$%.2f", absValue)
        return discountAmount < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Mock Data

extension DiscountActivitiesData {
    /// Full-page records detail mock matching `DiscountActivitiesDetail.svg`.
    /// Title carries the "Records" suffix used on the detail screen.
    static let recordsDetailMock = DiscountActivitiesData(
        title: "Discount Activities Records",
        sections: [
            DiscountSection(
                id: "1", name: "Discount 1", discountCount: 1, discountsTotal: -236.89,
                orders: [
                    DiscountOrderRow(id: "1-1", orderNumber: "787-101", discountAmount: -236.89)
                ]
            ),
            DiscountSection(
                id: "2", name: "Discount 2", discountCount: 3, discountsTotal: -100.00,
                orders: [
                    DiscountOrderRow(id: "2-1", orderNumber: "787-101", discountAmount: -236.89),
                    DiscountOrderRow(id: "2-2", orderNumber: "787-101", discountAmount: -236.89),
                    DiscountOrderRow(id: "2-3", orderNumber: "787-101", discountAmount: -236.89)
                ]
            ),
            DiscountSection(
                id: "3", name: "Discount 3", discountCount: 1, discountsTotal: -236.89,
                orders: [
                    DiscountOrderRow(id: "3-1", orderNumber: "787-101", discountAmount: -236.89)
                ]
            )
        ],
        totalAmount: -263.49
    )

    static let mock = DiscountActivitiesData(
        title: "Discount Activities",
        sections: [
            DiscountSection(
                id: "1", name: "Discount 1", discountCount: 1, discountsTotal: -236.89,
                orders: [
                    DiscountOrderRow(id: "1-1", orderNumber: "787-101", discountAmount: -236.89)
                ]
            ),
            DiscountSection(
                id: "2", name: "Discount 2", discountCount: 3, discountsTotal: -100.00,
                orders: [
                    DiscountOrderRow(id: "2-1", orderNumber: "787-101", discountAmount: -236.89),
                    DiscountOrderRow(id: "2-2", orderNumber: "787-101", discountAmount: -236.89),
                    DiscountOrderRow(id: "2-3", orderNumber: "787-101", discountAmount: -236.89)
                ]
            ),
            DiscountSection(
                id: "3", name: "Discount 3", discountCount: 1, discountsTotal: -236.89,
                orders: [
                    DiscountOrderRow(id: "3-1", orderNumber: "787-101", discountAmount: -236.89)
                ]
            )
        ],
        totalAmount: -263.49
    )
}
