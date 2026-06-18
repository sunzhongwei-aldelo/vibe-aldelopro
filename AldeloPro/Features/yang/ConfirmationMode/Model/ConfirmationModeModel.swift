import Foundation

enum ConfirmationMethod: String, CaseIterable {
    case autoConfirm = "Auto Confirm"
    case manuallyConfirm = "Manually Confirm"
}

struct ThirdPartyPlatform: Identifiable {
    let id: String
    let name: String
    let iconName: String
    let iconColor: String
    var isEnabled: Bool
    var timeoutMinutes: Int

    var timeoutLabel: String {
        "\(timeoutMinutes) mins"
    }
}
