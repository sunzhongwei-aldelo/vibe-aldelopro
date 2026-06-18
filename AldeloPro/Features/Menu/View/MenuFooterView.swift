//
//  MenuFooterView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

struct MenuFooterView: View {
    let currentPage: Int
    let totalPages: Int
    let onMore: () -> Void
    let onCourse: () -> Void
    let onGratuity: () -> Void
    let onDiscount: () -> Void
    /// Course 按钮是否处于激活状态（弹窗展开时高亮）
    var isCourseActive: Bool = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            paginationDots
            actionButtons
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Pagination Dots

    @ViewBuilder
    private var paginationDots: some View {
        if totalPages > 1 {
            HStack(spacing: Spacing.xs) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? AppColors.primaryNormal : AppColors.line)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.sm) {
            Spacer()

            footerButton(icon: "ellipsis.circle", title: "More", action: onMore)
            footerButton(icon: nil, title: "Course", isActive: isCourseActive, action: onCourse)
                .anchorPreference(key: CourseButtonAnchorKey.self, value: .bounds) { $0 }
            footerButton(icon: nil, title: "Gratuity", action: onGratuity)
            footerButton(icon: nil, title: "Discount", action: onDiscount)
        }
    }

    private func footerButton(
        icon: String?,
        title: String,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? AppColors.primaryNormal : AppColors.textPrimary)
                }
                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(isActive ? AppColors.primaryNormal : AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.lg)
            .frame(height: 63)
            .background(isActive ? AppColors.primaryLight : AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(isActive ? AppColors.primaryNormal : AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preference Key

/// 记录底部工具栏 "Course" 按钮的位置，供上层把弹窗锚定到按钮上方
struct CourseButtonAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

// MARK: - Preview

#Preview("Footer - Page 1 of 3") {
    MenuFooterView(
        currentPage: 0,
        totalPages: 3,
        onMore: {},
        onCourse: {},
        onGratuity: {},
        onDiscount: {},
        isCourseActive: true
    )
    .background(Color(hex: "#E5EAF4"))
}

