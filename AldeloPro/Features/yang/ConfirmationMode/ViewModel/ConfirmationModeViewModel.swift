import SwiftUI

@Observable
final class ConfirmationModeViewModel {
    var isOrdersTurnedOff: Bool = false
    var confirmationMethod: ConfirmationMethod = .autoConfirm
    var isSoundNotificationOn: Bool = false
    var platforms: [ThirdPartyPlatform]

    init() {
        self.platforms = [
            ThirdPartyPlatform(id: "uber_eats", name: "Uber Eats", iconName: "bag.fill", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 3),
            ThirdPartyPlatform(id: "doordash", name: "DoorDash", iconName: "arrow.right", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 3),
            ThirdPartyPlatform(id: "isv", name: "ISV", iconName: "square.grid.2x2.fill", iconColor: "#34C759", isEnabled: true, timeoutMinutes: 3),
            ThirdPartyPlatform(id: "masa", name: "Masa", iconName: "flame.fill", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 15),
            
            
//            ThirdPartyPlatform(id: "uber_eats", name: "Uber Eats", iconName: "Rectangle930", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 3),
//            ThirdPartyPlatform(id: "doordash", name: "DoorDash", iconName: "Rectangle931", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 3),
//            ThirdPartyPlatform(id: "isv", name: "ISV", iconName: "Frame89307", iconColor: "#34C759", isEnabled: true, timeoutMinutes: 3),
//            ThirdPartyPlatform(id: "masa", name: "Masa", iconName: "Rectangle932", iconColor: "#FF3B30", isEnabled: true, timeoutMinutes: 15),
        ]
    }

    func togglePlatform(at index: Int) {
        platforms[index].isEnabled.toggle()
    }

    func confirm() {
        // TODO: Save confirmation mode settings to backend
    }
}
