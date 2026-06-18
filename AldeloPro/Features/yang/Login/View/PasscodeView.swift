import SwiftUI

// MARK: - Passcode View

struct PasscodeView: View {
    @ObservedObject var viewModel: ClockInOutViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Enter Your Passcode")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(Color(hex: "#262626"))
                .padding(.top, 40)

            // Passcode Dots
            passcodeDots
                .padding(.top, 32)

            // Numpad
            numpadGrid
                .padding(.top, 32)

            Spacer()
        }
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
            // Row 1: 1, 2, 3
            ForEach(["1", "2", "3"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            // Row 2: 4, 5, 6
            ForEach(["4", "5", "6"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            // Row 3: 7, 8, 9
            ForEach(["7", "8", "9"], id: \.self) { digit in
                numpadButton(digit: digit)
            }
            // Row 4: Delete, 0, Clock In
            deleteButton
            numpadButton(digit: "0")
            clockInButton
        }
    }

    // MARK: - Numpad Button

    private func numpadButton(digit: String) -> some View {
        Button {
            viewModel.appendDigit(digit)
        } label: {
            Text(digit)
                .font(.custom("PingFang SC", size: 40).weight(.regular))
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
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 107, height: 87)
                .background(Color.white)
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                )
        }
    }

    // MARK: - Clock In Button

    private var clockInButton: some View {
        Button {
            viewModel.clockIn()
        } label: {
            Text("Clock In")
                .font(AppFont.tabletDisplay7Medium)
                .foregroundColor(.white)
                .frame(width: 114, height: 88)
                .background(AppColors.primaryNormal)
                .cornerRadius(11)
        }
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueModifier: (Self) -> TrueContent,
        else falseModifier: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueModifier(self)
        } else {
            falseModifier(self)
        }
    }
}
