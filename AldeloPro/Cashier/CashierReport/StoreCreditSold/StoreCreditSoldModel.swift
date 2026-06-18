import Foundation

// MARK: - Store Credit Sold Data

struct StoreCreditSoldData {
    let title: String
    let rows: [StoreCreditRow]
    let faceValueTotal: Double
    let paidAmountTotal: Double

    var faceValueTotalFormatted: String { CurrencyFormat.grouped(faceValueTotal) }
    var paidAmountTotalFormatted: String { CurrencyFormat.grouped(paidAmountTotal) }
}

// MARK: - Currency formatting helper

/// Shared currency formatter for thousands-grouped USD amounts (e.g. "$41,370.00"),
/// matching the totals shown in the Store Credit Sold detail design.
enum CurrencyFormat {
    static func grouped(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let number = NSNumber(value: abs(value))
        let body = formatter.string(from: number) ?? String(format: "%.2f", abs(value))
        return value < 0 ? "($\(body))" : "$\(body)"
    }
}

// MARK: - Table Row

struct StoreCreditRow: Identifiable {
    let id: String
    let storeCredit: String
    let count: Int
    let faceValue: Double
    let paidAmount: Double

    var faceValueFormatted: String { CurrencyFormat.grouped(faceValue) }
    var paidAmountFormatted: String { CurrencyFormat.grouped(paidAmount) }
}

// MARK: - Mock Data

extension StoreCreditSoldData {
    /// Full-page records detail mock matching `StoreCreditSoldDetail.svg` (8 rows).
    static let recordsDetailMock = StoreCreditSoldData(
        title: "Store Credit Sold Records",
        rows: [
            StoreCreditRow(id: "1", storeCredit: "Store Credit 1", count: 9, faceValue: 10.00, paidAmount: 370.00),
            StoreCreditRow(id: "2", storeCredit: "Store Credit 2", count: 5, faceValue: 20.00, paidAmount: 400.00),
            StoreCreditRow(id: "3", storeCredit: "Store Credit 3", count: 32, faceValue: 100.00, paidAmount: 700.00),
            StoreCreditRow(id: "4", storeCredit: "Store Credit 4", count: 1, faceValue: 50.00, paidAmount: 450.00),
            StoreCreditRow(id: "5", storeCredit: "Store Credit 5", count: 2, faceValue: 5.00, paidAmount: 50.00),
            StoreCreditRow(id: "6", storeCredit: "Store Credit 6", count: 2, faceValue: 5.00, paidAmount: 50.00),
            StoreCreditRow(id: "7", storeCredit: "Store Credit 7", count: 2, faceValue: 5.00, paidAmount: 50.00),
            StoreCreditRow(id: "8", storeCredit: "Store Credit 8", count: 5, faceValue: 5.00, paidAmount: 50.00)
        ],
        faceValueTotal: 200.00,
        paidAmountTotal: 41370.00
    )

    static let mock = StoreCreditSoldData(
        title: "Store Credit Sold",
        rows: [
            StoreCreditRow(id: "1", storeCredit: "Store Credit 1", count: 9, faceValue: 10.00, paidAmount: 370.00),
            StoreCreditRow(id: "2", storeCredit: "Store Credit 2", count: 5, faceValue: 20.00, paidAmount: 400.00),
            StoreCreditRow(id: "3", storeCredit: "Store Credit 3", count: 32, faceValue: 100.00, paidAmount: 700.00),
            StoreCreditRow(id: "4", storeCredit: "Store Credit 4", count: 1, faceValue: 50.00, paidAmount: 450.00),
            StoreCreditRow(id: "5", storeCredit: "Store Credit 5", count: 2, faceValue: 5.00, paidAmount: 50.00)
        ],
        faceValueTotal: 200.00,
        paidAmountTotal: 41370.00
    )
}
