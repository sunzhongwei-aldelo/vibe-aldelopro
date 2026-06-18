//
//  MenuPanelView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

struct MenuPanelView: View {
    @State private var viewModel = MenuPanelViewModel()
    @State private var showCoursePopup = false
    // 弹窗实测高度（默认值与 CourseMenuPopover 实际尺寸一致，避免首帧跳动）
    @State private var coursePopupHeight: CGFloat = 224
    var orderingViewModel: OrderingPageViewModel

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.xs),
        count: 4
    )

    var body: some View {
        VStack(spacing: 0) {
//            if let title = viewModel.menuTitle {
//                menuTitleBar(title)
//            }
            groupSection
            Divider().background(AppColors.line).padding(.all,20)
            itemSection
            Spacer()
            MenuFooterView(
                currentPage: viewModel.currentPage,
                totalPages: viewModel.totalPages,
                onMore: {},
                onCourse: { showCoursePopup.toggle() },
                onGratuity: {},
                onDiscount: {},
                isCourseActive: showCoursePopup
            )
        }
        .padding(.top, Spacing.sm)
        .overlayPreferenceValue(CourseButtonAnchorKey.self) { anchor in
            if showCoursePopup, let anchor {
                GeometryReader { proxy in
                    let rect = proxy[anchor]
                    // Tap-to-dismiss scrim
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { showCoursePopup = false }

                    CourseMenuPopover(
                        courses: OrderCourse.allCases,
                        selectedCourse: orderingViewModel.selectedCourseId,
                        onSelect: { course in
                            orderingViewModel.selectCourse(course)
                            showCoursePopup = false
                        }
                    )
                    .fixedSize()
                    // 实测弹窗高度，保证底部紧贴 Course 按钮顶部
                    .background(
                        GeometryReader { popupProxy in
                            Color.clear.onAppear {
                                coursePopupHeight = popupProxy.size.height
                            }
                            .onChange(of: popupProxy.size.height) { _, newValue in
                                coursePopupHeight = newValue
                            }
                        }
                    )
                    // 左缘与 Course 按钮对齐，弹窗向上展开（底部贴着按钮顶部）
                    .offset(
                        x: rect.minX,
                        y: rect.minY - Spacing.xs - coursePopupHeight
                    )
                }
            }
        }
    }

    // MARK: - Menu Title

    private func menuTitleBar(_ title: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textSecondary)

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - Group Section

    private var groupSection: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(viewModel.groups) { group in
                MenuGroupCardView(
                    group: group,
                    isSelected: viewModel.selectedGroupId == group.id,
                    action: { viewModel.selectGroup(group.id) }
                )
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Item Section

    private var itemSection: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(viewModel.currentItems) { item in
                MenuItemCardView(
                    item: item,
                    orderedQuantity: orderingViewModel.orderedQuantity(for: item.id)
                ) {
                    orderingViewModel.addMenuItem(item)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        viewModel.goToPage(viewModel.currentPage + 1)
                    } else if value.translation.width > 50 {
                        viewModel.goToPage(viewModel.currentPage - 1)
                    }
                }
        )
    }
}

// MARK: - Preview

#Preview("Menu Panel") {
    MenuPanelView(orderingViewModel: OrderingPageViewModel())
        .frame(width: 900, height: 800)
        .background(AppColors.pageBgDeep)
}
