//
//  BasicSetupView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import SwiftUI

struct BasicSetupView: View {

    // MARK: - Environment

    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // MARK: - State

    @State private var viewModel = BasicSetupViewModel()
    @FocusState private var focusedField: Int?
    /// City 下拉是否展开（用于展开时自动上滚露出浮层空间）
    @State private var isCityOpen = false

    // MARK: - Callbacks

    /// 上一步（出栈返回，由父级 SetupFlowRootView 注入）。
    var onPrevious: (() -> Void)?
    /// 下一步导航（由父级注入）。
    var onNext: (() -> Void)?

    private var isPhone: Bool { layout.isPhonePortrait }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SetupTopBarView(progress: 0.4)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        titleSection
                        storeNameField
                        address1Field
                        address2Field
                        cityStateRow
                            .id("cityRow")
                            .zIndex(1)
                        postalCodeField
                    }
                    .padding(.horizontal, !layout.iPadLandscape ? Spacing.md : Spacing.xx100)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xxl)
                }
                .keyboardFocusScroll(focused: focusedField, proxy: proxy)
                // City 展开时把它滚到顶部，露出下方浮层展开空间；收起不强制回弹
                .onChange(of: isCityOpen) { _, opened in
                    guard opened else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo("cityRow", anchor: .top)
                    }
                }
            }

            bottomButtons
        }
        .background(AppColors.pageBg)
        .dropdownHost()
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Basic Information")
            .font(isPhone ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Fields

    private var storeNameField: some View {
        FormTextField(
            title: "Store Name",
            text: $viewModel.storeName,
            isRequired: true,
            fieldTag: 0,
            externalFocus: $focusedField
        )
        .id(0)
    }

    private var address1Field: some View {
        FormTextField(
            title: "Address 1",
            text: $viewModel.address1,
            isRequired: true,
            fieldTag: 1,
            externalFocus: $focusedField
        )
        .id(1)
    }

    private var address2Field: some View {
        FormTextField(
            title: "Address 2",
            text: $viewModel.address2,
            placeholder: "Optional",
            fieldTag: 2,
            externalFocus: $focusedField
        )
        .id(2)
    }

    // MARK: - City + State Row

    @ViewBuilder
    private var cityStateRow: some View {
        if isPhone {
            // 手机竖排：City 在上、State 在下，二者为同层 VStack 兄弟。
            // City 下拉浮层向下展开会落在 State 区域；若不给 cityField 提权，
            // 后声明的 stateField 默认渲染层级更高，会穿透盖住浮层第一项（见截图 bug）。
            VStack(alignment: .leading, spacing: Spacing.md) {
                cityField.zIndex(1)
                stateField
            }
        } else {
            HStack(alignment: .top, spacing: Spacing.md) {
                cityField
                stateField
            }
        }
    }

    private var cityField: some View {
        OverlaySelectField(
            title: "City",
            options: viewModel.cityOptions,
            selection: $viewModel.city,
            display: { $0 },
            placeholder: "Select city",
            isRequired: true,
            onOpenChange: { opened in isCityOpen = opened }
        )
    }

    private var stateField: some View {
        FormTextField(
            title: "State",
            text: $viewModel.state,
            isRequired: true,
            fieldTag: 3,
            externalFocus: $focusedField
        )
        .id(3)
    }

    @ViewBuilder
    private var postalCodeField: some View {
        let field = FormTextField(
            title: "Postal Code",
            text: $viewModel.postalCode,
            isRequired: true,
            keyboardType: .numberPad,
            fieldTag: 4,
            externalFocus: $focusedField
        )
        .id(4)

        if isPhone {
            field
        } else {
            // 与上方 City 列对齐：占左半宽（右半留空），宽度随容器弹性，
            // 与 cityStateRow 的 HStack 等分逻辑一致，不再硬编码 545。
            HStack(spacing: Spacing.md) {
                field
                Color.clear.frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: Spacing.lg) {
            if isPhone == false { Spacer() }

            Button {
                viewModel.previousStep()
                onPrevious?()
            } label: {
                Text("Previous Step")
                    .font(isPhone ? AppFont.mobileButton1Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: isPhone ? .infinity : 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)
            .dismissesDropdown()

            Button {
                viewModel.nextStep()
                onNext?()
            } label: {
                Text("Next Step")
                    .font(isPhone ? AppFont.mobileButton1Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: isPhone ? .infinity : 382)
                    .controlHeight(64)
                    .background(viewModel.canProceed ? AppColors.buttonPrimaryBg : AppColors.buttonDisabledBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.canProceed == false)
            .dismissesDropdown()

            if isPhone == false { Spacer() }
        }
        .padding(.horizontal, isPhone ? Spacing.md : Spacing.xl)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    BasicSetupView()
        .provideDeviceLayout()
}
