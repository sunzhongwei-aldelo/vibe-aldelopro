// MARK: - Model & ViewModel
import SwiftUI

enum RegistrationStep {
    case emailPassword
    case phoneVerification
}

struct PasswordValidation {
    var hasMinLength: Bool = false
    var hasLettersAndNumbers: Bool = false
    var hasSymbol: Bool = false
    var hasUpperAndLower: Bool = false
    
    var isValid: Bool {
        hasMinLength && hasLettersAndNumbers && hasSymbol && hasUpperAndLower
    }
    
    static func validate(_ password: String) -> PasswordValidation {
        let hasLetter = password.contains(where: \.isLetter)
        let hasNumber = password.contains(where: \.isNumber)
        let hasUpper = password.contains(where: \.isUppercase)
        let hasLower = password.contains(where: \.isLowercase)
        let hasSymbol = password.contains { char in
            !char.isLetter && !char.isNumber
        }
        return PasswordValidation(
            hasMinLength: password.count >= 8,
            hasLettersAndNumbers: hasLetter && hasNumber,
            hasSymbol: hasSymbol,
            hasUpperAndLower: hasUpper && hasLower
        )
    }
}

struct CountryCode: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let dialCode: String
    let minDigits: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
    static func == (lhs: CountryCode, rhs: CountryCode) -> Bool {
        lhs.code == rhs.code
    }
    
    static let us = CountryCode(code: "US", name: "US", dialCode: "+1", minDigits: 10)
    
    static let allCountries: [CountryCode] = [
        CountryCode(code: "US", name: "US", dialCode: "+1", minDigits: 10),
        CountryCode(code: "CA", name: "CA", dialCode: "+1", minDigits: 10),
        CountryCode(code: "CN", name: "CN", dialCode: "+86", minDigits: 11),
        CountryCode(code: "GB", name: "UK", dialCode: "+44", minDigits: 10),
        CountryCode(code: "AU", name: "AU", dialCode: "+61", minDigits: 9),
        CountryCode(code: "JP", name: "JP", dialCode: "+81", minDigits: 10),
        CountryCode(code: "KR", name: "KR", dialCode: "+82", minDigits: 10),
        CountryCode(code: "IN", name: "IN", dialCode: "+91", minDigits: 10),
        CountryCode(code: "DE", name: "DE", dialCode: "+49", minDigits: 10),
        CountryCode(code: "FR", name: "FR", dialCode: "+33", minDigits: 9),
        CountryCode(code: "MX", name: "MX", dialCode: "+52", minDigits: 10),
    ]
}
// MARK: - Carousel

struct CarouselItem: Identifiable {
    let id: Int
    let backgroundColor: Color

    static let defaultItems: [CarouselItem] = [
        CarouselItem(id: 0, backgroundColor: Color(hex: "#4A90D9")),
        CarouselItem(id: 1, backgroundColor: Color(hex: "#50B86C")),
        CarouselItem(id: 2, backgroundColor: Color(hex: "#E8845C")),
        CarouselItem(id: 3, backgroundColor: Color(hex: "#9B6DD7")),
        CarouselItem(id: 4, backgroundColor: Color(hex: "#E66B7A")),
    ]
}

