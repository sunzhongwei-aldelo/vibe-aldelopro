import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var passcodeDigits: [String] = []
    let passcodeLength = 4

    var onLogin: ((String) -> Void)?
    var onClockInOut: (() -> Void)?

    func appendDigit(_ digit: String) {
        guard passcodeDigits.count < passcodeLength else { return }
        passcodeDigits = passcodeDigits + [digit]
    }

    func deleteLastDigit() {
        guard !passcodeDigits.isEmpty else { return }
        passcodeDigits = Array(passcodeDigits.dropLast())
    }

    func login() {
        let code = passcodeDigits.joined()
        guard code.count == passcodeLength else { return }
        onLogin?(code)
    }

    func goToClockInOut() {
        onClockInOut?()
    }
}
