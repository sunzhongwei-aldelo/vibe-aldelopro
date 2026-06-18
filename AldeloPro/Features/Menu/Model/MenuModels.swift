//
//  MenuModels.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import Foundation

struct MenuGroup: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let itemCount: Int
    let imageName: String? // nil = text-only mode
}

struct MenuItem: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let price: Decimal
    let pricePrefix: String? // "From" prefix for range prices
    let imageName: String? // nil = text-only mode
    let stockCount: Int? // nil = unlimited, 0 = sold out
    let orderedQuantity: Int // quantity already in cart
}

enum MenuItemStatus: Equatable, Sendable {
    case available
    case lowStock(Int)
    case soldOut
}

extension MenuItem {
    var status: MenuItemStatus {
        guard let stock = stockCount else { return .available }
        if stock == 0 { return .soldOut }
        if stock <= 10 { return .lowStock(stock) }
        return .available
    }

    var displayPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let priceStr = formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
        if let prefix = pricePrefix {
            return "\(prefix) \(priceStr)"
        }
        return priceStr
    }
}
