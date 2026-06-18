import SwiftUI

// MARK: - Order Type

enum OrderCreationType: String, CaseIterable, Identifiable {
    case dineIn = "Dine In"
    case delivery = "Delivery"
    case takeOut = "Take Out"
    case bar = "Bar"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .dineIn: return "fork.knife"
        case .delivery: return "figure.walk"
        case .takeOut: return "bag"
        case .bar: return "wineglass"
        }
    }

    var badgeColor: Color {
        switch self {
        case .dineIn: return AppColors.orderTypeDineIn
        case .delivery: return Color(hex: "#13b8d6")
        case .takeOut: return AppColors.orderTypeTakeOut
        case .bar: return Color(hex: "#00a99d")
        }
    }

    var requiresAddress: Bool {
        self == .delivery
    }

    var requiresTable: Bool {
        self == .dineIn
    }

    var showsCustomerByDefault: Bool {
        self != .bar
    }

    var hasTabNameOption: Bool {
        self == .bar
    }
}

// MARK: - Field Requirement

enum FieldRequirement {
    case optional
    case required
    case hidden
}

// MARK: - Order Creation Config

struct OrderCreationConfig {
    let orderType: OrderCreationType
    let phoneRequirement: FieldRequirement
    let nameRequirement: FieldRequirement
    let addressRequirement: FieldRequirement

    static func config(for type: OrderCreationType) -> OrderCreationConfig {
        switch type {
        case .dineIn:
            return OrderCreationConfig(
                orderType: type,
                phoneRequirement: .optional,
                nameRequirement: .optional,
                addressRequirement: .optional
            )
        case .delivery:
            return OrderCreationConfig(
                orderType: type,
                phoneRequirement: .required,
                nameRequirement: .required,
                addressRequirement: .required
            )
        case .takeOut:
            return OrderCreationConfig(
                orderType: type,
                phoneRequirement: .optional,
                nameRequirement: .optional,
                addressRequirement: .hidden
            )
        case .bar:
            return OrderCreationConfig(
                orderType: type,
                phoneRequirement: .optional,
                nameRequirement: .optional,
                addressRequirement: .optional
            )
        }
    }
}

// MARK: - Bar Input Mode

enum BarInputMode: String, CaseIterable {
    case tabName = "Tab Name"
    case customer = "Customer"
}

// MARK: - Limited Auth Mode

enum LimitedAuthMode {
    case numpad
    case amountGrid
}

// MARK: - Card Tap Mode

enum CardTapMode {
    case preAuth(amount: Decimal)
    case openAuth
}

// MARK: - Auth Result

struct AuthResult {
    let isApproved: Bool
    let amount: Decimal?
}

// MARK: - Preset Amount

struct PresetAmount: Identifiable {
    let id = UUID()
    let value: Decimal
    var displayString: String {
        "$\(value)"
    }
}
