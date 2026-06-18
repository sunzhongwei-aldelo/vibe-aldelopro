import SwiftUI

// MARK: - Order Prep Time ViewModel

@Observable
final class OrderPrepTimeViewModel {
    var selectedPlatform: PrepTimePlatform = .uberEatsDoorDash
    var isUniformWeekly: Bool = false
    var closedDays: Set<PrepTimeDayOfWeek> = [.tuesday]

    // [platform][day][orderType] -> PrepTimeOption?
    private var dailySelections: [PrepTimePlatform: [PrepTimeDayOfWeek: [PrepTimeOrderType: PrepTimeOption]]] = [:]
    // [platform][orderType] -> PrepTimeOption? (uniform mode)
    private var uniformSelections: [PrepTimePlatform: [PrepTimeOrderType: PrepTimeOption]] = [:]

    var orderTypesForCurrentPlatform: [PrepTimeOrderType] {
        switch selectedPlatform {
        case .uberEatsDoorDash:
            return [.takeOut, .delivery]
        case .masa:
            return [.takeOut, .delivery, .dineIn, .driveThru]
        case .isv:
            return [.takeOut, .delivery, .dineIn, .driveThru, .bar, .retail]
        }
    }

    func selectedTime(day: PrepTimeDayOfWeek, orderType: PrepTimeOrderType) -> PrepTimeOption? {
        dailySelections[selectedPlatform]?[day]?[orderType]
    }

    func setTime(day: PrepTimeDayOfWeek, orderType: PrepTimeOrderType, option: PrepTimeOption) {
        if dailySelections[selectedPlatform] == nil {
            dailySelections[selectedPlatform] = [:]
        }
        if dailySelections[selectedPlatform]?[day] == nil {
            dailySelections[selectedPlatform]?[day] = [:]
        }
        dailySelections[selectedPlatform]?[day]?[orderType] = option
    }

    func uniformTime(orderType: PrepTimeOrderType) -> PrepTimeOption? {
        uniformSelections[selectedPlatform]?[orderType]
    }

    func setUniformTime(orderType: PrepTimeOrderType, option: PrepTimeOption) {
        if uniformSelections[selectedPlatform] == nil {
            uniformSelections[selectedPlatform] = [:]
        }
        uniformSelections[selectedPlatform]?[orderType] = option
    }

    func confirm() {
        // TODO: Send prep time settings to API
    }
}
