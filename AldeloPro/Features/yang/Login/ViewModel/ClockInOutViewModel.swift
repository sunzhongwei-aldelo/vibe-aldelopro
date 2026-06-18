import SwiftUI
import Combine

// MARK: - ClockInOut Tab

enum ClockInOutTab: String, CaseIterable {
    case passcode = "Passcode"
    case faceRecognition = "Face Recognition"
}

// MARK: - Face Recognition State

enum FaceRecognitionState {
    case idle
    case recognizing
    case failed
}

// MARK: - ClockInOut ViewModel

@MainActor
final class ClockInOutViewModel: ObservableObject {
    // MARK: Tab
    @Published var selectedTab: ClockInOutTab = .passcode

    // MARK: Passcode
    @Published var passcodeDigits: [String] = []
    let passcodeLength = 4

    // MARK: Face Recognition
    @Published var faceState: FaceRecognitionState = .idle

    // MARK: Callbacks
    var onClockIn: ((String) -> Void)?
    var onBack: (() -> Void)?

    // MARK: - Passcode Actions

    func appendDigit(_ digit: String) {
        guard passcodeDigits.count < passcodeLength else { return }
        passcodeDigits = passcodeDigits + [digit]
    }

    func deleteLastDigit() {
        guard !passcodeDigits.isEmpty else { return }
        passcodeDigits = Array(passcodeDigits.dropLast())
    }

    func submitPasscode() {
        let code = passcodeDigits.joined()
        guard code.count == passcodeLength else { return }
        onClockIn?(code)
    }

    func clockIn() {
        let code = passcodeDigits.joined()
        onClockIn?(code)
    }

    // MARK: - Face Recognition Actions

    func startFaceRecognition() {
        faceState = .recognizing
    }

    func faceRecognitionSucceeded() {
        onClockIn?("")
    }

    func faceRecognitionFailed() {
        faceState = .failed
    }

    func rescan() {
        faceState = .idle
    }

    // MARK: - Navigation

    func back() {
        onBack?()
    }
}
