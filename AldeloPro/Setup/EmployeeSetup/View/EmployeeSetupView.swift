//
//  EmployeeSetupView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/04.
//

import SwiftUI
import AVFoundation

// MARK: - 员工设置入口页（选择添加方式）

struct EmployeeSetupView: View {
    // MARK: - Environment
    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // MARK: - State
    @State private var presentedMethod: SetupMethod?
    @State private var editingEmployee: Employee?
    @State private var employeeStore = EmployeeStore()
    @State private var isProcessing = false
    @State private var processingMessage = "Document Processing By AI..."
    @State private var shouldLaunchCameraOnPresent = true

    var isPhone: Bool { layout.isPhonePortrait }
        
    // MARK: - Callbacks
    var onPreviousStep: (() -> Void)?
    var onSkipStep: (() -> Void)?
    var onCompleteSetup: (() -> Void)?

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.pageBg
                .ignoresSafeArea()

            if layout.isPhonePortrait {
                compactLayout(isNarrow: true)
            } else {
                regularLayout(isNarrow: layout == .iPadPortrait)
            }
        }
        .fullScreenCover(item: $presentedMethod) { method in
            destinationView(for: method)
        }
        .overlay {
            if isProcessing {
                ProcessingLoadingView(message: processingMessage)
            }
        }
        .fullScreenCover(item: $editingEmployee) { employee in
            AddEmployeeView(editingEmployee: employee, onSave: { updated in
                employeeStore.update(updated)
            })
        }
    }

    // MARK: - iPhone 竖屏布局（ScrollView + 全宽弹性）
    private func compactLayout(isNarrow: Bool) -> some View {
        VStack(spacing: 0) {
            SetupTopBarView(progress: 0.8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if employeeStore.hasEmployees {
                        compactTitleWithActions
                        compactEmployeeList
                    } else {
                        compactTitleSection
                        compactCardsSection
                    }
                }
            }

            compactBottomButtons
        }
    }

    // MARK: - iPad 布局（横屏/竖屏）
    private func regularLayout(isNarrow: Bool) -> some View {
        VStack(spacing: 0) {
            SetupTopBarView(progress: 0.8)
            
            VStack {
                if employeeStore.hasEmployees {
                    regularTitleWithActions(isNarrow: isNarrow)
                    employeeListSection(isNarrow: isNarrow)
                } else {
                    regularTitleSection
                    cardsSection(isNarrow: isNarrow)
                }
            }
            .padding(.horizontal, !layout.iPadLandscape ? Spacing.md : Spacing.xx100)
            
            Spacer()
            regularBottomButtons
        }
    }

    // MARK: - Present 目标
    @ViewBuilder
    private func destinationView(for method: SetupMethod) -> some View {
        switch method {
        case .manuallyAdd:
            AddEmployeeView(onSave: { employee in
                employeeStore.add(employee)
            })
        case .aiVoiceChat:
            placeholderView(title: "AI Voice Chat")
        case .scanOrUpload:
            ScanUploadView(
                shouldLaunchCamera: shouldLaunchCameraOnPresent,
                onBack: { presentedMethod = nil },
                onNext: { scannedPages, uploadedFiles in
                    presentedMethod = nil
                    if scannedPages.isEmpty == false {
                        processingMessage = "Image Processing By AI..."
                    } else {
                        processingMessage = "Document Processing By AI..."
                    }
                    isProcessing = true
                    simulateProcessing()
                }
            )
            .presentationBackground(.clear)
        }
    }

    // MARK: - Camera Permission Check
    private func checkCameraPermissionAndPresent() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            shouldLaunchCameraOnPresent = true
            presentedMethod = .scanOrUpload
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    shouldLaunchCameraOnPresent = granted
                    presentedMethod = .scanOrUpload
                }
            }
        case .denied, .restricted:
            shouldLaunchCameraOnPresent = false
            presentedMethod = .scanOrUpload
        @unknown default:
            shouldLaunchCameraOnPresent = false
            presentedMethod = .scanOrUpload
        }
    }

    // MARK: - Simulate AI Processing (Demo)
    private func simulateProcessing() {
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            let demoEmployees: [Employee] = [
                Employee(id: UUID(), firstName: "Emily", lastName: "Johnson", jobTitle: "Waiter"),
                Employee(id: UUID(), firstName: "Michael", lastName: "Davis", jobTitle: "Waiter"),
                Employee(id: UUID(), firstName: "Jame", lastName: "Smith", jobTitle: "Waiter"),
                Employee(id: UUID(), firstName: "Benjamin", lastName: "Hayes", jobTitle: "Waiter"),
                Employee(id: UUID(), firstName: "Olivia", lastName: "Thomas", jobTitle: "Waiter")
            ]
            for emp in demoEmployees {
                employeeStore.add(emp)
            }
            isProcessing = false
        }
    }

    private func placeholderView(title: String) -> some View {
        ZStack(alignment: .topLeading) {
            AppColors.pageBg.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                Text(title)
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text("Coming Soon")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { presentedMethod = nil }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.primaryNormal)
            }
            .padding(.top, Spacing.lg)
            .padding(.leading, Spacing.lg)
        }
    }

    // MARK: - iPad 标题（空状态）
    private var regularTitleSection: some View {
        Text("Employee Setup")
            .font(AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.top, Spacing.xxxl)
            .padding(.bottom, Spacing.xxxxxxxl)
    }

    // MARK: - iPad 标题 + 操作按钮（有员工状态）
    private func regularTitleWithActions(isNarrow: Bool) -> some View {
        HStack {
            Text("Employee Setup")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            HStack(spacing: Spacing.md) {
                actionButton(icon: "doc.badge.plus", title: "Add", compact: false) {
                    presentedMethod = .manuallyAdd
                }
                actionButton(icon: "camera.fill", title: "Scan", compact: false) {
                    checkCameraPermissionAndPresent()
                }
                actionButton(icon: "AI Voice Chat", title: "Chat", compact: false) {
                    presentedMethod = .aiVoiceChat
                }
            }
        }
        .padding(.top, Spacing.xxxl)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - iPhone 标题（空状态）
    private var compactTitleSection: some View {
        Text("Employee Setup")
            .font(AppFont.mobileH1Medium)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xl)
    }

    // MARK: - iPhone 标题 + 操作按钮
    private var compactTitleWithActions: some View {
        HStack {
            Text("Employee Setup")
                .font(AppFont.mobileH1Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            HStack(spacing: Spacing.xs) {
                actionButton(icon: "doc.badge.plus", title: "", compact: true) {
                    presentedMethod = .manuallyAdd
                }
                actionButton(icon: "camera.fill", title: "", compact: true) {
                    checkCameraPermissionAndPresent()
                }
                actionButton(icon: "AI Voice Chat", title: "", compact: true) {
                    presentedMethod = .aiVoiceChat
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - 操作按钮
    private func actionButton(icon: String, title: String, compact: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(icon)
                    .font(compact ? AppFont.mobileBody1Medium : AppFont.tabletH4Medium)
                if compact == false {
                    Text(title)
                        .font(AppFont.tabletH3Medium)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, compact ? Spacing.sm : Spacing.lg)
            .frame(height: 50)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.xs)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 员工列表（固定两列）
    private func employeeListSection(isNarrow: Bool) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 2)

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.md) {
                ForEach(employeeStore.employees) { employee in
                    regularEmployeeCard(employee: employee)
                }
            }
        }
    }

    // MARK: - iPad 员工卡片
    private func regularEmployeeCard(employee: Employee) -> some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.pageBg)
                    .frame(width: 64, height: 64)
                if let data = employee.avatarImageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                } else {
                    Text(employee.initials)
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.buttonPrimaryBg)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(employee.fullName)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "person.fill")
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text(employee.jobTitle)
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Button(action: { editingEmployee = employee }) {
                Image(.frame2)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: { employeeStore.removeById(employee.id) }) {
                Image(.frame3)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 115)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(AppColors.buttonPrimaryBg)
                .frame(width: 10, height: 10)
                .offset(x: 10, y: 10)
        }
    }

    // MARK: - iPhone 员工列表
    private var compactEmployeeList: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(employeeStore.employees) { employee in
                compactEmployeeCard(employee: employee)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - iPhone 员工卡片
    private func compactEmployeeCard(employee: Employee) -> some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.pageBg)
                    .frame(width: 44, height: 44)
                if let data = employee.avatarImageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Text(employee.initials)
                        .font(AppFont.mobileH2Medium)
                        .foregroundColor(AppColors.buttonPrimaryBg)
                }
            }
            .padding(.leading, Spacing.sm)

            VStack(alignment: .leading, spacing: 2) {
                Text(employee.fullName)
                    .font(AppFont.mobileH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text(employee.jobTitle)
                    .font(AppFont.mobileBody2Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: Spacing.xs)

            Button(action: { editingEmployee = employee }) {
                Image(.frame2)
                    .font(AppFont.mobileH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: { employeeStore.removeById(employee.id) }) {
                Image(.frame3)
                    .font(AppFont.mobileH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(AppColors.buttonPrimaryBg)
                .frame(width: 8, height: 8)
                .offset(x: 10, y: 10)
        }
    }

    // MARK: - iPad 三张方式卡片
    private func cardsSection(isNarrow: Bool) -> some View {
        let layout = isNarrow
            ? AnyLayout(VStackLayout(spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.md))

        return layout {
            methodCard(method: .aiVoiceChat, icon: "AI Voice Chat", title: "AI Voice Chat", compact: false)
            methodCard(method: .scanOrUpload, icon: "Scan or Upload", title: "Scan or Upload", compact: false)
            methodCard(method: .manuallyAdd, icon: "Manually Add", title: "Manually Add", compact: false)
        }
    }

    // MARK: - iPhone 三张方式卡片（横向：图标左 + 文字右）
    private var compactCardsSection: some View {
        VStack(spacing: Spacing.sm) {
            compactMethodCard(method: .aiVoiceChat, icon: "AI Voice Chat", title: "AI Voice Chat")
            compactMethodCard(method: .scanOrUpload, icon: "Scan or Upload", title: "Scan or Upload")
            compactMethodCard(method: .manuallyAdd, icon: "Manually Add", title: "Manually Add")
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - iPhone 单张方式卡片（横向布局）
    private func compactMethodCard(method: SetupMethod, icon: String, title: String) -> some View {
        return Button {
            if method == .scanOrUpload {
                checkCameraPermissionAndPresent()
            } else {
                presentedMethod = method
            }
        } label: {
            HStack(spacing: Spacing.md) {
                Image(icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 32, alignment: .center)

                Text(title)
                    .font(AppFont.mobileH2Medium)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.md)
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 单张方式卡片（纵向布局）
    private func methodCard(method: SetupMethod, icon: String, title: String, compact: Bool) -> some View {
        return Button {
            if method == .scanOrUpload {
                checkCameraPermissionAndPresent()
            } else {
                presentedMethod = method
            }
        } label: {
            VStack(spacing: Spacing.md) {
                Image(icon)
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.textPrimary)

                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad 底部按钮
    private var regularBottomButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                onPreviousStep?()
            } label: {
                Text("Previous Step")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            if employeeStore.hasEmployees {
                Button {
                    onCompleteSetup?()
                } label: {
                    Text("Complete Setup")
                        .font(AppFont.tabletButton3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(maxWidth: 382)
                        .controlHeight(64)
                        .background(AppColors.buttonPrimaryBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    onSkipStep?()
                } label: {
                    Text("Skip This Step")
                        .font(AppFont.tabletButton3Medium)
                        .foregroundColor(AppColors.buttonTextColor)
                        .frame(maxWidth: 382)
                        .controlHeight(64)
                        .background(AppColors.card)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - iPhone 底部按钮
    private var compactBottomButtons: some View {
        VStack(spacing: Spacing.sm) {
            if employeeStore.hasEmployees {
                Button {
                    onCompleteSetup?()
                } label: {
                    Text("Complete Setup")
                        .font(AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .controlHeight(64)
                        .background(AppColors.buttonPrimaryBg)
                        .cornerRadius(AppRadius.Tablet.md)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    onSkipStep?()
                } label: {
                    Text("Skip This Step")
                        .font(AppFont.mobileButton2Medium)
                        .foregroundColor(AppColors.buttonTextColor)
                        .frame(maxWidth: .infinity)
                        .controlHeight(64)
                        .background(AppColors.card)
                        .cornerRadius(AppRadius.Tablet.md)
                }
                .buttonStyle(.plain)
            }

            Button {
                onPreviousStep?()
            } label: {
                Text("Previous Step")
                    .font(AppFont.mobileButton2Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.md)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
    }
}

// MARK: - 添加方式枚举

enum SetupMethod: String, CaseIterable, Identifiable, Hashable {
    case aiVoiceChat
    case scanOrUpload
    case manuallyAdd

    var id: String { rawValue }
}

// MARK: - Preview

#Preview {
    EmployeeSetupView()
        .provideDeviceLayout()
}
