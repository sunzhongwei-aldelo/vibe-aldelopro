import Foundation

// MARK: - Gratuity Summary Data

struct GratuitySummaryData {
    let chartItems: [RevenueLineItem]
    let summary: GratuitySummarySummary
}

// MARK: - Summary (right panel)

struct GratuitySummarySummary {
    let tipsAdded: Double
    let orderGratuity: Double
    let tipFee: Double
    let bankSurcharge: Double
    let gratuityPayable: Double
    let gratuityPaid: Double
    let gratuityBalance: Double

    var tipsAddedFormatted: String { formatCurrency(tipsAdded) }
    var orderGratuityFormatted: String { formatCurrency(orderGratuity) }
    var tipFeeFormatted: String { formatCurrency(tipFee) }
    var bankSurchargeFormatted: String { formatCurrency(bankSurcharge) }
    var gratuityPayableFormatted: String { formatCurrency(gratuityPayable) }
    var gratuityPaidFormatted: String { formatCurrency(gratuityPaid) }
    var gratuityBalanceFormatted: String { formatCurrency(gratuityBalance) }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Detail metadata

extension GratuitySummaryData {
    /// Screen title for the full-page overview, matching `GratuitySummaryDetail.svg`.
    var detailTitle: String { "Gratuity Summary Overview" }
}

// MARK: - Mock Data

extension GratuitySummaryData {
    /// Full-page overview detail mock matching `GratuitySummaryDetail.svg`.
    static let overviewDetailMock = GratuitySummaryData(
        chartItems: [
            RevenueLineItem(label: "Masa e-Gift Card", amount: 135.26),
            RevenueLineItem(label: "MasterCard", amount: 51.12),
            RevenueLineItem(label: "Masa Reward Card", amount: 29.07),
            RevenueLineItem(label: "Debit Card", amount: 19.19),
            RevenueLineItem(
                label: "Gratuities Payable at other\ncashier / Server bank",
                amount: -2.54
            )
        ],
        summary: GratuitySummarySummary(
            tipsAdded: 232.09,
            orderGratuity: 9.83,
            tipFee: -13.55,
            bankSurcharge: -21.18,
            gratuityPayable: 207.19,
            gratuityPaid: 0.00,
            gratuityBalance: 207.19
        )
    )

    static let mock = GratuitySummaryData(
        chartItems: [
            RevenueLineItem(label: "Masa E-Gift Card", amount: 135.26),
            RevenueLineItem(label: "MasterCard", amount: 51.12),
            RevenueLineItem(label: "Masa Reward Card", amount: 29.07),
            RevenueLineItem(label: "Debit Card", amount: 19.19),
            RevenueLineItem(
                label: "Gratuities Payable At Other\nCashier / Server Bank",
                amount: -2.54
            )
        ],
        summary: GratuitySummarySummary(
            tipsAdded: 232.09,
            orderGratuity: 9.83,
            tipFee: -13.55,
            bankSurcharge: -21.18,
            gratuityPayable: 207.19,
            gratuityPaid: 0.00,
            gratuityBalance: 207.19
        )
    )
}
