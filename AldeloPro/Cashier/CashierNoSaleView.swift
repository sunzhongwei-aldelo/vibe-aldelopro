import SwiftUI

struct CashierNoSaleView: View {
    var isOptional: Bool = false
    var onConfirm: ((String) -> Void)?

    @State private var inputText: String = ""
    @State private var selectedReason: String?

    private let reasons: [String] = [
        "Make Change", "Count Cash", "Refund Change",
        "Drawer Test", "Shift Count", "Drawer Check",
        "Other","No Reason"
    ]

    var body: some View {
        
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Title
            titleLabel
            // Input field
            inputField
            // Reason chips
            reasonChips
            
            Spacer()
                
            // Confirm button
            confirmButton
        }
        .padding(Spacing.lg)
        
    }

    // MARK: - Title
    private var titleLabel: some View {
        HStack(spacing: Spacing.xxs) {
            if !isOptional {
                Text("*")
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.primaryNormal)
            }
            Text("No Sale Reason (\(isOptional ? "Optional" : "Required"))")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Input Field
    private var inputField: some View {
        TextField("Enter Or Select A No Sale Reason", text: $inputText)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.md)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .fill(AppColors.inputBg)
            )
    }

    // MARK: - Reason Chips (FlowLayout)
    private var reasonChips: some View {
        FlowLayout(spacing: Spacing.md) {
            ForEach(reasons, id: \.self) { reason in
                reasonChip(reason)
            }
        }
    }

    private func reasonChip(_ title: String) -> some View {
        Button(action: {
            selectedReason = title
            inputText = title
        }) {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, Spacing.lg)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(selectedReason == title ? AppColors.primaryLight : AppColors.white100)
                )
                .overlay(
                    Capsule()
                        .stroke(
                            selectedReason == title ? AppColors.primaryNormal : AppColors.line,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confirm Button
    private var confirmButton: some View {
        HStack {
            Spacer()
            Button(action: {
                onConfirm?(inputText)
            }) {
                Text("Confirm")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.white100)
                    .frame(width: 379, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .fill(AppColors.buttonPrimaryBg)
                    )
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }
}

// MARK: - FlowLayout

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        let totalHeight = currentY + lineHeight
        return ArrangementResult(
            size: CGSize(width: totalWidth, height: totalHeight),
            positions: positions
        )
    }

    private struct ArrangementResult {
        let size: CGSize
        let positions: [CGPoint]
    }
}

#Preview {
    CashierNoSaleView(isOptional: false)
        .frame(width: 682, height: 726)
        .background(AppColors.pageBg)
}
