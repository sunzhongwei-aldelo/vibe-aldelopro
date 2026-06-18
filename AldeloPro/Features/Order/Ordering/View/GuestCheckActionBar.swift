//
//  GuestCheckActionBar.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 客单操作栏


/// 已点菜品列表顶部的操作按钮栏
/// 包含编辑、删除、分配客人等快捷操作按钮
struct GuestCheckActionBar: View {
    var viewModel: OrderingPageViewModel
    @Binding var showAssignGuest: Bool
    @Binding var showHoldView: Bool
    @Binding var showItemNoteView: Bool
    @State private var hasAssignGuest = true

    var body: some View {
        VStack(spacing: 0) {
            // Action buttons (wrapping)
            WrappingHStack(spacing: Spacing.sm) {
                // Delete button (red)
                actionButton(icon: "Frame-12", color: AppColors.buttonPrimaryText, bg: AppColors.errorNormal) { }

                // Edit button
                actionButton(icon: "square.and.pencil",isSystem: true, color: AppColors.textPrimary, bg: AppColors.inputBg) { }

                // Hold button (hourglass)
                actionButton(icon: "hold", color: AppColors.textPrimary, bg: AppColors.inputBg) {
                    showHoldView = true
                }

                // Sorted button (sort arrows)
                actionButton(icon: "Frame-39", color: AppColors.textPrimary, bg: AppColors.inputBg) { }

                // Void button (red text)
                textActionButton(title: "Void", color: AppColors.buttonPrimaryText, bg: AppColors.errorNormal) { }

//                // Share button
                textActionButton(title: "Share", color: AppColors.textPrimary, bg: AppColors.inputBg) { }

                // Repeat button (copy icon)
                actionButton(icon: "Duplicate Order", color: AppColors.textPrimary, bg: AppColors.inputBg) { }

                // Note button
                actionButton(icon: "Notes", color: AppColors.textPrimary, bg: AppColors.inputBg) {
                    showItemNoteView = true
                }

                if hasAssignGuest {
                    // Assign Guest button
                    Button {
                        showAssignGuest.toggle()
                    } label: {
                        Image(showAssignGuest ? "assignBlue" : "assign")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryNormal)
                            .frame(width: 48, height: 48)
                            .background(showAssignGuest ? AppColors.infoSelectedBg.opacity(0.08) : AppColors.inputBg)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                    }
                    .anchorPreference(key: AssignGuestAnchorKey.self, value: .bounds) { $0 }
                }
                
                // Quantity controls (always one row)
                HStack(spacing: Spacing.sm) {
                    actionButton(icon: "minus",isSystem: true, color: AppColors.textPrimary, bg: AppColors.inputBg) {
                        viewModel.updateQuantity(delta: -1)
                    }
                    
                    Text("\(viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })?.quantity ?? 1)")
                        .font(AppFont.tabletH5Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 96, height: 48)
                        .background(AppColors.inputBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                .stroke(AppColors.line, lineWidth: 1)
                        )
                    
                    actionButton(icon: "plus",isSystem: true, color: AppColors.textPrimary, bg: AppColors.inputBg) {
                        viewModel.updateQuantity(delta: 1)
                    }
                }
            }

        }
//        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(AppColors.primaryLight)
    }

    private func actionButton(
        icon: String,
        isSystem:Bool = false,
        color: Color,
        bg: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            if isSystem {
                Image(systemName: icon)
                    .renderingMode(.template)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(bg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }else {
                Image(icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(bg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
 
        }
    }

    private func textActionButton(
        title: String,
        color: Color,
        bg: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(color)
                .frame(width: 96, height: 48)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        }
    }
}

// MARK: - Wrapping Flow Layout

struct WrappingHStack: Layout {
    var spacing: CGFloat = Spacing.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
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
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return CGSize(width: totalWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), anchor: .topLeading, proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview("Action Bar") {
    GuestCheckActionBar(viewModel: OrderingPageViewModel(), showAssignGuest: .constant(false), showHoldView: .constant(false), showItemNoteView: .constant(false))
        .frame(width: 450)
}

