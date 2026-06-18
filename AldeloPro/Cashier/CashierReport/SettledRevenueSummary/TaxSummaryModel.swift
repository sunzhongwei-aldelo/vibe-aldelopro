//
//  TaxSummaryModel.swift
//  AldeloPro
//

import Foundation

struct TaxSummaryData: Codable {
    let title: String
    let bannerLabel: String
    let bannerAmount: String
    let rows: [TaxSummaryRow]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

struct TaxSummaryRow: Codable, Identifiable {
    var id: String { taxName }
    let taxName: String
    let taxableSubTotal: String
    let nonTaxable: String
    let taxExempt: String
    let nonInclusiveTaxesCollected: String
}

extension TaxSummaryData {
    static let mock = TaxSummaryData(
        title: "Tax Summary",
        bannerLabel: "Non-Inclusive Taxes Collected",
        bannerAmount: "$99999.00",
        rows: [
            TaxSummaryRow(taxName: "Tax 1", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$149.65"),
            TaxSummaryRow(taxName: "Tax 2", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$149.65"),
            TaxSummaryRow(taxName: "Tax 3", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$28.34"),
            TaxSummaryRow(taxName: "Tax 4", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$149.65"),
            TaxSummaryRow(taxName: "Tax 5", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$149.65"),
            TaxSummaryRow(taxName: "Tax 6", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$149.65"),
            TaxSummaryRow(taxName: "Tax 7", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$28.34"),
            TaxSummaryRow(taxName: "Tax 8", taxableSubTotal: "$1,762.27", nonTaxable: "$51,743.25", taxExempt: "$200.00", nonInclusiveTaxesCollected: "$28.34")
        ],
        totalCount: 48,
        currentPage: 1,
        totalPages: 6
    )
}
