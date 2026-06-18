//
//  OrderingPageView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 点单主页面


/// 点单操作的主容器页面
/// 包含菜品分类导航、菜品网格、已点菜品列表等核心区域
struct OrderingPageView: View {
    @State private var viewModel = OrderingPageViewModel()
    @State private var showAssignGuest = false
    @State private var showMoreMenu = false

    var body: some View {
        HStack(spacing: 0) {
            GuestCheckPanelView(viewModel: viewModel, showAssignGuest: $showAssignGuest, showMoreMenu: $showMoreMenu)
                .frame(width: AppGrid.orderDetailWidth)
                // 提升层级：使其 AssignGuest / More 浮层溢出到右侧菜单区时，
                // 不被后声明（绘制层级更高）的 MenuItemCardView 盖住
                .zIndex(1)
            VStack {
                TopToolbarView()
                if viewModel.selectedItemHasPortions {
                    PizzaBuilderView(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                } else {
                    MenuPanelView(orderingViewModel: viewModel)
                        .frame(maxWidth: .infinity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if showAssignGuest { showAssignGuest = false }
                if showMoreMenu { showMoreMenu = false }
            }
        }
        .background(AppColors.pageBgDeep)
        .ignoresSafeArea(edges: .bottom)
        .overlay {
            if showMoreMenu {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { showMoreMenu = false }
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    OrderingPageView()
}

