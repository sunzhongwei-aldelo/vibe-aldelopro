//
//  AddEmployeeView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/03.
//

import SwiftUI
import PhotosUI
import Combine

// MARK: - CropImageItem

private struct CropImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - AddEmployeeView

struct AddEmployeeView: View {
    // 1. Environment
    @Environment(\.dismiss) private var dismiss
    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // 2. ViewModel
    @State private var viewModel = AddEmployeeViewModel()

    // 3. Input
    var editingEmployee: Employee?

    // 4. Callbacks
    var onSave: ((Employee) -> Void)?

    // 5. Photo State
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var cropItem: CropImageItem?

    // 6. UI State
    @State private var showMoreSettings = true
    @State private var showJobTitleDropdown = false
    @State private var showLanguageDropdown = false
    @State private var showStartDatePicker = false
    @State private var showTerminationDatePicker = false

    // 7. Keyboard / Focus
    /// 当前聚焦的输入框标识；键盘弹出时据此把该字段滚到键盘上方
    @FocusState private var focusedField: Int?

    // MARK: - Layout Constants

    var isCompact: Bool { layout.isPhonePortrait }
    
    private var pageTitle: String { editingEmployee != nil ? "Edit Employee" : "Add Employee" }

    // MARK: - Bindings for FormSelectField (Set<String> ↔ [String])

    private var rolesBinding: Binding<[String]> {
        Binding(
            get: { Array(viewModel.selectedRoles.sorted()) },
            set: { viewModel.selectedRoles = Set($0) }
        )
    }

    private var accessibilitiesBinding: Binding<[String]> {
        Binding(
            get: { Array(viewModel.selectedAccessibilities.sorted()) },
            set: { viewModel.selectedAccessibilities = Set($0) }
        )
    }

    private var jobTitleBinding: Binding<[String]> {
        Binding(
            get: { viewModel.jobTitle.isEmpty ? [] : [viewModel.jobTitle] },
            set: { viewModel.jobTitle = $0.last ?? "" }
        )
    }

    private var languageBinding: Binding<[String]> {
        Binding(
            get: { viewModel.language.isEmpty ? [] : [viewModel.language] },
            set: { viewModel.language = $0.last ?? "" }
        )
    }

    // MARK: - Keyboard

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Body

    var body: some View {
        // iPad 竖屏使用窄布局；iPad 横屏使用宽布局
        let isNarrow = layout == .iPadPortrait

        return ZStack(alignment: .top) {
                AppColors.pageBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    topBar(isNarrow: isNarrow)
                    scrollContent(isNarrow: isNarrow)
                }
                .task { prefillFromEmployee() }
            
                if showStartDatePicker {
                    datePickerOverlay(
                        selectedDate: $viewModel.startDate,
                        onConfirm: { showStartDatePicker = false },
                        onDismiss: { showStartDatePicker = false }
                    )
                }

                if showTerminationDatePicker {
                    datePickerOverlay(
                        selectedDate: $viewModel.terminationDate,
                        onConfirm: { showTerminationDatePicker = false },
                        onDismiss: { showTerminationDatePicker = false }
                    )
                }
            }
        // 点击空白处 / 普通控件时自动收起 FormSelectField 下拉面板
        .dropdownHost()
    }

    // MARK: - Actions

    private func saveEmployee() {
        hideKeyboard()
        // 兜底校验：按钮 gate 之外的异常路径也再确认一次
        guard viewModel.isFormValid else { return }
        let employee = Employee(
            id: editingEmployee?.id ?? UUID(),
            firstName: viewModel.firstName,
            lastName: viewModel.lastName,
            jobTitle: viewModel.jobTitle,
            avatarImageData: avatarImage?.jpegData(compressionQuality: 0.8)
        )
        onSave?(employee)
        dismiss()
    }

    private func prefillFromEmployee() {
        guard let employee = editingEmployee else { return }
        viewModel.firstName = employee.firstName
        viewModel.lastName = employee.lastName
        viewModel.jobTitle = employee.jobTitle
        if let data = employee.avatarImageData {
            avatarImage = UIImage(data: data)
        }
    }

    // MARK: - Date Picker Overlay

    private func datePickerOverlay(
        selectedDate: Binding<Date>,
        onConfirm: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            Color.black.opacity(0.01)
                .onTapGesture { onDismiss() }

            AppSingleDatePicker(
                initialDate: selectedDate.wrappedValue,
                onConfirm: { date in
                    selectedDate.wrappedValue = date
                    onConfirm()
                },
                onDismiss: onDismiss
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.25), value: showStartDatePicker)
        .animation(.easeInOut(duration: 0.25), value: showTerminationDatePicker)
    }

    // MARK: - Top Bar

    private func topBar(isNarrow: Bool) -> some View {
        HStack(spacing: Spacing.md) {
            Text(pageTitle)
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if isCompact {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.textEmphasis)
                        .padding(.horizontal, Spacing.lg)
                        .controlHeight(64)
                        .background(AppColors.buttonSecondaryBg)
                        .cornerRadius(AppRadius.Tablet.sm)
                }

                Button(action: saveEmployee) {
                    Text("Save")
                        .font(AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .padding(.horizontal, Spacing.lg)
                        .controlHeight(64)
                        .background(viewModel.isFormValid ? AppColors.buttonPrimaryBg : AppColors.buttonDisabledBg)
                        .cornerRadius(AppRadius.Tablet.sm)
                }
                .disabled(viewModel.isFormValid == false)
            } else {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textEmphasis)
                        .frame(width: isNarrow ? 140 : 200)
                        .controlHeight(64)
                        .background(AppColors.buttonSecondaryBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }

                Button(action: saveEmployee) {
                    Text("Save")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(width: isNarrow ? 140 : 200)
                        .controlHeight(64)
                        .background(viewModel.isFormValid ? AppColors.buttonPrimaryBg : AppColors.buttonDisabledBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
                .disabled(viewModel.isFormValid == false)
            }
        }
        .padding(.horizontal, isCompact ? Spacing.md : Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(AppColors.glass)
    }

    // MARK: - Scroll Content

    private var isDatePickerShowing: Bool {
        showStartDatePicker || showTerminationDatePicker
    }

    private func scrollContent(isNarrow: Bool) -> some View {
        let hPadding: CGFloat = isCompact ? Spacing.md : (isNarrow ? Spacing.xl : Spacing.xx100)

        return ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: isCompact ? Spacing.md : Spacing.lg) {
                    nameFields
                    jobTitleField.zIndex(5)
                    phoneFields
                    emailField
                    passcodeField
                    moreSettingsSection.zIndex(4)
                }
                .padding(.horizontal, hPadding)
                .padding(.top, isCompact ? Spacing.md : Spacing.xl)
                // 固定底部余量：键盘弹出时给聚焦字段提供向上滚动的空间。
                // 用固定常量而非 keyboardHeight，避免与系统键盘避让叠加顶起顶栏。
                .padding(.bottom, isDatePickerShowing ? 350 : 0)//300)
            }
            .scrollDismissesKeyboard(.interactively)
            // 键盘弹出后把聚焦字段滚到键盘上方（仅改滚动位置，不改布局尺寸，不顶顶栏）
            .keyboardFocusScroll(focused: focusedField, proxy: proxy)
            .onChange(of: showStartDatePicker) { _, isShowing in
                if isShowing {
                    hideKeyboard()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("dateFields", anchor: .top)
                        }
                    }
                }
            }
            .onChange(of: showTerminationDatePicker) { _, isShowing in
                if isShowing {
                    hideKeyboard()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("dateFields", anchor: .top)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Name Fields

    private var nameFields: some View {
        let layout = isCompact
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            FormTextField(
                title: "First Name",
                text: $viewModel.firstName,
                isRequired: true,
                fieldTag: 1,
                externalFocus: $focusedField
            )
            .id(1)
            FormTextField(
                title: "Last Name",
                text: $viewModel.lastName,
                isRequired: true,
                fieldTag: 2,
                externalFocus: $focusedField
            )
            .id(2)
        }
    }

    // MARK: - Job Title

    private var jobTitleField: some View {
        FormSelectField(
            title: "Job Title",
            options: viewModel.jobTitleOptions,
            selectedOptions: jobTitleBinding,
            isSingleSelect: true
        )
    }

    // MARK: - Phone Fields

    private var phoneFields: some View {
        let layout = isCompact
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            FormTextField(
                title: "Phone",
                text: $viewModel.phone,
                placeholder: "Optional",
                keyboardType: .phonePad,
                validate: FieldValidator.phone,
                fieldTag: 3,
                externalFocus: $focusedField
            )
            .id(3)
            FormTextField(
                title: "Mobile",
                text: $viewModel.mobile,
                placeholder: "Optional",
                keyboardType: .phonePad,
                validate: FieldValidator.phone,
                fieldTag: 4,
                externalFocus: $focusedField
            )
            .id(4)
        }
    }

    // MARK: - Email

    private var emailField: some View {
        FormTextField(
            title: "Email",
            text: $viewModel.email,
            keyboardType: .emailAddress,
            autocapitalization: .never,
            disableAutocorrection: true,
            validate: FieldValidator.email,
            fieldTag: 5,
            externalFocus: $focusedField
        )
        .id(5)
    }

    // MARK: - Passcode

    private var passcodeField: some View {
        FormTextField(
            title: "Passcode",
            text: $viewModel.passcode,
            placeholder: "Optional",
            keyboardType: .numberPad,
            fieldTag: 6,
            externalFocus: $focusedField
        )
        .id(6)
    }

    // MARK: - More Settings

    private var moreSettingsSection: some View {
        VStack(alignment: .leading, spacing: isCompact ? Spacing.md : Spacing.lg) {
            Button(action: { showMoreSettings.toggle() }) {
                HStack(spacing: Spacing.xxs) {
                    Text("More Settings")
                        .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Image(systemName: showMoreSettings ? "chevron.up" : "chevron.down")
                        .font(isCompact ? AppFont.mobileCaption1Regular : AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.top, isCompact ? Spacing.md : Spacing.xl)

            if showMoreSettings {
                VStack(alignment: .leading, spacing: isCompact ? Spacing.md : Spacing.lg) {
                    posSecurityRoleField.zIndex(3)
                    posAccessibilitiesField.zIndex(2)
                    payRateRow
                    dateFields.id("dateFields")
                    languageField.zIndex(1)
                    avatarSection
                }
            }
        }
    }

    // MARK: - POS Security Role

    private var posSecurityRoleField: some View {
        FormSelectField(
            title: "POS Security Role",
            options: viewModel.roleOptions,
            selectedOptions: rolesBinding
        )
    }

    // MARK: - POS Accessibilities

    private var posAccessibilitiesField: some View {
        FormSelectField(
            title: "POS Accessibilities",
            options: viewModel.accessibilityOptions,
            selectedOptions: accessibilitiesBinding
        )
    }

    // MARK: - Pay Rate Row

    private var payRateRow: some View {
        let layout = isCompact
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            FormTextField(
                title: "Pay Rate",
                text: $viewModel.payRate,
                placeholder: "0.00",
                keyboardType: .decimalPad,
                fieldTag: 7,
                externalFocus: $focusedField
            )
            .id(7)
            FormToggleInputField(
                title: "Bank Surcharge %",
                isOn: $viewModel.bankSurchargeEnabled,
                text: $viewModel.bankSurcharge,
                placeholder: "0.00",
                keyboardType: .decimalPad
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Date Fields

    private var dateFields: some View {
        let layout = isCompact
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            FormDateField(
                title: "Start Date",
                date: .constant(viewModel.startDate),
                isFocused: showStartDatePicker,
                onInputTapped: {
                    hideKeyboard()
                    showTerminationDatePicker = false
                    showStartDatePicker = true
                }
            )
            FormDateField(
                title: "Termination Date",
                date: .constant(viewModel.terminationDate),
                isFocused: showTerminationDatePicker,
                onInputTapped: {
                    hideKeyboard()
                    showStartDatePicker = false
                    showTerminationDatePicker = true
                }
            )
        }
    }

    // MARK: - Language

    private var languageField: some View {
        FormSelectField(
            title: "Language",
            options: viewModel.languageOptions,
            selectedOptions: languageBinding,
            isSingleSelect: true
        )
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        let avatarSize: CGFloat = isCompact ? 80 : 120

        return VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Avatar Image")
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputTitle)

            HStack(spacing: isCompact ? Spacing.md : Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(AppColors.card)
                        .frame(width: avatarSize, height: avatarSize)
                        .overlay(
                            Circle().stroke(AppColors.line, lineWidth: 1)
                        )

                    if let avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: avatarSize, height: avatarSize)
                            .clipShape(Circle())
                    } else {
                        Text(viewModel.avatarInitials)
                            .font(isCompact ? AppFont.mobileDisplay1Medium : AppFont.tabletDisplay5Semibold)
                            .foregroundColor(AppColors.primaryNormal)
                    }
                }

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Support jpg, png, jpeg formats, the maximum size is no more than 2M.")
                        .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textTertiary)

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text(avatarImage != nil ? "Change Image" : "Upload Image")
                            .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletH3Medium)
                            .foregroundColor(AppColors.primaryNormal)
                            .frame(maxWidth: isCompact ? .infinity : 200)
                            .controlHeight(64)
                            .background(AppColors.card)
                            .cornerRadius(AppRadius.Tablet.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                                    .stroke(AppColors.primaryNormal, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    cropItem = CropImageItem(image: image)
                }
            }
        }
        .sheet(item: $cropItem) { item in
            AvatarCropView(image: item.image) { cropped in
                avatarImage = cropped
                cropItem = nil
            } onCancel: {
                cropItem = nil
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddEmployeeView()
        .provideDeviceLayout()
}

#Preview("Dark Mode") {
    AddEmployeeView()
        .provideDeviceLayout()
        .preferredColorScheme(.dark)
}

