import SwiftUI
import Combine

@Observable
final class RegistrationViewModel {
    // MARK: - Step
    var currentStep: RegistrationStep = .emailPassword
    
    // MARK: - Carousel
    var carouselItems: [CarouselItem] = CarouselItem.defaultItems
    var currentCarouselPage: Int = 0
    private var carouselTimer: Timer?
    
    init() {
        startCarouselTimer()
    }
    
    private func startCarouselTimer() {
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentCarouselPage = (self.currentCarouselPage + 1) % self.carouselItems.count
        }
    }
    
    // MARK: - Step 1: Email & Password
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isPasswordVisible: Bool = false
    var isConfirmPasswordVisible: Bool = false
    
    var passwordValidation: PasswordValidation {
        PasswordValidation.validate(password)
    }
    
    var canProceedToNextStep: Bool {
        // for test
        // !email.isEmpty && passwordValidation.isValid && password == confirmPassword
        return true
    }
    
    // MARK: - Step 2: Phone Verification
    var selectedCountry: CountryCode = .us
    var showCountryPicker: Bool = false
    var phoneNumber: String = ""
    var verificationCode: String = ""
    var countdownSeconds: Int = 0
    var codeSent: Bool = false
    
    var isCountdownActive: Bool { countdownSeconds > 0 }
    
    private var countdownTimer: Timer?
    
    var phoneDigitsOnly: String {
        phoneNumber.filter(\.isNumber)
    }
    
    var isPhoneNumberValid: Bool {
        phoneDigitsOnly.count >= selectedCountry.minDigits
    }
    
    var canSendCode: Bool {
        isPhoneNumberValid && !isCountdownActive
    }
    
    var canSignUp: Bool {
        // for test
        // isPhoneNumberValid && verificationCode.count == 6 && codeSent
        true
    }
    
    // MARK: - Actions
    func goToNextStep() {
        currentStep = .phoneVerification
    }
    
    func goBack() {
        currentStep = .emailPassword
        stopCountdown()
        codeSent = false
    }
    
    func selectCountry(_ country: CountryCode) {
        selectedCountry = country
        showCountryPicker = false
        phoneNumber = ""
    }
    
    func sendCode() {
        guard canSendCode else { return }
        codeSent = true
        startCountdown()
    }
    
    func resendCode() {
        guard isPhoneNumberValid else { return }
        startCountdown()
    }
    
    func signUp() {
        // TODO: Implement sign up API call
    }
    
    private func startCountdown() {
        countdownSeconds = 60
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            if self.countdownSeconds > 0 {
                self.countdownSeconds -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownSeconds = 0
    }
}

