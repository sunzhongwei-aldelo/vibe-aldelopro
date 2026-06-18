//
//  CourseMenuPopover.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/11.
//

import SwiftUI

// MARK: - 出餐顺序选择弹窗


/// 点击底部工具栏 "Course" 按钮后弹出的出餐顺序选择器
/// 以纵向列表展示所有课程（Appetizer / Entrée / Dessert / Drinks），点击即归类
/// 对应设计稿 183 - Aldelo Pro Course 04
struct CourseMenuPopover: View {
    /// 所有可选课程
    let courses: [OrderCourse]
    /// 当前选中的课程（用于高亮）
    let selectedCourse: OrderCourse?
    /// 选中某个课程时的回调
    let onSelect: (OrderCourse) -> Void

    private let itemHeight: CGFloat = 44

    var body: some View {
        VStack(spacing: Spacing.xs) {
            ForEach(courses) { course in
                Button {
                    onSelect(course)
                } label: {
                    Text(course.title)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(
                            course == selectedCourse
                                ? AppColors.primaryNormal
                                : AppColors.textPrimary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.sm)
                        .frame(height: itemHeight)
                        .background(
                            course == selectedCourse
                                ? AppColors.primaryLight
                                : AppColors.white100
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                .stroke(
                                    course == selectedCourse
                                        ? AppColors.primaryNormal
                                        : AppColors.line,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.sm)
        .frame(width: 160)
        .background(AppColors.numpadPanelBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .shadow(color: AppColors.black20, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("Course Menu Popover") {
    CourseMenuPopover(
        courses: OrderCourse.allCases,
        selectedCourse: .entree,
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
}
