import SwiftUI

// MARK: - Gratuity Payable Data Model

struct GratuityPayableData {
    let title: String
    let rows: [GratuityPayableRow]
    let summary: GratuityPayableSummary
}

// MARK: - Table Row

struct GratuityPayableRow: Identifiable {
    let id: String
    let employee: String
    let gratuity: Double
    let lessFees: Double
    let netPayable: Double

    var gratuityFormatted: String { formatCurrency(gratuity) }
    var lessFeesFormatted: String { formatCurrency(lessFees) }
    var netPayableFormatted: String { formatCurrency(netPayable) }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Summary

struct GratuityPayableSummary {
    let gratuityTotal: Double
    let lessFeesTotal: Double
    let netPayableTotal: Double

    var gratuityTotalFormatted: String { formatCurrency(gratuityTotal) }
    var lessFeesTotalFormatted: String { formatCurrency(lessFeesTotal) }
    var netPayableTotalFormatted: String { formatCurrency(netPayableTotal) }

    private func formatCurrency(_ value: Double) -> String {
        let absValue = abs(value)
        let formatted = String(format: "$%.2f", absValue)
        return value < 0 ? "(\(formatted))" : formatted
    }
}

// MARK: - Mock Data

extension GratuityPayableData {
    /// Full-page records detail mock matching `GratuityPayableRecordsDetail.svg`.
    /// More rows than the card preview; the table grows with this data.
    static let recordsDetailMock = GratuityPayableData(
        title: "Gratuity Payable Records",
        rows: [
            GratuityPayableRow(id: "1", employee: "Masa online Order", gratuity: 30.32, lessFees: -1.98, netPayable: 28.34),
            GratuityPayableRow(id: "2", employee: "Zhang San", gratuity: 9.21, lessFees: -0.92, netPayable: 28.34),
            GratuityPayableRow(id: "3", employee: "Emily Anderson", gratuity: 202.29, lessFees: -0.92, netPayable: 28.34),
            GratuityPayableRow(id: "4", employee: "Alex Brown", gratuity: 210.29, lessFees: -0.92, netPayable: 28.34),
            GratuityPayableRow(id: "5", employee: "Mike Smith", gratuity: 73.10, lessFees: -0.92, netPayable: 28.34),
            GratuityPayableRow(id: "6", employee: "Mike Smith", gratuity: 73.10, lessFees: -0.92, netPayable: 28.34),
            GratuityPayableRow(id: "7", employee: "Mike Smith", gratuity: 73.10, lessFees: -0.92, netPayable: 28.34)
        ],
        summary: GratuityPayableSummary(
            gratuityTotal: 241.92,
            lessFeesTotal: -34.73,
            netPayableTotal: 207.19
        )
    )

    static let mock = GratuityPayableData(
        title: "Gratuity Payable",
        rows: [
            GratuityPayableRow(
                id: "1",
                employee: "Masa Online Order",
                gratuity: 30.32,
                lessFees: -1.98,
                netPayable: 28.34
            ),
            GratuityPayableRow(
                id: "2",
                employee: "Zhang San",
                gratuity: 9.21,
                lessFees: -0.92,
                netPayable: 28.34
            ),
            GratuityPayableRow(
                id: "3",
                employee: "Emily Anderson",
                gratuity: 202.29,
                lessFees: -0.92,
                netPayable: 28.34
            ),
            GratuityPayableRow(
                id: "4",
                employee: "Alex Brown",
                gratuity: 210.29,
                lessFees: -0.92,
                netPayable: 28.34
            ),
            GratuityPayableRow(
                id: "5",
                employee: "Mike Smith",
                gratuity: 73.10,
                lessFees: -0.92,
                netPayable: 28.34
            )
        ],
        summary: GratuityPayableSummary(
            gratuityTotal: 241.92,
            lessFeesTotal: -34.73,
            netPayableTotal: 207.19
        )
    )
}
