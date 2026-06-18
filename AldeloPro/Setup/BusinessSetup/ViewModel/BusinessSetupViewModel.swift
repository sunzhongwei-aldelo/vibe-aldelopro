//
//  BusinessSetupViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/11.
//

import Foundation

// MARK: - Industry Type

enum IndustryType: String, CaseIterable, Identifiable {
    case restaurant = "Restaurant"
    case retail = "Retail"
    case services = "Services"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .restaurant:
            return "Meals, Fast Food, Bars, Cafeterias, Takeaways, Etc."
        case .retail:
            return "Convenience Store, Fresh Food Store, Fruit Shop, Pet Store, Etc."
        case .services:
            return "Foot Washing, Massage, Beauty, Hairdressing, Car Washing, Etc."
        }
    }

    var iconName: String {
        switch self {
        case .restaurant: return "restaurants"
        case .retail: return "retails"
        case .services: return "services"
        }
    }

    var categories: [String] {
        switch self {
        case .restaurant:
            return ["Table Service", "Fine Dining", "Quick Service", "Fast Casual", "Buffet", "Cafeteria", "Food Truck", "Concession", "Other Hospitality"]
        case .retail:
            return ["Convenience", "Grocery", "Clothing", "Electronics", "Pet Store", "Specialty", "Other Retail"]
        case .services:
            return ["Beauty", "Massage", "Hair Salon", "Nail Salon", "Car Wash", "Laundry", "Other Services"]
        }
    }
}

// MARK: - Business Order Type

enum BusinessOrderType: String, CaseIterable, Identifiable {
    case dineIn = "Dine In"
    case takeOut = "Take Out"
    case bar = "Bar"
    case driveThru = "Drive Thru"
    case delivery = "Delivery"
    case retail = "Retail"

    var id: String { rawValue }
}

// MARK: - ViewModel

@Observable
@MainActor
final class BusinessSetupViewModel {

    // MARK: - State

    var selectedIndustry: IndustryType = .restaurant
    var selectedCategories: [String] = ["Quick Service", "Fast Casual", "Buffet"]
    var selectedOrderTypes: Set<BusinessOrderType> = Set(BusinessOrderType.allCases)

    // MARK: - Computed

    var categoryOptions: [String] {
        selectedIndustry.categories
    }

    // MARK: - Actions

    func selectIndustry(_ industry: IndustryType) {
        guard industry != selectedIndustry else { return }
        selectedIndustry = industry
        selectedCategories = []
    }

    func toggleOrderType(_ type: BusinessOrderType) {
        if selectedOrderTypes.contains(type) {
            selectedOrderTypes.remove(type)
        } else {
            selectedOrderTypes.insert(type)
        }
    }

    func nextStep() {
        // Navigation handled by parent
    }
}
