//
//  TenderSummaryModel.swift
//  AldeloPro
//

import Foundation

struct TenderSummaryData: Codable {
    let title: String
    let summaryCards: [TenderSummaryCard]
    let rows: [TenderSummaryRow]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

struct TenderSummaryCard: Codable, Identifiable {
    var id: String { label }
    let icon: String
    let label: String
    let amount: String
}

struct TenderSummaryRow: Codable, Identifiable {
    var id: String { "\(tender)-\(tenderCount)" }
    let tender: String
    let tenderCount: Int
    let paymentsTotal: String
    let tipsAddedTotal: String
    let tenderedTotal: String
}

extension TenderSummaryData {
    static let mock = TenderSummaryData(
        title: "Tender Summary",
        summaryCards: [
            TenderSummaryCard(icon: "creditcard", label: "Credit & Debit Cards Total", amount: "$510.68"),
            TenderSummaryCard(icon: "giftcard", label: "Gift Cards Total", amount: "$856.28"),
            TenderSummaryCard(icon: "banknote", label: "Cash Paid Total", amount: "$52,446.66"),
            TenderSummaryCard(icon: "square.grid.2x2", label: "Other Tendered Total", amount: "($23.12)"),
            TenderSummaryCard(icon: "wallet.pass", label: "Reward Cards Total", amount: "$130.27")
        ],
        rows: [
            TenderSummaryRow(tender: "Cash", tenderCount: 58, paymentsTotal: "$51,743.25", tipsAddedTotal: "$200.00", tenderedTotal: "$149.65"),
            TenderSummaryRow(tender: "Check", tenderCount: 2, paymentsTotal: "($12.77)", tipsAddedTotal: "$0.00", tenderedTotal: "($12.77)"),
            TenderSummaryRow(tender: "MasterCard", tenderCount: 32, paymentsTotal: "$51,743.25", tipsAddedTotal: "$200.00", tenderedTotal: "$28.34"),
            TenderSummaryRow(tender: "Debit Card", tenderCount: 28, paymentsTotal: "$51,743.25", tipsAddedTotal: "$200.00", tenderedTotal: "$149.65"),
            TenderSummaryRow(tender: "Masa Reward Card", tenderCount: 17, paymentsTotal: "$51,743.25", tipsAddedTotal: "$200.00", tenderedTotal: "$149.65"),
            TenderSummaryRow(tender: "Masa E-Gift Card", tenderCount: 52, paymentsTotal: "$51,743.25", tipsAddedTotal: "$200.00", tenderedTotal: "$149.65"),
            TenderSummaryRow(tender: "GrubHub", tenderCount: 2, paymentsTotal: "($10.35)", tipsAddedTotal: "$0.00", tenderedTotal: "($10.35)"),
            TenderSummaryRow(tender: "DoorDash", tenderCount: 2, paymentsTotal: "($10.35)", tipsAddedTotal: "$0.00", tenderedTotal: "($10.35)")
        ],
        totalCount: 48,
        currentPage: 1,
        totalPages: 6
    )
}
