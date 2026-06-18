import SwiftUI
import Combine

@MainActor
final class OrderCreationViewModel: ObservableObject {
    // MARK: - Order Info
    @Published var orderType: OrderCreationType
    @Published var orderNumber: String
    @Published var tableNumber: String
    @Published var serverName: String

    // MARK: - Form Fields
    @Published var guestsCount: Int = 4
    @Published var phoneNumber: String = ""
    @Published var customerName: String = ""
    @Published var address: String = ""
    @Published var tabName: String = ""

    // MARK: - Bar Mode
    @Published var barInputMode: BarInputMode = .tabName

    // MARK: - Navigation
    @Published var showLimitedAuth: Bool = false
    @Published var showCardTap: Bool = false
    @Published var showApproved: Bool = false

    // MARK: - Limited Auth
    @Published var limitedAuthMode: LimitedAuthMode = .numpad
    @Published var authAmount: String = "300.00"
    @Published var selectedPresetAmount: Decimal?
    @Published var cardTapMode: CardTapMode = .preAuth(amount: 100)

    // MARK: - Config
    var config: OrderCreationConfig {
        OrderCreationConfig.config(for: orderType)
    }

    let presetAmounts: [PresetAmount] = [
        PresetAmount(value: 100),
        PresetAmount(value: 200),
        PresetAmount(value: 300),
        PresetAmount(value: 400),
        PresetAmount(value: 500)
    ]

    let quickAmounts: [Decimal] = [100, 200, 500]

    // MARK: - Init

    init(
        orderType: OrderCreationType = .dineIn,
        orderNumber: String = "#015",
        tableNumber: String = "01",
        serverName: String = "Zhang San"
    ) {
        self.orderType = orderType
        self.orderNumber = orderNumber
        self.tableNumber = tableNumber
        self.serverName = serverName
    }

    // MARK: - Actions

    func incrementGuests() {
        guestsCount += 1
    }

    func decrementGuests() {
        guard guestsCount > 1 else { return }
        guestsCount -= 1
    }

    func onContinue() {
        // Navigate to order page or trigger auth flow
    }

    func onBack() {
        // Navigate back
    }

    func cycleOrderType() {
        let allTypes = OrderCreationType.allCases
        guard let currentIndex = allTypes.firstIndex(of: orderType) else { return }
        let nextIndex = (currentIndex + 1) % allTypes.count
        orderType = allTypes[nextIndex]
    }

    // MARK: - Limited Auth

    func selectQuickAmount(_ amount: Decimal) {
        authAmount = String(describing: amount) + ".00"
    }

    func selectPresetAmount(_ amount: Decimal) {
        selectedPresetAmount = amount
    }

    func onAuthContinue() {
        let amount = Decimal(string: authAmount) ?? 100
        cardTapMode = .preAuth(amount: amount)
        showLimitedAuth = false
        showCardTap = true
    }

    func onCashBar() {
        showLimitedAuth = false
    }

    func onCardTapCancel() {
        showCardTap = false
    }

    func onCardVerified() {
        showCardTap = false
        showApproved = true
    }

    func onDone() {
        showApproved = false
    }

    // MARK: - Numpad

    func numpadDigit(_ digit: String) {
        if authAmount == "0.00" || authAmount == "0" {
            authAmount = ""
        }
        authAmount += digit
    }

    func numpadBackspace() {
        guard !authAmount.isEmpty else { return }
        authAmount.removeLast()
        if authAmount.isEmpty {
            authAmount = "0"
        }
    }

    func numpadClear() {
        authAmount = "0.00"
    }

    // MARK: - Validation

    var isFormValid: Bool {
        switch orderType {
        case .delivery:
            return !phoneNumber.isEmpty && !customerName.isEmpty && !address.isEmpty
        case .bar:
            if barInputMode == .tabName {
                return !tabName.isEmpty
            }
            return true
        default:
            return true
        }
    }

    var addressPlaceholder: String {
        config.addressRequirement == .required ? "Required" : "Optional"
    }

    var phonePlaceholder: String {
        config.phoneRequirement == .required ? "Required" : "Optional"
    }

    var namePlaceholder: String {
        config.nameRequirement == .required ? "Required" : "Optional"
    }
}
