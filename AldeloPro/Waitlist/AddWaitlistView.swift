import SwiftUI

struct AddWaitlistView: View {
    @State private var guestCount: Int = 4
    @State private var selectedQueue: String = "Small Table"
    @State private var phoneNumber: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isQueueDropdownOpen = false

    var onCancel: (() -> Void)? = nil
    var onConfirm: (() -> Void)? = nil

    private let queueOptions = ["Small Table", "Big Table", "Round Table"]

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            HStack(alignment: .top, spacing: 0) {
                formPanel
                numpadPanel
            }

            Spacer()
            bottomBar
        }
        .background(AppColors.white100)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("Add Waitlist")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { onCancel?() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.black100)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Form Panel (Left)

    private var formPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                guestsCountSection
                divider
                waitlistQueueSection
                divider
                customerSection
            }
            .padding(.horizontal, Spacing.lg)
        }
        .frame(maxWidth: 552)
    }

    // MARK: - Guests Count Section

    private var guestsCountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Guests Count")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.md) {
                stepperButton(systemName: "plus") {
                    guestCount += 1
                }

                guestCountDisplay

                stepperButton(systemName: "minus") {
                    if guestCount > 1 { guestCount -= 1 }
                }
            }
        }
        .padding(.vertical, Spacing.lg)
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppColors.black100)
                .frame(width: Spacing.xxxxxl, height: Spacing.xxxxxl)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(Color(hex: "#F8F8F8"))
                )
        }
    }

    private var guestCountDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .fill(Color(hex: "#F8F8F8"))
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .stroke(AppColors.primaryNormal, lineWidth: 1)
            Text("\(guestCount)")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.black100)
        }
        .frame(width: 241, height: 64)
    }

    // MARK: - Waitlist Queue Section

    private var waitlistQueueSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Waitlist Queue")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            queueDropdown

            queueInfo
        }
        .padding(.vertical, Spacing.lg)
    }

    private var queueDropdown: some View {
        VStack(spacing: 0) {
            Button(action: { isQueueDropdownOpen.toggle() }) {
                HStack {
                    Text(selectedQueue)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.black100.opacity(0.5))
                }
                .padding(.horizontal, Spacing.md)
                .frame(height: Spacing.xxxxxl)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .fill(Color(hex: "#F8F8F8"))
                )
            }
            .overlay(alignment: .top) {
                if isQueueDropdownOpen {
                    VStack(spacing: 0) {
                        ForEach(queueOptions, id: \.self) { option in
                            Button(action: {
                                selectedQueue = option
                                isQueueDropdownOpen = false
                            }) {
                                Text(option)
                                    .font(AppFont.tabletH3Medium)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                            }
                            if option != queueOptions.last {
                                Divider()
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .fill(AppColors.white100)
                            .shadow(color: AppColors.black100.opacity(0.1), radius: 8, y: 4)
                    )
                    .offset(y: 68)
                }
            }
            .zIndex(1)
        }
    }

    private var queueInfo: some View {
        HStack(alignment: .top) {
            Text("#S03")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.warningNormal)

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text("Currently 3rd In Line")
                    .font(AppFont.tabletBody4Regular)
                    .foregroundColor(AppColors.warningNormal)
                Text("About 15 Minutes")
                    .font(AppFont.tabletBody4Regular)
                    .foregroundColor(AppColors.warningNormal)
            }
        }
        .padding(.top, Spacing.md)
    }

    // MARK: - Customer Section

    private var customerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Customer")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            formField(title: "Phone Number", text: $phoneNumber, placeholder: "(877) 639-8767")
            formField(title: "First Name", text: $firstName, placeholder: "Optional")
            formField(title: "Last Name", text: $lastName, placeholder: "Optional")
        }
        .padding(.vertical, Spacing.lg)
    }

    private func formField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            TextField("", text: text, prompt: Text(placeholder)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.inputPlaceholder)
            )
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.md)
            .frame(height: Spacing.xxxxxl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .fill(Color(hex: "#F8F8F8"))
            )
        }
    }

    // MARK: - Numpad Panel (Right)

    private var numpadPanel: some View {
        VStack(spacing: Spacing.xs) {
            numpadRow(keys: ["1", "2", "3"])
            numpadRow(keys: ["4", "5", "6"])
            numpadRow(keys: ["7", "8", "9"])
            numpadBottomRow
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
    }

    private func numpadRow(keys: [String]) -> some View {
        HStack(spacing: Spacing.xs) {
            ForEach(keys, id: \.self) { key in
                numpadKey(key)
            }
        }
    }

    private var numpadBottomRow: some View {
        HStack(spacing: Spacing.xs) {
            backspaceKey
            numpadKey("0")
            clearKey
        }
    }

    private func numpadKey(_ digit: String) -> some View {
        Button(action: { handleNumpadInput(digit) }) {
            Text(digit)
                .font(AppFont.tabletDisplay1Regular)
                .foregroundColor(AppColors.black100)
                .frame(maxWidth: .infinity)
                .frame(height: 122)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.white100)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(Color(hex: "#E0E0E0"), lineWidth: 1.4)
                )
        }
    }

    private var backspaceKey: some View {
        Button(action: { handleBackspace() }) {
            Image(systemName: "delete.left")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(AppColors.black100)
                .frame(maxWidth: .infinity)
                .frame(height: 122)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.white100)
                )
        }
    }

    private var clearKey: some View {
        Button(action: { handleClear() }) {
            Text("Clear")
                .font(AppFont.tabletDisplay3Regular)
                .foregroundColor(AppColors.black100)
                .frame(maxWidth: .infinity)
                .frame(height: 122)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.white100)
                )
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(height: 1)

            HStack(spacing: Spacing.md) {
                Button(action: { onCancel?() }) {
                    Text("Cancel")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.black100)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.xxxxxl)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                                .fill(Color(hex: "#F8F8F8"))
                        )
                }

                Button(action: { onConfirm?() }) {
                    Text("Confirm")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.white100)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.xxxxxl)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                                .fill(AppColors.buttonPrimaryBg)
                        )
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
        }
        .background(AppColors.white100)
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(Color(hex: "#E0E0E0"))
            .frame(height: 1)
    }

    // MARK: - Input Handling

    private func handleNumpadInput(_ digit: String) {
        phoneNumber += digit
    }

    private func handleBackspace() {
        if !phoneNumber.isEmpty {
            phoneNumber.removeLast()
        }
    }

    private func handleClear() {
        phoneNumber = ""
    }
}

// MARK: - Preview

#Preview {
    AddWaitlistView(onCancel: {
        
    }, onConfirm: {
        
    })
        .frame(width: 900, height: 701)
}
