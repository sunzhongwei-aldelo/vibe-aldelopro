//
//  PerformanceModel.swift
//  AldeloPro
//

import Foundation
import CoreGraphics

enum PerformanceTab: String, Codable, CaseIterable {
    case category = "Category"
    case group = "Group"
    case item = "Item"
}

struct PerformanceData: Codable {
    let title: String
    let selectedTab: PerformanceTab
    let rows: [PerformanceRow]
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int

    /// Single max across both discounts and sales for unified bar scaling
    var maxBarAmount: CGFloat {
        let allAmounts = rows.map(\.categorySalesAmount) + rows.map(\.lineDiscountsAmount)
        return CGFloat(allAmounts.max() ?? 1)
    }
}

struct PerformanceRow: Codable, Identifiable {
    var id: String { "\(rank)-\(categoryName)" }
    let rank: Int
    let categoryName: String
    let categoryTotal: String
    let lineDiscounts: String
    let lineDiscountsAmount: Double
    let categorySales: String
    let categorySalesAmount: Double

    /// Returns bar width in points, scaled to availableWidth.
    /// Min 8pt when amount > 0, max = availableWidth.
    func salesBarWidth(maxAmount: CGFloat, availableWidth: CGFloat) -> CGFloat {
        guard categorySalesAmount > 0, maxAmount > 0 else { return 0 }
        let ratio = CGFloat(categorySalesAmount) / maxAmount
        return max(8, ratio * availableWidth)
    }

    /// Returns bar width in points, scaled to availableWidth.
    /// Min 8pt when amount > 0, max = availableWidth.
    func discountBarWidth(maxAmount: CGFloat, availableWidth: CGFloat) -> CGFloat {
        guard lineDiscountsAmount > 0, maxAmount > 0 else { return 0 }
        let ratio = CGFloat(lineDiscountsAmount) / maxAmount
        return max(8, ratio * availableWidth)
    }
}

extension PerformanceData {
    static let mock = PerformanceData(
        title: "Performance",
        selectedTab: .category,
        rows: [
            PerformanceRow(rank: 1, categoryName: "Appetizers", categoryTotal: "$1515.99", lineDiscounts: "($10.18)", lineDiscountsAmount: 6.18, categorySales: "$1580.11", categorySalesAmount: 180.11),
            PerformanceRow(rank: 2, categoryName: "Entrees", categoryTotal: "$1790.12", lineDiscounts: "($30.18)", lineDiscountsAmount: 26.18, categorySales: "$580.11", categorySalesAmount: 580.11),
            PerformanceRow(rank: 3, categoryName: "Sides", categoryTotal: "$1790.12", lineDiscounts: "($6.18)", lineDiscountsAmount: 16.18, categorySales: "$580.11", categorySalesAmount: 280.11),
            PerformanceRow(rank: 4, categoryName: "Desserts", categoryTotal: "$1790.12", lineDiscounts: "($1.18)", lineDiscountsAmount: 6.18, categorySales: "$280.11", categorySalesAmount: 480.11),
            PerformanceRow(rank: 5, categoryName: "Beverages", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$524.77", categorySalesAmount: 324.77),
            PerformanceRow(rank: 6, categoryName: "Category A", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$354.77", categorySalesAmount: 324.77),
            PerformanceRow(rank: 7, categoryName: "Category B", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$324.77", categorySalesAmount: 324.77),
            PerformanceRow(rank: 8, categoryName: "Category C", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$324.77", categorySalesAmount: 324.77),
            PerformanceRow(rank: 9, categoryName: "Category D", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$124.77", categorySalesAmount: 324.77),
            PerformanceRow(rank: 10, categoryName: "Category E", categoryTotal: "$1790.12", lineDiscounts: "$0.00", lineDiscountsAmount: 0, categorySales: "$324.77", categorySalesAmount: 324.77)
        ],
        totalCount: 48,
        currentPage: 1,
        totalPages: 6
    )
}
