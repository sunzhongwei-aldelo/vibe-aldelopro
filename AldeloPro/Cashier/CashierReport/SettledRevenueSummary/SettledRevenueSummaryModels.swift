import Foundation

// MARK: - Revenue Line Item

struct RevenueLineItem: Identifiable {
    let id = UUID()
    let label: String
    let amount: Double
    let subtitle: String?
    let isNegative: Bool

    var formattedAmount: String {
        let absAmount = abs(amount)
        let formatted = String(format: "$%.2f", absAmount)
        return isNegative ? "(\(formatted))" : formatted
    }

    init(label: String, amount: Double, subtitle: String? = nil) {
        self.label = label
        self.amount = amount
        self.subtitle = subtitle
        self.isNegative = amount < 0
    }
}

// MARK: - Revenue Summary Section

struct RevenueSummarySection: Identifiable {
    let id = UUID()
    let items: [RevenueLineItem]
    let totalLabel: String
    let totalAmount: Double

    var formattedTotal: String {
        String(format: "$%.2f", totalAmount)
    }
}

// MARK: - Settled Revenue Summary Data

struct SettledRevenueSummaryData {
    let upperSection: RevenueSummarySection
    let lowerSection: RevenueSummarySection

    static let mock = SettledRevenueSummaryData(
        upperSection: RevenueSummarySection(
            items: [
                RevenueLineItem(label: "All Categories Sales", amount: 2215.93),
                RevenueLineItem(label: "Non-Inclusive Taxes Collected", amount: 1429.65),
                RevenueLineItem(label: "Order Surcharges", amount: 1244.25),
                RevenueLineItem(label: "Delivery Charges", amount: 496.25),
                RevenueLineItem(label: "Order Gratuities Collected", amount: 9.83),
                RevenueLineItem(label: "Total Tips Added", amount: 248.67),
                RevenueLineItem(label: "Rounding", amount: 20.54),
                RevenueLineItem(label: "Order Discounts", amount: -263.49),
                RevenueLineItem(label: "Total Order Refunds", amount: -1235.75),
                RevenueLineItem(label: "Total Gratuities Payable", amount: -223.11),
                RevenueLineItem(label: "Total Credit Card Cash Discount", amount: -96.43)
            ],
            totalLabel: "Total Settled Revenue",
            totalAmount: 2242.70
        ),
        lowerSection: RevenueSummarySection(
            items: [
                RevenueLineItem(
                    label: "Gift Cards Sold",
                    amount: 41370.00,
                    subtitle: "(Face Value: $41,370.00)"
                ),
                RevenueLineItem(
                    label: "Store Credit Issued",
                    amount: 10200.00,
                    subtitle: "(Face Value: $10,200.00)"
                ),
                RevenueLineItem(
                    label: "Settled At Other Cashiers /\nServer Banks",
                    amount: 157.61
                ),
                RevenueLineItem(label: "Driver Compensations", amount: -42.00)
            ],
            totalLabel: "Net Settled Revenue",
            totalAmount: 53928.31
        )
    )
}
