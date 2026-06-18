import Foundation

// MARK: - Cash Denomination Item

struct CashDenominationItem: Identifiable {
    let id = UUID()
    let denomination: String
    let count: Int
    let totalAmount: Double

    var formattedTotal: String {
        String(format: "$%.2f", totalAmount)
    }

    var countLabel: String {
        "\u{00D7}\(count)"
    }
}

// MARK: - Cash Count Summary

struct CashCountSummary {
    let startAmount: Double
    let actualCashTotal: Double
    let cashOwed: Double

    var formattedStartAmount: String {
        String(format: "$%.2f", startAmount)
    }

    var formattedActualCashTotal: String {
        String(format: "$%.2f", actualCashTotal)
    }

    var formattedCashOwed: String {
        String(format: "$%.2f", cashOwed)
    }
}

// MARK: - Cash Count Data

struct CashCountData {
    let summary: CashCountSummary
    let denominations: [CashDenominationItem]

    var maxAmount: Double {
        denominations.map { $0.totalAmount }.max() ?? 1.0
    }

    static let mock = CashCountData(
        summary: CashCountSummary(
            startAmount: 100.00,
            actualCashTotal: 240.00,
            cashOwed: 140.00
        ),
        denominations: [
            CashDenominationItem(denomination: "1\u{00A2}", count: 40, totalAmount: 0.40),
            CashDenominationItem(denomination: "5\u{00A2}", count: 10, totalAmount: 0.50),
            CashDenominationItem(denomination: "10\u{00A2}", count: 10, totalAmount: 1.00),
            CashDenominationItem(denomination: "25\u{00A2}", count: 10, totalAmount: 2.50),
            CashDenominationItem(denomination: "$1", count: 10, totalAmount: 10.00),
            CashDenominationItem(denomination: "$5", count: 2, totalAmount: 10.00),
            CashDenominationItem(denomination: "$10", count: 2, totalAmount: 20.00),
            CashDenominationItem(denomination: "$20", count: 1, totalAmount: 20.00),
            CashDenominationItem(denomination: "$50", count: 1, totalAmount: 50.00),
            CashDenominationItem(denomination: "$100", count: 1, totalAmount: 100.00)
        ]
    )
}
