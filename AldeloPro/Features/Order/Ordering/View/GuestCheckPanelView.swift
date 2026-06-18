//
//  GuestCheckPanelView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import SwiftUI

// MARK: - 客单面板视图


/// 右侧已点菜品的完整面板容器
/// 包含操作栏、菜品列表（ScrollView）、底部汇总栏三大区域
struct GuestCheckPanelView: View {
    var viewModel: OrderingPageViewModel
    @Binding var showAssignGuest: Bool
    @Binding var showMoreMenu: Bool
    @State private var showHoldView = false
    @State private var showOrderHoldView = false
    @State private var showItemNoteView = false
    @State private var showOrderNoteView = false
    @State private var showSwitchOrderType = false
    @State private var showEditPrice = false
    
    @Environment(AppUIManager.self) private var uiManager: AppUIManager?
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            orderInfoSection
            Divider().background(AppColors.line)
            itemListSection
            Spacer(minLength: 0)
//            discountAndTotals
            Divider().background(AppColors.line)
            balanceBar
            GuestCheckFooterView()
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .overlayPreferenceValue(AssignGuestAnchorKey.self) { anchor in
            if showAssignGuest, let anchor {
                GeometryReader { proxy in
                    let rect = proxy[anchor]
                    let panelHeight = proxy.size.height
                    let popoverTop = rect.maxY + Spacing.xs
                    let threeItemHeight: CGFloat = 293
                    let fitsThree = (popoverTop + threeItemHeight) <= panelHeight
                    let visibleCount = fitsThree ? 3 : 2

                    // Tap to dismiss (below popover)
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { showAssignGuest = false }

                    AssignGuestPopover(
                        guests: viewModel.guestList,
                        onSelect: { guest in
                            viewModel.assignGuest(guest)
                            showAssignGuest = false
                        },
                        maxVisibleCount: visibleCount
                    )
                    .fixedSize()
                    .offset(x: rect.minX, y: popoverTop)
                }
            }
        }

        .overlay(alignment: .topTrailing) {
            if showMoreMenu {
                moreMenuContent
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
        .onChange(of: showHoldView) { _, newValue in
            if newValue {
                let selectedItem = viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })
                uiManager?.presentCover {
                    HoldView(
                        itemName: selectedItem?.name ?? "",
                        maxQuantity: selectedItem?.quantity,
                        isPresented: $showHoldView
                    ) { (dateTime,qty) in
                        viewModel.updateItemHoldDateTime(dateTime: dateTime)
                    }
                    //.background(ClearBackgroundView())
                }
            }else {
                uiManager?.dismissCover()
            }
        }
        .onChange(of: showOrderHoldView) { _, newValue in
            if newValue {
                uiManager?.presentCover {
                    HoldView(
                        itemName: "Order",
                        isPresented: $showOrderHoldView
                    ) { (dateTime,qty) in
                        viewModel.updateOrderHoldDateTime(dateTime: dateTime)
                    }
                    .background(ClearBackgroundView())
                }
            }else {
                uiManager?.dismissCover()
            }
        }.onChange(of: showItemNoteView) { _, newValue in
            if newValue {
                let selectedItem = viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })
                uiManager?.presentCover {
                    NoteMainView(
                        itemName: selectedItem?.name ?? "",
                        existingNote: selectedItem?.itemNote ?? "",
                        existingQuantity: selectedItem?.quantity ?? 1,
                        onConfirm: { note, qty in
                            viewModel.updateItemNote(note, quantity: qty)
                            showItemNoteView = false
                        },
                        onDismiss: { showItemNoteView = false }
                    )
                }
            } else {
                uiManager?.dismissCover()
            }
        }
        .onChange(of: showOrderNoteView) { _, newValue in
            if newValue {
                let selectedItem = viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })
                uiManager?.presentCover {
                    NoteMainView(
                        itemName: "Order",
                        existingNote: viewModel.orderNote ?? "",
                        existingQuantity: selectedItem?.quantity,
                        onConfirm: { note, _ in
                            viewModel.updateOrderNote(note: note)
                            showOrderNoteView = false
                        },
                        onDismiss: { showOrderNoteView = false }
                    )
                }
            } else {
                uiManager?.dismissCover()
            }
        }
        .onChange(of: showSwitchOrderType) { _, newValue in
            if newValue {
                uiManager?.presentCover {
                    OrderSettingsMainView(
                        type: .switchOrderType(currentType: viewModel.guestCheck.orderType),
                        onConfirm: { showSwitchOrderType = false },
                        onDismiss: { showSwitchOrderType = false },
                        onConfirmOrderType: { type in
                            viewModel.updateOrderType(type)
                        }
                    )
                    .background(ClearBackgroundView())
                }
            } else {
                uiManager?.dismissCover()
            }
        }
        .onChange(of: showEditPrice) { _, newValue in
            if newValue {
                let item = viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })
                uiManager?.presentCover {
                    OrderSettingsMainView(
                        type: .editPrice(
                            originalPrice: formatPrice(item?.unitPrice ?? 0),
                            itemQuantity: item?.quantity ?? 1,
                            note: item?.itemNote ?? ""
                        ),
                        onConfirm: { showEditPrice = false },
                        onDismiss: { showEditPrice = false },
                        onConfirmEditPrice: { price, _, note in
                            viewModel.updateItemPrice(price, note: note)
                        }
                    )
                    .background(ClearBackgroundView())
                }
            } else {
                uiManager?.dismissCover()
            }
        }
//        .fullScreenCover(isPresented: $showHoldView) {
//            let selectedItem = viewModel.orderItems.first(where: { $0.id == viewModel.selectedItemId })
//            HoldView(
//                itemName: selectedItem?.name ?? "",
//                maxQuantity: selectedItem?.quantity,
//                isPresented: $showHoldView
//            ) { (dateTime,qty) in
//                viewModel.updateItemHoldDateTime(dateTime: dateTime)
//            }
//            .background(ClearBackgroundView())
//        }
//        .fullScreenCover(isPresented: $showOrderHoldView) {
//            
//            HoldView(
//                itemName: "Order",
//                isPresented: $showOrderHoldView
//            ) { (dateTime,qty) in
//                viewModel.updateOrderHoldDateTime(dateTime: dateTime)
//            }
//            .background(ClearBackgroundView())
//        }
    }

    // MARK: - More Menu

    private var moreMenuContent: some View {
        VStack(spacing: Spacing.md) {
            moreMenuItem(icon: "doc.on.doc", title: "Split") {
                showMoreMenu = false
            }
            moreMenuItem(icon: "arrow.right.arrow.left", title: "Combine") {
                showMoreMenu = false
            }
            moreMenuItem(icon: "xmark.circle", title: "Void Check") {
                showMoreMenu = false
            }
        }
        .padding(Spacing.md)
        .frame(width: 230)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(Color(hex: "#4F535B").opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        )
        .padding(.top, 64)
        .padding(.trailing, Spacing.md)
    }

    private func moreMenuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 28, height: 28)
                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: 63)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            Button { } label: {
                Image(.返回)
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 48, height: 48)
            }

            Text(viewModel.guestCheck.orderNumber)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.xxs) {
                Image(.frame10)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(AppColors.textPrimary)
                Text(viewModel.guestCheck.tableNumber)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(AppColors.buttonSecondaryBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))

            Spacer()

            HStack(spacing: Spacing.xs) {
                Button { /* TODO: Note action */
                    showOrderNoteView = true
                } label: {
                    Image(.notes)
                        .font(AppFont.tabletH1Medium)
                        .frame(width: 48, height: 48)
                        .foregroundColor(AppColors.textPrimary)
                        .background(AppColors.buttonSecondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }

                Button { /* TODO: Hold action */
                    showOrderHoldView = true
                } label: {
                    Image(.hold)
                        .font(AppFont.tabletH1Medium)
                        .frame(width: 48, height: 48)
                        .foregroundColor(AppColors.textPrimary)
                        .background(AppColors.buttonSecondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }

                Button { showMoreMenu = true } label: {
                    Image(.more)
                        .font(AppFont.tabletH1Medium)
                        .frame(width: 48, height: 48)
                        .foregroundColor(AppColors.textPrimary)
                        .background(AppColors.buttonSecondaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
            }
        }
        .frame(height: 64)
        .padding(.horizontal, Spacing.xs)
    }



    // MARK: - Order Info

    private var orderInfoSection: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(viewModel.guestCheck.orderType.assetImageName)
                        .font(AppFont.tabletDisplay6Regular)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.guestCheck.orderType.rawValue)
                            .font(AppFont.tabletH6Medium)
                            .foregroundColor(AppColors.textPrimary)
                        Text(viewModel.guestCheck.orderCode)
                            .font(AppFont.tabletCaption1Regular)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { showSwitchOrderType = true }
                Spacer()
                HStack(spacing: Spacing.xxs) {
                    Text("Server:")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textTertiary)
                    Text(viewModel.guestCheck.serverName)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }

            HStack {
                HStack(spacing: Spacing.xxs) {
                    Image(.frame76)
                        .resizable()
                        .frame(width: 22,height: 22)
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(viewModel.guestCheck.guestCount)")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
                if let time = viewModel.guestCheck.holdDateTime {
                    HoldBadge(time: time)
                }else {
                    HStack(spacing: Spacing.xxs) {
                        Text("Opened")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textTertiary)
                        Text(viewModel.guestCheck.openedTime)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            
            if let _ = viewModel.guestCheck.holdDateTime {
                HStack {
                    Spacer()
                    HStack(spacing: Spacing.xxs) {
                        Text("Opened")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textTertiary)
                        Text(viewModel.guestCheck.openedTime)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }}
            }

            if let note = viewModel.orderNote {
                Text(note)
                    .font(AppFont.tabletBody4Regular)
                    .foregroundColor(AppColors.errorNormal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //.padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
//                            .stroke(
//                                AppColors.errorNormal,
//                                style: StrokeStyle(lineWidth: 1, dash: [4, 3])
//                            )
//                    )
            }
        }
        .padding(.horizontal, Spacing.md)
//        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Item List

    private var itemListSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // course分组内，再按客人分组展示
                    ForEach(viewModel.courseGroupedItems, id: \.course) { courseGroup in
                        courseHeader(course: courseGroup.course)

                        // 课程分组内，再按客人分组展示
                        ForEach(viewModel.guestGroups(in: courseGroup.items), id: \.guest) { guestGroup in
                            guestHeaderHasCourse(guest: guestGroup.guest)

                            ForEach(guestGroup.items) { item in
                                let isSelected = item.id == viewModel.selectedItemId
                                selectedItemBlock(item: item, isSelected: isSelected)
                                    .id(item.id)
                            }
                        }
                    }
                    
                    if viewModel.courseGroupedItems.isEmpty == true {
                        // 没有course，按客人分组展示（排在所有课程分组之后，无课程标题）
                        ForEach(viewModel.guestGroups(in: viewModel.uncategorizedItems), id: \.guest) { guestGroup in
                            guestHeader(guest: guestGroup.guest)
                            
                            ForEach(guestGroup.items) { item in
                                let isSelected = item.id == viewModel.selectedItemId
                                selectedItemBlock(item: item, isSelected: isSelected)
                                    .id(item.id)
                            }
                        }
                    }

                    Rectangle().frame(height: 10).foregroundStyle(AppColors.pageBgDeep)
                    discountAndTotals
                }
            }
            .simultaneousGesture(
                showAssignGuest
                    ? DragGesture(minimumDistance: 5).onChanged { _ in showAssignGuest = false }
                    : nil
            )
            .onChange(of: viewModel.selectedItemId) { _, newId in
                if let id = newId {
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    /// 课程分组标题（Appetizer / Entrée / ...），右侧带 Fire 触发按钮
    /// 对应设计稿 180/181 - Aldelo Pro Course 01/02
    @ViewBuilder
    private func courseHeader(course: OrderCourse?) -> some View {
        let isSelected = course != nil && viewModel.selectedCourseId == course
        let title = course?.title ?? "Uncategorized"
        VStack(spacing: 0) {
            Divider().background(AppColors.line)
            HStack {
                Button {
                    // 课程标题点击：未选中则选中，已选中则取消选中
                    viewModel.toggleCourseSelection(course)
                } label: {
                    Text(title)
                        .font(AppFont.tabletH6Medium)
                        .foregroundColor(isSelected ? AppColors.primaryNormal : AppColors.textPrimary)
                }
                .buttonStyle(.plain)

                Spacer()

                if course != nil {
                    firePill
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            Rectangle()
                .fill(isSelected ? AppColors.primaryNormal : AppColors.line)
                .frame(height: isSelected ? 2 : 0.5)
        }
        .background(AppColors.pageBgDeep)
    }
    
    @ViewBuilder
    private func guestHeader(guest: Int?) -> some View {
        let isSelected = guest != nil && viewModel.selectedGuestId == guest
        let title = guest.map { "Guest \($0)" } ?? "Unassigned"
        VStack(spacing: 0) {
            Divider().background(AppColors.line)
            Button {
                viewModel.selectGuest(guest)
            } label: {
                Text(title)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(isSelected ? AppColors.primaryNormal : AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.sm)
            }
            .buttonStyle(.plain)
            Rectangle()
                .fill(isSelected ? AppColors.primaryNormal : AppColors.line)
                .frame(height: isSelected ? 2 : 0.5)
        }
        .background(AppColors.pageBgDeep)
    }
    

    /// "Fire" 催菜胶囊按钮 — 出现在每个课程分组标题右侧
    /// 对应设计稿 180/181/182 课程标题右侧的蓝色 "Fire" 药丸
    /// TODO: 接入厨房催菜服务后改为真实触发
    private var firePill: some View {
        Button {
            // TODO: 触发该课程的厨房催菜（kitchen firing service）
        } label: {
            Text("Fire")
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.primaryNormal)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .overlay(
                    Capsule()
                        .stroke(AppColors.primaryNormal.opacity(0.4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// 客人分组小标题（课程分组内部，按客人再分组）
    /// 展示一个人形图标 + "Guest N"；未分配客人（guest == nil）显示 "Unassigned"
    @ViewBuilder
    private func guestHeaderHasCourse(guest: Int?) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "person")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(guest.map { "Guest \($0)" } ?? "Unassigned")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xxs)
    }

    private func selectedItemBlock(item: OrderItem, isSelected: Bool) -> some View {
        VStack(spacing: 0) {
            // 仅菜品行响应点击选中；操作栏（含删除等按钮）不再被外层 tap 手势包裹，
            // 否则落在按钮边缘的点击会被外层 selectItem 抢走，导致删除等操作时灵时不灵。
            GuestCheckItemRow(
                item: item,
                isSelected: isSelected,
                onEditPrice: { showEditPrice = true }
            )
            .contentShape(Rectangle())
            .onTapGesture { viewModel.selectItem(item.id) }

            if isSelected {
                GuestCheckActionBar(viewModel: viewModel, showAssignGuest: $showAssignGuest, showHoldView: $showHoldView, showItemNoteView: $showItemNoteView)
            }
        }
        .background(isSelected ? AppColors.primaryLight : Color.clear)
        .overlay(
            isSelected
                ? AnyView(selectedBorder)
                : AnyView(EmptyView())
        )
    }

    private var selectedBorder: some View {
        VStack(spacing: 0) {
            Spacer()
            Rectangle()
                .stroke(AppColors.primaryNormal, lineWidth: 2)
//                .fill(AppColors.primaryNormal)
//                .frame(height: 3)
        }
//        .overlay(
//            Rectangle()
//                .stroke(AppColors.primaryNormal.opacity(0.4), lineWidth: 1)
//        )
    }

    // MARK: - Discount & Totals

    private var discountAndTotals: some View {
        VStack(spacing: Spacing.xs) {
            totalRow("New Store Opening Discount", value: viewModel.discount)
            Divider().background(AppColors.line)
            totalRow("Subtotal", value: viewModel.subtotal)
            totalRow("Tax", value: viewModel.tax)
            totalRow("Total", value: viewModel.total, isBold: true)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
    }

    private func totalRow(_ label: String, value: Decimal, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isBold ? AppFont.tabletH6Medium : AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(formatPrice(value))
                .font(isBold ? AppFont.tabletH6Medium : AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Balance Bar

    private var balanceBar: some View {
        HStack {
            Text("Balance Due:")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Spacer()

            HStack(spacing: 0) {
                Text("Cash Due")
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(AppColors.white100)
                    .padding(.horizontal, Spacing.xs)
                    .frame(maxHeight: .infinity)
                    .background(AppColors.inputSuccess)
                Text(formatPrice(viewModel.cashBalance))
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.xs)
                    .frame(maxHeight: .infinity)
                    .background(AppColors.inputBg)
            }
            .fixedSize(horizontal: false, vertical: true)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .stroke(AppColors.inputSuccess, lineWidth: 1)
            )

            Text(formatPrice(viewModel.balanceDue))
                .font(AppFont.tabletH3Medium)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryNormal)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Helpers

    private func formatPrice(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview("Guest Check - Selected") {
    GuestCheckPanelView(viewModel: OrderingPageViewModel(), showAssignGuest: .constant(false), showMoreMenu: .constant(false))
        .frame(width: AppGrid.orderDetailWidth, height: 900)
        .background(AppColors.pageBgDeep)
}

#Preview("Guest Check - No Selection") {
    @Previewable @State var vm = OrderingPageViewModel()
    let _ = { vm.selectedItemId = nil }()
    GuestCheckPanelView(viewModel: vm, showAssignGuest: .constant(false), showMoreMenu: .constant(false))
        .frame(width: AppGrid.orderDetailWidth, height: 900)
        .background(AppColors.pageBgDeep)
}



// MARK: - Preference Key

struct AssignGuestAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

