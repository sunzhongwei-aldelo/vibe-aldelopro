import SwiftUI

// MARK: - Cashier Summary Data Model

struct CashierSummaryData {
    let title: String
    let centerLabel: String
    let centerSubLabel: String
    let centerAmount: Double
    let items: [CashierSummaryItem]

    var centerAmountFormatted: String {
        formatCurrency(centerAmount)
    }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Summary Item

struct CashierSummaryItem: Identifiable {
    let id: String
    let label: String
    let amount: Double
    let color: Color

    var amountFormatted: String {
        let absValue = abs(amount)
        let formatted = String(format: "$%.2f", absValue)
        return amount < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Mock Data

extension CashierSummaryData {
    static let mock = CashierSummaryData(
        title: "Server Bank Summary",
        centerLabel: "Cash Owed",
        centerSubLabel: "To Employee",
        centerAmount: -400.00,
        items: [
            CashierSummaryItem(
                id: "net_payments",
                label: "Net Payments",
                amount: 4444.63,
                color: AppColors.chartCat1
            ),
            CashierSummaryItem(
                id: "begin_cash_expected",
                label: "Begin Cash Expected",
                amount: 0.00,
                color: AppColors.chartCat2
            ),
            CashierSummaryItem(
                id: "safe_drop",
                label: "Safe Drop",
                amount: 0.00,
                color: AppColors.chartCat3
            ),
            CashierSummaryItem(
                id: "begin_cash_shortage",
                label: "Begin Cash Shortage",
                amount: 0.00,
                color: AppColors.chartCat4
            ),
            CashierSummaryItem(
                id: "driver_compensation",
                label: "Driver Compensation",
                amount: -400.00,
                color: AppColors.chartCat5
            ),
            CashierSummaryItem(
                id: "non_cash_tenders",
                label: "Non-Cash Tenders Total",
                amount: -4444.63,
                color: AppColors.chartCat6
            )
        ]
    )

    static let mockAllPositive = CashierSummaryData(
        title: "Server Bank Summary",
        centerLabel: "Cash Owed",
        centerSubLabel: "To House",
        centerAmount: 1200.00,
        items: [
            CashierSummaryItem(
                id: "net_payments",
                label: "Net Payments",
                amount: 3200.00,
                color: AppColors.chartCat1
            ),
            CashierSummaryItem(
                id: "begin_cash_expected",
                label: "Begin Cash Expected",
                amount: 500.00,
                color: AppColors.chartCat2
            ),
            CashierSummaryItem(
                id: "safe_drop",
                label: "Safe Drop",
                amount: 200.00,
                color: AppColors.chartCat3
            ),
            CashierSummaryItem(
                id: "begin_cash_shortage",
                label: "Begin Cash Shortage",
                amount: 0.00,
                color: AppColors.chartCat4
            ),
            CashierSummaryItem(
                id: "driver_compensation",
                label: "Driver Compensation",
                amount: 800.00,
                color: AppColors.chartCat5
            ),
            CashierSummaryItem(
                id: "non_cash_tenders",
                label: "Non-Cash Tenders Total",
                amount: 1500.00,
                color: AppColors.chartCat6
            )
        ]
    )
}
