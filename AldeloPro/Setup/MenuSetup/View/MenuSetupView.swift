//
//  MenuSetupView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/6/8.
//

import SwiftUI
import AVFoundation

struct MenuSetupView: View {
    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // MARK: - ViewModel
    @State private var viewModel = MenuSetupViewModel()

    // MARK: - Camera Permission State
    /// 进入 ScanUploadView 后是否直接开相机（取决于入口预检的权限状态）。
    @State private var shouldLaunchCamera = true

    // MARK: - Callbacks
    var onPreviousStep: (() -> Void)?
    var onSkipStep: (() -> Void)?
    var onSaveAndNextStep: (() -> Void)?

    // MARK: - Body
    var body: some View {
        ZStack {
            let isCompact = layout.isPhonePortrait
            let isNarrow = layout == .iPadPortrait
            
            AppColors.pageBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SetupTopBarView(progress: 0.6)
                
                Group {
                    if viewModel.showManualSetup {
                        MenuSetupManualView(
                            viewModel: viewModel,
                            isNarrow: isCompact ? true : isNarrow,
                            onPreviousStep: onPreviousStep,
                            onSaveAndNextStep: onSaveAndNextStep,
                            onScanOrUpload: { checkCameraPermissionAndPresent() }
                        )
                    } else {
                        MenuSetupMethodSelectionView(
                            viewModel: viewModel,
                            isCompact: isCompact,
                            isNarrow: isNarrow,
                            onPreviousStep: onPreviousStep,
                            onSkipStep: onSkipStep,
                            onScanOrUpload: { checkCameraPermissionAndPresent() }
                        )
                    }
                }
                .padding(.horizontal, !layout.iPadLandscape ? Spacing.md : Spacing.xx100)
            }
        }
        .fullScreenCover(item: $viewModel.presentedMethod) { method in
            destinationView(for: method)
        }
        .fullScreenCover(isPresented: $viewModel.showMenuGroupView, onDismiss: {
            viewModel.editingGroupId = nil
        }) {
            ManageMenuGroupView(existingGroups: viewModel.menuGroups, focusGroupId: viewModel.editingGroupId) { updatedGroups in
                viewModel.updateGroups(updatedGroups)
            }
            .presentationBackground(.clear)
        }
        .fullScreenCover(item: $viewModel.addItemPresentation) { presentation in
            switch presentation {
            case .create(let groupId):
                AddItemView(
                    availableGroups: viewModel.menuGroups,
                    initialGroupId: groupId,
                    optionGroupPool: viewModel.optionGroupPool,
                    onCreateOptionGroup: { viewModel.upsertOptionGroupInPool($0) }
                ) { item in
                    viewModel.addItem(item)
                }
            case .edit(let editItem):
                AddItemView(
                    availableGroups: viewModel.menuGroups,
                    initialGroupId: editItem.groupId,
                    editingItem: editItem,
                    optionGroupPool: viewModel.optionGroupPool,
                    onCreateOptionGroup: { viewModel.upsertOptionGroupInPool($0) }
                ) { item in
                    viewModel.updateItem(originalId: editItem.id, with: item)
                }
            case .editPending(let editItem):
                AddItemView(
                    availableGroups: viewModel.pendingGroups,
                    initialGroupId: editItem.groupId,
                    editingItem: editItem,
                    optionGroupPool: viewModel.optionGroupPool,
                    onCreateOptionGroup: { viewModel.upsertOptionGroupInPool($0) }
                ) { item in
                    viewModel.updatePendingItem(originalId: editItem.id, with: item)
                }
            }
        }
        .overlay {
            if viewModel.isProcessing {
                ProcessingLoadingView(message: viewModel.processingMessage)
            }
        }
        .overlay {
            if viewModel.showConfirmMenu {
                ConfirmMenuView(
                    menuGroups: viewModel.pendingGroups,
                    menuItems: viewModel.pendingItems,
                    onBack: { viewModel.cancelConfirm() },
                    onConfirm: { viewModel.confirmPendingMenu() },
                    onEditItem: { viewModel.editPendingItem($0) },
                    onDeleteItem: { viewModel.requestDeletePendingItem($0) }
                )
            }
        }
        .menuSetupDeleteAlerts(viewModel: viewModel)
    }

    // MARK: - Camera Permission Check
    /// 点击 Scan or Upload 时预检相机权限（逻辑与 EmployeeSetupView 一致）。
    /// authorized → 进页并直接开相机；notDetermined → 请求后进页；denied/restricted → 进页但不开相机，权限提示由 ScanUploadView 内部处理。
    private func checkCameraPermissionAndPresent() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            shouldLaunchCamera = true
            viewModel.presentedMethod = .scanOrUpload
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    shouldLaunchCamera = granted
                    viewModel.presentedMethod = .scanOrUpload
                }
            }
        case .denied, .restricted:
            shouldLaunchCamera = false
            viewModel.presentedMethod = .scanOrUpload
        @unknown default:
            shouldLaunchCamera = false
            viewModel.presentedMethod = .scanOrUpload
        }
    }

    // MARK: - Present 目标
    @ViewBuilder
    private func destinationView(for method: SetupMethod) -> some View {
        switch method {
        case .manuallyAdd:
            EmptyView()
        case .aiVoiceChat:
            placeholderView(title: "AI Voice Chat")
        case .scanOrUpload:
            ScanUploadView(
                shouldLaunchCamera: shouldLaunchCamera,
                headerTitle: "Scan or Upload Menu",
                scanHint: "Please Align the Menu for Scanning",
                onBack: { viewModel.presentedMethod = nil },
                onNext: { scannedPages, _ in
                    viewModel.presentedMethod = nil
                    viewModel.startProcessing(hasScannedPages: scannedPages.isEmpty == false)
                }
            )
            .presentationBackground(.clear)
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

            Button(action: { viewModel.presentedMethod = nil }) {
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
}

#Preview {
    MenuSetupView()
}
