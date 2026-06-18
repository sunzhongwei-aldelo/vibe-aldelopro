import SwiftUI

// MARK: - View

struct EditPriceView: View {
    let itemName: String
    let originalPrice: Double
    let salePrice: Double?
    var onCancel: () -> Void = {}
    var onConfirm: (Double, Int, String) -> Void = { _, _, _ in }

    @State private var priceText: String = ""
    @State private var quantity: Int = 1
    @State private var note: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerView
            HStack(spacing: 0) {
                leftPanel
                numpadPanel
            }
            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 4)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Spacer()
            Text("Edit Price")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
            Button(action: {
                onCancel()
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.trailing, 24)
        }
        .frame(height: 80)
    }

    // MARK: - Left Panel

    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            priceSection
            Divider()
                .padding(.horizontal, 24)
            quantitySection
            Divider()
                .padding(.horizontal, 24)
            noteSection
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Price Section

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("New Price")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
                HStack(spacing: 8) {
                    Text("Original")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text("|")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Text("Sale")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }

            priceInputField
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var priceInputField: some View {
        HStack {
            Text(priceText.isEmpty ? "0.00" : priceText)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(priceText.isEmpty ? .gray : .black)
            Rectangle()
                .fill(Color(red: 0.0, green: 0.49, blue: 1.0))
                .frame(width: 2, height: 32)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 63)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.0, green: 0.49, blue: 1.0), lineWidth: 1)
        )
    }

    // MARK: - Quantity Section

    private var quantitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Qty")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)

            HStack(spacing: 16) {
                quantityButton(systemName: "minus", enabled: quantity > 1) {
                    if quantity > 1 { quantity -= 1 }
                }

                Text("\(quantity)")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 241, height: 63)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 1)
                    )

                quantityButton(systemName: "plus", enabled: true) {
                    quantity += 1
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private func quantityButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(enabled ? .black : .black.opacity(0.3))
                .frame(width: 64, height: 64)
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    // MARK: - Note Section

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)

            TextField("Price...", text: $note, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(4...6)
                .padding(16)
                .frame(minHeight: 100, maxHeight: 153, alignment: .topLeading)
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - Numpad

    private var numpadPanel: some View {
        let rows: [[NumpadKey]] = [
            [.digit("1"), .digit("2"), .digit("3")],
            [.digit("4"), .digit("5"), .digit("6")],
            [.digit("7"), .digit("8"), .digit("9")],
            [.backspace, .digit("0"), .clear]
        ]

        return VStack(spacing: 2) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 2) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                        numpadButton(rows[rowIndex][colIndex])
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    private func numpadButton(_ key: NumpadKey) -> some View {
        Button(action: { handleKeyPress(key) }) {
            Group {
                switch key {
                case .digit(let value):
                    Text(value)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.black)
                case .backspace:
                    Image(systemName: "delete.backward")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.black)
                case .clear:
                    Text("Clear")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.88, green: 0.88, blue: 0.88), lineWidth: 0.7)
            )
        }
        .buttonStyle(.plain)
    }

    private func handleKeyPress(_ key: NumpadKey) {
        switch key {
        case .digit(let value):
            if value == "0" && priceText.isEmpty {
                priceText = "0."
            } else if priceText.contains(".") {
                let parts = priceText.split(separator: ".", omittingEmptySubsequences: false)
                if parts.count < 2 || parts[1].count < 2 {
                    priceText += value
                }
            } else {
                priceText += value
            }
        case .backspace:
            if !priceText.isEmpty {
                priceText.removeLast()
            }
        case .clear:
            priceText = ""
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(Color(red: 0.88, green: 0.88, blue: 0.88))

            HStack(spacing: 16) {
                Button(action: {
                    onCancel()
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                AldeloButton(title: "Confirm", style: .primary, size: .large, icon: nil) {
                    let price = Double(priceText) ?? 0.0
                    onConfirm(price, quantity, note)
                    dismiss()
                }
                
//                Button(action: {
//                    let price = Double(priceText) ?? 0.0
//                    onConfirm(price, quantity, note)
//                    dismiss()
//                }) {
//                    Text("Confirm")
//                        .font(.system(size: 18, weight: .medium))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 64)
//                        .background(Color(red: 0.0, green: 0.49, blue: 1.0))
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                }
//                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
        }
    }
}

// MARK: - Numpad Key

private enum NumpadKey {
    case digit(String)
    case backspace
    case clear
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .ignoresSafeArea()

        EditPriceView(
            itemName: "Burger",
            originalPrice: 12.99,
            salePrice: 9.99,
            onCancel: { print("Cancelled") },
            onConfirm: { price, qty, note in
                print("Price: \(price), Qty: \(qty), Note: \(note)")
            }
        )
        .frame(width: 900)
    }
}
