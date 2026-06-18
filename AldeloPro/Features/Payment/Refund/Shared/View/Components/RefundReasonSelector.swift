//
//  RefundReasonSelector.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundReasonSelector

/// Right-side Step 1: Reason input field + preset chips
/// Used by both PaymentRefund and CustomRefund flows
struct RefundReasonSelector: View {

    // MARK: - Parameters

    let displayedReason: String
    let selectedPreset: RefundPresetReason?
    let isEditable: Bool
    let onSelectPreset: (RefundPresetReason) -> Void
    let onUpdateReason: (String) -> Void
    let onConfirmReason: () -> Void
    let onEditReason: (() -> Void)?

    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle
                .padding(.bottom, isCompact ? Spacing.sm : Spacing.md)
            if isEditable {
                editableContent
            } else {
                readOnlyReasonRow
            }
        }
    }

    // MARK: - Section Title

    private var sectionTitle: some View {
        Text("Refund Reason")
            .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletBody3Regular)
            .foregroundColor(AppColors.textSecondary)
    }

    // MARK: - Editable Content (Step 1 active)

    private var editableContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            reasonTextField
                .padding(.bottom, isCompact ? Spacing.md : Spacing.xl)
            presetChips
        }
    }

    // MARK: - Reason TextField

    private var reasonTextField: some View {
        TextField("Enter Or Select A Refund Reason", text: reasonBinding)
            .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(height: isCompact ? 40 : 48)
            .padding(Spacing.md)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .shadow(color: AppColors.textPrimary.opacity(0.04), radius: 4, y: 2)
            .focused($isTextFieldFocused)
            .onSubmit { onConfirmReason() }
    }

    private var reasonBinding: Binding<String> {
        Binding(
            get: { displayedReason },
            set: { onUpdateReason($0) }
        )
    }

    // MARK: - Preset Chips

    private var presetChips: some View {
        FlowLayout(spacing: isCompact ? Spacing.sm : Spacing.md) {
            ForEach(RefundPresetReason.allCases) { reason in
                chipButton(reason)
            }
        }
    }

    private func chipButton(_ reason: RefundPresetReason) -> some View {
        let isSelected = selectedPreset == reason
        return Button {
            onSelectPreset(reason)
            isTextFieldFocused = false
        } label: {
            Text(reason.rawValue)
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletButton4Medium)
                .foregroundColor(isSelected ? AppColors.theme : AppColors.textPrimary)
                .padding(.horizontal, Spacing.lg)
                .frame(height: isCompact ? 44 : 52)
                .background(isSelected ? AppColors.theme.opacity(0.08) : AppColors.card)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppColors.theme : AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Read-Only Reason Row (after confirm, shows reason + pencil icon)

    private var readOnlyReasonRow: some View {
        HStack {
            Text(displayedReason.isEmpty ? "Enter Or Select A Refund Reason" : displayedReason)
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletBody2_5Regular)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            if let onEdit = onEditReason {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: isCompact ? 40 : 48)
        .padding(Spacing.md)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        .shadow(color: AppColors.textPrimary.opacity(0.04), radius: 4, y: 2)
    }
}

// MARK: - FlowLayout (横向自适应换行布局)

/// 横向流式布局：子视图按顺序排列，排满一行后自动换行
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX - spacing)
        }
        totalHeight = currentY + lineHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview("Editable - Empty") {
    RefundReasonSelector(
        displayedReason: "",
        selectedPreset: nil,
        isEditable: true,
        onSelectPreset: { _ in },
        onUpdateReason: { _ in },
        onConfirmReason: {},
        onEditReason: nil
    )
    .padding()
    .background(AppColors.pageBg)
}

#Preview("Read-Only with Edit") {
    RefundReasonSelector(
        displayedReason: "Order Mistake",
        selectedPreset: .orderMistake,
        isEditable: false,
        onSelectPreset: { _ in },
        onUpdateReason: { _ in },
        onConfirmReason: {},
        onEditReason: {}
    )
    .padding()
    .background(AppColors.pageBg)
}

