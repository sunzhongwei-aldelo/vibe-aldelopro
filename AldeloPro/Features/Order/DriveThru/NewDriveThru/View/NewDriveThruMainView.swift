//
//  NewDriveThruMainView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import SwiftUI

/// 汽车外卖创建控制台的根入口（本特性中唯一以 `MainView` 结尾命名的视图）。
///
/// 组合结构：固定的 `DriveThruHeaderView` + 可滚动的配置主体。
/// - iPad：主体置于 `ScrollViewReader` 中；当某个顾客字段获得焦点时，
///   视图会将该字段滚动到垂直方向大致居中处，确保原生键盘永不遮挡它。
/// - iPhone：主体为纵向流，`Continue` 通过 `safeAreaInset` 变为吸底胶囊键。
struct NewDriveThruMainView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @State private var viewModel: NewDriveThruViewModel
    @FocusState private var focusedField: CustomerField?

    init(viewModel: NewDriveThruViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var isPad: Bool { hSizeClass == .regular }

    var body: some View {
        VStack(spacing: 0) {
            // 迁移至通用 AldeloTransactionHeaderView（B 族 Drive Thru 渠道）。
            AldeloTransactionHeaderView.driveThru(
                longOrderNo: viewModel.stationNumber,
                orderNumber: viewModel.orderNumber,
                serverName: viewModel.serverName,
                onBack: { viewModel.goBack() },
                onContinue: { viewModel.advanceFromContinue() }
            )
            configurationBody
        }
        .background(AppColors.pageBg)
        // iPhone：跨越安全区的吸底 Continue 按钮。
        .safeAreaInset(edge: .bottom) {
            if !isPad {
                stickyContinueBar
            }
        }
        // 保持 @FocusState 与 ViewModel 的业务状态严格同步。
        .onChange(of: focusedField) { _, newValue in
            viewModel.syncFocus(to: newValue)
        }
        .onChange(of: viewModel.workflowState) { _, _ in
            if focusedField != viewModel.focusedField {
                focusedField = viewModel.focusedField
            }
        }
    }

    // MARK: 主体 (Body)

    private var configurationBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: isPad ? Spacing.xl : Spacing.lg) {
                    DriveThruStepperView(
                        title: "Guests Count",
                        value: viewModel.guestCount,
                        canStepDown: viewModel.canStepDown,
                        canStepUp: viewModel.canStepUp,
                        onDecrement: { viewModel.decrementGuests() },
                        onIncrement: { viewModel.incrementGuests() }
                    )

                    // 一旦进入姓名录入阶段，车型矩阵即隐藏（对齐设计图 177）。
                    if !viewModel.isNameActive {
                        VehicleTypeSelectorView(
                            title: "Vehicle",
                            vehicles: viewModel.vehicleTypes,
                            selectedID: viewModel.selectedVehicleID,
                            onSelect: { viewModel.selectVehicle($0) }
                        )

                        VehicleColorSelectorView(
                            colors: viewModel.vehicleColors,
                            selectedID: viewModel.selectedColorID,
                            onSelect: { viewModel.selectColor($0) }
                        )
                    }

                    if viewModel.isCustomerSectionVisible {
                        CustomerInfoInputView(
                            title: "Customer",
                            phoneText: viewModel.formattedPhone,
                            nameText: viewModel.customerName,
                            onPhoneChange: { viewModel.updatePhone(rawInput: $0) },
                            onNameChange: { viewModel.updateName($0) },
                            focus: $focusedField
                        )
                        .id(Self.customerAnchor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, contentHorizontalPadding)
                .padding(.vertical, isPad ? Spacing.xl : Spacing.lg)
                .animation(.easeInOut(duration: 0.25), value: viewModel.workflowState)
            }
            // 焦点变化时，将激活字段滚动到键盘上方可见区域。
            .onChange(of: focusedField) { _, newValue in
                guard let field = newValue else { return }
                scrollFieldAboveKeyboard(field, using: proxy)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    /// 将聚焦的顾客字段滚动到软键盘上方，避免遮挡。
    ///
    /// 滚动目标为字段自身的锚点（而非整个分组），使其在键盘上方区域居中。
    /// 延迟的第二次滚动发生在键盘把自身高度作为底部安全区 inset 应用之后，
    /// 这样 `.center` 是针对"可见区域（键盘上方）"而非"整个高度"求解 ——
    /// 这正是此前导致字段被部分遮挡的根因。
    private func scrollFieldAboveKeyboard(_ field: CustomerField, using proxy: ScrollViewProxy) {
        withAnimation(.easeInOut(duration: 0.25)) {
            proxy.scrollTo(field, anchor: .center)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.keyboardSettleDelay) {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }

    // MARK: 局部组件 (Pieces)

    private var stickyContinueBar: some View {
        Button(action: { viewModel.advanceFromContinue() }) {
            Text("Continue")
                .font(AppFont.mobileButton1Medium)
                .foregroundStyle(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Mobile.full, style: .continuous)
                        .fill(AppColors.theme)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
        .background(AppColors.pageBg)
    }

    // MARK: 布局常量 (Layout constants)

    private static let customerAnchor = "customer-section"
    /// 第二次滚动前的延迟，需足够长以等待键盘弹出动画把底部安全区 inset 应用完毕
    /// （系统动画约 0.25s）。
    private static let keyboardSettleDelay: TimeInterval = 0.35

    /// iPad 采用基于 1440 基准约 12% 的侧边距；iPhone 采用固定间距。
    private var contentHorizontalPadding: CGFloat {
        isPad ? Spacing.xxxl : Spacing.md
    }
}

// MARK: - Previews

#Preview("iPad 横屏 - 状态一 triage") {
    NewDriveThruMainView(viewModel: NewDriveThruViewModel())
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 横屏 - 状态二 Phone (Dark)") {
    NewDriveThruMainView(
        viewModel: {
            let vm = NewDriveThruViewModel()
            vm.beginPhoneIntake()
            return vm
        }()
    )
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}

#Preview("iPad 横屏 - 状态三 Name") {
    NewDriveThruMainView(
        viewModel: {
            let vm = NewDriveThruViewModel()
            vm.updatePhone(rawInput: "8776398767")
            vm.updateName("ZYX")
            vm.beginNameIntake()
            return vm
        }()
    )
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏 - 状态一") {
    NewDriveThruMainView(viewModel: NewDriveThruViewModel())
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPhone 竖屏 - 状态二 Phone") {
    NewDriveThruMainView(
        viewModel: {
            let vm = NewDriveThruViewModel()
            vm.beginPhoneIntake()
            return vm
        }()
    )
    .environment(\.horizontalSizeClass, .compact)
}
