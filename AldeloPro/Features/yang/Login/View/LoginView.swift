import SwiftUI

// MARK: - Login View

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#E5EAF4")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                topBar

                // Content
                VStack(spacing: 0) {
                    // Title
                    Text("Enter Login Passcode")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(Color(hex: "#262626"))
                        .padding(.top, 40)

                    // Passcode Dots
                    passcodeDots
                        .padding(.top, 32)

                    // Numpad
                    numpadGrid
                        .padding(.top, 32)
                }

                Spacer() 
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        ZStack {
            // Center: Log In title
            Text("Log In")
                .font(.custom("PingFang SC", size: 23).weight(.semibold))
                .foregroundColor(Color(hex: "#262626"))

            HStack {
                // Left: Store Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Super Delicious Flagship Store")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(.black)
                    HStack(spacing: 0) {
                        Text("Sub ID: ")
                            .font(AppFont.tabletCaption1Regular)
                            .foregroundColor(Color(hex: "#595959"))
                        Text("1234-ABCD")
                            .font(AppFont.tabletCaption1Regular)
                            .foregroundColor(Color(hex: "#595959"))
                    }
                }
                .padding(.leading, 24)

                Spacer()

                // Right: Clock In/Out Button
                Button {
                    viewModel.goToClockInOut()
                } label: {
                    Text("Clock In/Out")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(.black)
                        .frame(width: 160, height: 45)
                        .background(Color(hex: "#F8F8F8"))
                        .cornerRadius(11)
                }
                .padding(.trailing, 24)
            }
        }
        .frame(height: 80)
        .padding(.top, 20)
    }

    // MARK: - Passcode Dots

    private var passcodeDots: some View {
        HStack(spacing: 56) {
            ForEach(0..<viewModel.passcodeLength, id: \.self) { index in
                Circle()
                    .if(index < viewModel.passcodeDigits.count) { view in
                        view.fill(Color(hex: "#262626"))
                    } else: { view in
                        view
                            .fill(Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "#595959"), lineWidth: 2)
                            )
                    }
                    .frame(width: 16, height: 16)
            }
        }
    }

    // MARK: - Numpad Grid

    private var numpadGrid: some View {
        let columns = [
            GridItem(.fixed(109), spacing: 12),
            GridItem(.fixed(109), spacing: 12),
            GridItem(.fixed(109), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(["1", "2", "3"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            ForEach(["4", "5", "6"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            ForEach(["7", "8", "9"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            deleteButton
            numpadButton(digit: "0")
            loginButton
        }
    }

    // MARK: - Numpad Button

    private func numpadButton(digit: String) -> some View {
        Button {
            viewModel.appendDigit(digit)
        } label: {
            Text(digit)
                .font(.custom("PingFang SC", size: 45).weight(.regular))
                .foregroundColor(.black)
                .frame(width: 109, height: 87)
                .background(Color.white)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                )
        }
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button {
            viewModel.deleteLastDigit()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 109, height: 87)
                .background(Color.white)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                )
        }
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            viewModel.login()
        } label: {
            Text("Log In")
                .font(AppFont.tabletDisplay6Medium)
                .foregroundColor(.white)
                .frame(width: 114, height: 88)
                .background(AppColors.primaryNormal)
                .cornerRadius(11)
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
