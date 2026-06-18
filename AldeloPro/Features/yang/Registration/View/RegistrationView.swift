import SwiftUI

struct RegistrationView: View {
    @State private var viewModel = RegistrationViewModel()

    /// 注册完成（点击 Sign Up）后由父级处理导航，进入引导流程第一步。
    var onComplete: (() -> Void)?

    var body: some View {
        ZStack {
            Color(hex: "#F4F8FF")
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xl)
                .fill(Color.white)
                .padding(.horizontal, 67)
                .padding(.vertical, 41)
            
            HStack(spacing: 0) {
                brandingPanel
                formPanel
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 46)
        }
    }
    
    // MARK: - Left Branding Carousel
    private var brandingPanel: some View {
        ZStack(alignment: .bottom) {
            // Crossfade pages
            ForEach(viewModel.carouselItems) { item in
                item.backgroundColor
                    .overlay {
                        Image(systemName: "cube.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .opacity(item.id == viewModel.currentCarouselPage ? 1 : 0)
            }
            
            // Page Dots
            HStack(spacing: 8) {
                ForEach(viewModel.carouselItems) { item in
                    let isActive = item.id == viewModel.currentCarouselPage
                    Circle()
                        .fill(Color.white.opacity(isActive ? 1.0 : 0.5))
                        .frame(width: isActive ? 10 : 8, height: isActive ? 10 : 8)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(width: 462)
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 21))
        .animation(.easeInOut(duration: 0.6), value: viewModel.currentCarouselPage)
    }
    
    // MARK: - Right Form Panel
    private var formPanel: some View {
        VStack {
            switch viewModel.currentStep {
            case .emailPassword:
                RegistrationStep1View(viewModel: viewModel)
            case .phoneVerification:
                RegistrationStep2View(viewModel: viewModel, onComplete: onComplete)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading, 32)
    }
}

// MARK: - Step 1: Email & Password
struct RegistrationStep1View: View {
    @Bindable var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)
            
            Text("Welcome to Aldelo Pro")
                .font(.custom("PingFang SC", size: 24).weight(.semibold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer().frame(height: 12)
            
            Text("Quick & Easy Free Account Sign Up Starts Here")
                .font(AppFont.tabletBody1Regular)
                .foregroundColor(Color(hex: "#6B7785"))
            
            Spacer().frame(height: 36)
            
            // Email Field
            fieldLabel("Email")
            Spacer().frame(height: 8)
            inputField(
                text: $viewModel.email,
                placeholder: "Enter your email"
            )
            
            Spacer().frame(height: 24)
            
            // Password Field
            fieldLabel("New Password")
            Spacer().frame(height: 8)
            passwordField(
                text: $viewModel.password,
                isVisible: viewModel.isPasswordVisible,
                toggleVisibility: { viewModel.isPasswordVisible.toggle() }
            )
            
            Spacer().frame(height: 12)
            
            // Password Validation Rules
            passwordValidationRules
            
            Spacer().frame(height: 24)
            
            // Confirm Password Field
            fieldLabel("Confirm Password")
            Spacer().frame(height: 8)
            passwordField(
                text: $viewModel.confirmPassword,
                placeholder: "Re-Enter New Password",
                isVisible: viewModel.isConfirmPasswordVisible,
                toggleVisibility: { viewModel.isConfirmPasswordVisible.toggle() }
            )
            
            Spacer()
            
            // Next Step Button
            primaryButton("Next Step") {
                viewModel.goToNextStep()
            }
            .disabled(!viewModel.canProceedToNextStep)
            .opacity(viewModel.canProceedToNextStep ? 1 : 0.5)
            
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 24)
    }
    
    private var passwordValidationRules: some View {
        let validation = viewModel.passwordValidation
        return VStack(alignment: .leading, spacing: 6) {
            validationRow("Contains 8 Characters Or More", isMet: validation.hasMinLength)
            validationRow("Contains Letters And Numbers", isMet: validation.hasLettersAndNumbers)
            validationRow("Contains 1 Symbol or More", isMet: validation.hasSymbol)
            validationRow("Contains Upper And Lower Case", isMet: validation.hasUpperAndLower)
        }
    }
    
    private func validationRow(_ text: String, isMet: Bool) -> some View {
        HStack(spacing: 6) {
            if isMet {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.successNormal)
            }
            Text(isMet ? " \(text)" : text)
                .font(AppFont.tabletBody4Regular)
                .foregroundColor(isMet ? AppColors.successNormal : Color(hex: "#BFBFBF"))
        }
    }
}

// MARK: - Step 2: Phone Verification
struct RegistrationStep2View: View {
    @Bindable var viewModel: RegistrationViewModel

    /// 注册完成回调（透传自父级 RegistrationView）。
    var onComplete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)
            
            // Back Button
            Button(action: { viewModel.goBack() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .regular))
                    Text("Back")
                        .font(.custom("PingFang SC", size: 24).weight(.regular))
                }
                .foregroundColor(AppColors.textPrimary)
            }
            .buttonStyle(.plain)
            
            Spacer().frame(height: 48)
            
            // Phone Number Field
            fieldLabel("Mobile Phone Number")
            Spacer().frame(height: 8)
            phoneInputField
            
            Spacer().frame(height: 24)
            
            // SMS Verification Code
            fieldLabel("SMS Verification Code")
            Spacer().frame(height: 8)
            verificationCodeRow
            
            Spacer()
            
            // Sign Up Button
            primaryButton("Sign Up") {
                viewModel.signUp()
                onComplete?()
            }
            .disabled(!viewModel.canSignUp)
            .opacity(viewModel.canSignUp ? 1 : 0.5)
            
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $viewModel.showCountryPicker) {
            countryPickerSheet
        }
    }
    
    // MARK: - Phone Input（根据区号限制最大位数）
    private var phoneInputField: some View {
        HStack(spacing: 0) {
            // Country Code Dropdown
            Button(action: { viewModel.showCountryPicker = true }) {
                HStack(spacing: 4) {
                    Text("\(viewModel.selectedCountry.dialCode) (\(viewModel.selectedCountry.name))")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
            
            Rectangle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 1, height: 28)
            
            // Phone Number 限制位数
            TextField("Enter phone number", text: $viewModel.phoneNumber)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 12)
                .keyboardType(.phonePad)
                .onChange(of: viewModel.phoneNumber) { old, new in
                    let max = viewModel.selectedCountry.minDigits
                    if new.count > max {
                        viewModel.phoneNumber = String(new.prefix(max))
                    }
                }
        }
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(Color.gray.opacity(0.15)) // 输入框背景灰色
        )
    }
    
    // MARK: - Verification Code Row（验证码=6位）
    private var verificationCodeRow: some View {
        HStack(spacing: 12) {
            // Code Input 固定6位
            TextField("Enter code", text: $viewModel.verificationCode)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(.numberPad)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .fill(Color.gray.opacity(0.15)) // 灰色背景
                )
                .onChange(of: viewModel.verificationCode) { old, new in
                    if new.count > 6 {
                        viewModel.verificationCode = String(new.prefix(6))
                    }
                }
            
            // Send / Countdown / Re-send Button
            if !viewModel.codeSent {
                Button(action: { viewModel.sendCode() }) {
                    Text("Send")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(viewModel.canSendCode ? .white : Color(hex: "#BFBFBF"))
                        .frame(width: 156, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                .fill(viewModel.canSendCode ? AppColors.buttonPrimaryBg : Color(hex: "#CFCFCF"))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canSendCode)
            } else if viewModel.isCountdownActive {
                Text("\(viewModel.countdownSeconds)s")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(.white)
                    .frame(width: 156, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .fill(Color(hex: "#CFCFCF"))
                    )
            } else {
                // Re-send 按钮：电话不合格时禁用
                Button(action: { viewModel.resendCode() }) {
                    Text("Re-send")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(viewModel.isPhoneNumberValid ? AppColors.textPrimary : Color(hex: "#BFBFBF"))
                        .frame(width: 156, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                                .fill(Color.white)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isPhoneNumberValid)
            }
        }
    }
    
    // MARK: - Country Picker Sheet
    private var countryPickerSheet: some View {
        NavigationStack {
            List(CountryCode.allCountries) { country in
                Button(action: { viewModel.selectCountry(country) }) {
                    HStack {
                        Text("\(country.dialCode) (\(country.name))")
                            .font(AppFont.tabletBody2Regular)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        if country.code == viewModel.selectedCountry.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primaryNormal)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showCountryPicker = false
                    }
                }
            }
        }
    }
}

// MARK: - Shared Components
private func fieldLabel(_ text: String) -> some View {
    Text(text)
        .font(AppFont.tabletBody3Regular)
        .foregroundColor(Color(hex: "#595959"))
}

private func inputField(text: Binding<String>, placeholder: String) -> some View {
    TextField(placeholder, text: text)
        .font(AppFont.tabletBody2Regular)
        .foregroundColor(AppColors.textPrimary)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(Color.gray.opacity(0.15)) // 灰色背景
        )
}

private func passwordField(
    text: Binding<String>,
    placeholder: String = "",
    isVisible: Bool,
    toggleVisibility: @escaping () -> Void
) -> some View {
    HStack {
        if isVisible {
            TextField(placeholder.isEmpty ? "Enter password" : placeholder, text: text)
                .font(AppFont.tabletBody2Regular)
        } else {
            SecureField(placeholder.isEmpty ? "Enter password" : placeholder, text: text)
                .font(AppFont.tabletBody2Regular)
        }
        
        Button(action: toggleVisibility) {
            Image(systemName: isVisible ? "eye" : "eye.slash")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#BFBFBF"))
        }
        .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .frame(height: 48)
    .background(
        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
            .fill(Color.gray.opacity(0.15)) // 灰色背景
    )
}

private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(title)
            .font(AppFont.tabletButton3Medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(AppColors.buttonPrimaryBg)
            )
    }
    .buttonStyle(.plain)
}

#Preview {
    RegistrationView()
}
