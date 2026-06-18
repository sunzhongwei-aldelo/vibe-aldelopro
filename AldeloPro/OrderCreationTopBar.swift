import SwiftUI

struct OrderCreationTopBar: View {
    let orderType: String
    let orderNumber: String
    let tableNumber: String
    let serverName: String
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left: Order type icon + info
            orderTypeSection

            // Middle: Order number + table badge
            orderInfoSection

            Spacer()

            // Right: Server info + buttons
            rightSection
        }
        .frame(height: 112)
        .background(Color(hex: "E9EDF4").opacity(0.5))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "E0E0E0")),
            alignment: .bottom
        )
    }

    // MARK: - Order Type Section

    private var orderTypeSection: some View {
        HStack(spacing: 16) {
            // Orange icon background with waiter icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "FF6A01"))
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(orderType)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "262626"))
                Text(orderNumber)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "BFBFBF"))
            }
        }
        .padding(.leading, 16)
    }

    // MARK: - Order Info Section

    private var orderInfoSection: some View {
        HStack(spacing: 8) {
            Text("#015")
                .font(.title.bold())
                .foregroundColor(Color(hex: "262626"))

            // Table badge
            HStack(spacing: 4) {
                Image(systemName: "tablecells")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)

                Text(tableNumber)
                    .font(.title.bold())
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 12)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 5.25)
                    .fill(Color(hex: "F8F8F8"))
            )
        }
        .padding(.leading, 24)
    }

    // MARK: - Right Section

    private var rightSection: some View {
        HStack(spacing: 16) {
            // Server info
            HStack(spacing: 4) {
                Text("Server:")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "BFBFBF"))
                Text(serverName)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "262626"))
            }

            // Back button
            AldeloButton(
                title: "Back",
                style: .secondary,
                size: .large,
                action: onBack
            )
            .frame(width: 178)

            // Continue button
            AldeloButton(
                title: "Continue",
                style: .primary,
                size: .large,
                action: onContinue
            )
            .frame(width: 178)
        }
        .padding(.trailing, 16)
    }
}

// Color(hex:) is defined in DesignTokens.swift

// MARK: - Preview

#Preview {
    VStack {
        OrderCreationTopBar(
            orderType: "Dine In",
            orderNumber: "1200002",
            tableNumber: "01",
            serverName: "Zhang San",
            onBack: {},
            onContinue: {}
        )
        Spacer()
    }
    
}
