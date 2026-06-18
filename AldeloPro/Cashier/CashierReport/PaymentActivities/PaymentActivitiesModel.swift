import SwiftUI

// MARK: - Payment Activities Data Model

struct PaymentActivitiesData {
    let title: String
    let rows: [PaymentActivityRow]
    let summary: PaymentActivitiesSummary
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

// MARK: - Table Row

struct PaymentActivityRow: Identifiable {
    let id: String
    let time: String
    let orderNumber: String
    let tenderTitle: String
    let tenderSubtitle: String?
    let payment: Double
    let tipAmount: Double
    let total: Double

    var paymentFormatted: String { formatCurrency(payment) }
    var tipAmountFormatted: String { formatCurrency(tipAmount) }
    var totalFormatted: String { formatCurrency(total) }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Summary

struct PaymentActivitiesSummary {
    let orderPayment: Double
    let orderRefunds: Double
    let tip: Double
    let totalOrderPayment: Double
    let refunds: Double
    let netPayments: Double

    var orderPaymentFormatted: String { formatCurrency(orderPayment) }
    var orderRefundsFormatted: String { formatCurrency(orderRefunds) }
    var tipFormatted: String { formatCurrency(tip) }
    var totalOrderPaymentFormatted: String { formatCurrency(totalOrderPayment) }
    var refundsFormatted: String { formatCurrency(refunds) }
    var netPaymentsFormatted: String { formatCurrency(netPayments) }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Table Column Definition

struct PaymentActivityColumn: Identifiable {
    let id: String
    let title: String
    let keyPath: (PaymentActivityRow) -> String
    let hasTwoLines: Bool

    init(id: String, title: String, hasTwoLines: Bool = false, keyPath: @escaping (PaymentActivityRow) -> String) {
        self.id = id
        self.title = title
        self.hasTwoLines = hasTwoLines
        self.keyPath = keyPath
    }
}

// MARK: - Mock Data

extension PaymentActivitiesData {
    /// 23 rows so the table spans multiple pages (10 rows / page → 3 pages).
    static let mock = PaymentActivitiesData(
        title: "Payment Activities",
        rows: makeMockRows(count: 23),
        summary: PaymentActivitiesSummary(
            orderPayment: 53972.61,
            orderRefunds: -2.30,
            tip: 0.00,
            totalOrderPayment: 53970.31,
            refunds: -49.54,
            netPayments: 53970.31
        ),
        totalCount: 23,
        currentPage: 1,
        totalPages: 3
    )

    /// Generates varied, deterministic mock rows that cycle through the
    /// tender/refund patterns seen in the design.
    private static func makeMockRows(count: Int) -> [PaymentActivityRow] {
        let patterns: [(tender: String, subtitle: String?)] = [
            ("MasterCard xxxx4422", "PMT: E9C18C6A-05FB-4536-BBB1-E36637466743"),
            ("Cash", nil),
            ("Refund - MasterCard xxxx1234", "PMT: 7B2D91A4-1C8E-4F02-A6D5-9E13C8B47A20"),
            ("Refund - Cash", nil),
            ("Visa xxxx9087", "PMT: 3F19C7E2-08AB-4D55-9C31-A2E6471B8D90"),
            ("Amex xxxx3311", "PMT: 5A8B2C1D-77E0-4933-B1F4-6D90C3E2A148")
        ]
        let times = ["10:42 AM", "11:18 AM", "01:59 PM", "03:41 PM", "05:07 PM", "06:23 PM", "07:55 PM"]

        return (1...count).map { index in
            let pattern = patterns[(index - 1) % patterns.count]
            let isRefund = pattern.tender.hasPrefix("Refund")
            let payment = Double((index * 137) % 4200) / 100.0 + 1.99
            let tip = isRefund ? 0.0 : Double((index * 53) % 500) / 100.0
            let signedPayment = isRefund ? -payment : payment
            let total = signedPayment + tip
            let order = isRefund && index % 4 == 0 ? "-" : "787-\(200 + index)"

            return PaymentActivityRow(
                id: "\(index)",
                time: "2022-12-30 \(times[(index - 1) % times.count])",
                orderNumber: order,
                tenderTitle: pattern.tender,
                tenderSubtitle: pattern.subtitle,
                payment: signedPayment,
                tipAmount: tip,
                total: total
            )
        }
    }
}
