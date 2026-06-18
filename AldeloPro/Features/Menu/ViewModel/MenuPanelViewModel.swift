//
//  MenuPanelViewModel.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import Foundation

@Observable @MainActor
final class MenuPanelViewModel {
    // MARK: - State

    private(set) var menuTitle: String? = "Super Delicious Classic Menu 2025"

    private struct GroupMeta: Sendable {
        let id: String
        let name: String
        let imageName: String?
    }

    private let groupMetas: [GroupMeta] = [
        GroupMeta(id: "drinks", name: "Drinks", imageName: nil),
        GroupMeta(id: "hotdishes", name: "Hot Dishes", imageName: nil),
        GroupMeta(id: "colddish", name: "Cold Dish", imageName: nil),
        GroupMeta(id: "staplefood", name: "Staple Food", imageName: nil),
        GroupMeta(id: "skewers", name: "Grilled Skewers", imageName: nil),
        GroupMeta(id: "soup", name: "Soup", imageName: nil),
        GroupMeta(id: "snack", name: "Snack", imageName: nil),
    ]

    var groups: [MenuGroup] {
        groupMetas.map { meta in
            MenuGroup(
                id: meta.id,
                name: meta.name,
                itemCount: allItems[meta.id]?.count ?? 0,
                imageName: meta.imageName
            )
        }
    }

    var selectedGroupId: String = "drinks"

    private(set) var allItems: [String: [MenuItem]] = [
        "drinks": [
            MenuItem(id: "d1", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 5),
            MenuItem(id: "d2", name: "Coconut Water", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d3", name: "Mango Juice", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 1),
            MenuItem(id: "d4", name: "Wine", price: 35.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 1),
            MenuItem(id: "d5", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d6", name: "Coconut Water", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d7", name: "Yellow Wine", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: 9, orderedQuantity: 0),
            MenuItem(id: "d8", name: "Liquor", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d9", name: "Orange Juice", price: 5.00, pricePrefix: "From", imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d10", name: "Cola", price: 35.00, pricePrefix: nil, imageName: nil, stockCount: 0, orderedQuantity: 0),
            MenuItem(id: "d11", name: "Coconut Water", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "d12", name: "Coconut Water", price: 5.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
        ],
        "hotdishes": [
            MenuItem(id: "h1", name: "Kung Pao Chicken", price: 12.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "h2", name: "Sweet Sour Pork", price: 15.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "h3", name: "Mapo Tofu", price: 10.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
            MenuItem(id: "h4", name: "Steamed Fish", price: 28.00, pricePrefix: nil, imageName: nil, stockCount: nil, orderedQuantity: 0),
        ],
    ]

    /// Current page index for item pagination
    var currentPage: Int = 0
    private let itemsPerPage: Int = 16 // 4 columns × 4 rows

    // MARK: - Computed

    var currentItems: [MenuItem] {
        let items = allItems[selectedGroupId] ?? []
        let start = currentPage * itemsPerPage
        guard start < items.count else { return [] }
        let end = min(start + itemsPerPage, items.count)
        return Array(items[start..<end])
    }

    var totalPages: Int {
        let items = allItems[selectedGroupId] ?? []
        return max(1, (items.count + itemsPerPage - 1) / itemsPerPage)
    }

    // MARK: - Actions

    func selectGroup(_ id: String) {
        selectedGroupId = id
        currentPage = 0
    }


    func goToPage(_ page: Int) {
        guard page >= 0, page < totalPages else { return }
        currentPage = page
    }
}
