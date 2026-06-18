//
//  RefundMainContainerView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - 退款主容器视图


// MARK: - RefundMainContainerView

/// Top-level container for the Order Refund module
/// Manages: global header bar, tab switching, iPad split-view (35%/65%), iPhone stack layout
/// State machine routing for the right workspace panel
/// 退款流程的顶级容器
/// 根据退款类型（整单退/部分退/自定义金额退）分流至对应子页面
struct RefundMainContainerView: View {

    // MARK: - State

    @State private var activeTab: RefundModuleTab = .paymentRefund
    @State private var paymentVM: PaymentRefundViewModel
    @State private var customVM: CustomRefundViewModel
    @State private var receiptSubFlow: ReceiptSubFlow?

    // Receipt menu state (managed at container level for full-screen overlay)
    @State private var isReceiptMenuPresented = false
    @State private var receiptMenuButtonRect: CGRect = .zero
    @State private var receiptMenuEntryID: String = ""
    @State private var receiptMenuPaymentID: String = ""
    @State private var receiptMenuAnchor: AldeloMenuAnchor = .bottomRight

    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.dismiss) private var dismiss

    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Init

    init(
        paymentVM: PaymentRefundViewModel = .preview(),
        customVM: CustomRefundViewModel = .preview()
    ) {
        _paymentVM = State(initialValue: paymentVM)
        _customVM = State(initialValue: customVM)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let subFlow = receiptSubFlow {
                receiptSubFlowView(subFlow)
            } else {
                mainContent
            }
        }
        .overlay {
            processingOverlay
        }
        .aldeloMenu(
            isPresented: $isReceiptMenuPresented,
            anchor: receiptMenuAnchor,
            buttonRect: receiptMenuButtonRect,
            items: [
                AldeloMenuItem(id: "email", icon: "envelope", title: "Email Receipt"),
                AldeloMenuItem(id: "print", icon: "printer.fill", title: "Print Receipt"),
                AldeloMenuItem(id: "text", icon: "iphone", title: "Text Receipt"),
            ]
        ) { selectedItem in
            handleReceiptMenuAction(selectedItem)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: activeTab)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerBar
                Divider().foregroundColor(AppColors.line)

                if isCompact && geometry.size.height > geometry.size.width {
                    // iPhone portrait: top-bottom stack
                    verticalLayout
                } else {
                    // iPad / iPhone landscape: 35% / 65% split
                    horizontalLayout(containerWidth: geometry.size.width)
                }
            }
            .background(AppColors.pageBg)
        }
    }

    // MARK: - Header Bar (matches design: order info left, AI search center, Back right)

    private var headerBar: some View {
        // 迁移至通用 AldeloTransactionHeaderView（B 族 Dine In 渠道 + AI 中心搜索条）：
        // 订单信息 LEFT，AI 条 CENTER，Back RIGHT。客数 "06" 借用 tableNumber 槽（person.2 图标）。
        AldeloTransactionHeaderView(
            channelTitle: "Dine In",
            channelColor: AppColors.orderTypeDineIn,
            channelIcon: "fork.knife",
            longOrderNo: "1200002",
            orderNumber: "#02",
            tableNumber: "06",
            serverName: "",
            actions: [.back({ dismiss() })],
            aiState: .idle
        )
    }

    // MARK: - Horizontal Layout (iPad / Landscape)

    private func horizontalLayout(containerWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Left panel: 35%
            leftPanel
                .frame(width: containerWidth * 0.35)
                .padding(Spacing.lg)

            Divider().foregroundColor(AppColors.line)

            // Right panel: 65%
            rightWorkspace
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(isCompact ? Spacing.md : Spacing.lg)
        }
    }

    // MARK: - Vertical Layout (iPhone Portrait)

    private var verticalLayout: some View {
        VStack(spacing: 0) {
            leftPanel
                .frame(height: 200)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

            Divider().foregroundColor(AppColors.line)

            ScrollView {
                rightWorkspace
                    .padding(Spacing.md)
            }
        }
    }

    // MARK: - Left Panel (tab selector + content)

    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            tabSelector
            leftPanelContent
        }
    }

    private var tabSelector: some View {
        AldeloSegment(
            selection: $activeTab,
            items: RefundModuleTab.allCases.map { $0 },
            titleMapper: { $0.title }
        )
    }

    @ViewBuilder
    private var leftPanelContent: some View {
        switch activeTab {
        case .paymentRefund:
            PaymentRefundMainView(
                payments: paymentVM.payments,
                selectedPaymentID: paymentVM.selectedPaymentID,
                onSelectPayment: { paymentVM.selectPayment($0) },
                onReceiptTap: { entryID, paymentID in
                    if entryID.hasPrefix("email_") {
                        receiptSubFlow = .email
                    } else if entryID.hasPrefix("text_") {
                        receiptSubFlow = .text
                    } else if entryID.hasPrefix("print_") {
                        // Print receipt action
                    }
                },
                onReceiptIconTap: { entryID, paymentID, rect in
                    receiptMenuEntryID = entryID
                    receiptMenuPaymentID = paymentID
                    receiptMenuButtonRect = rect
                    receiptMenuAnchor = .bottomRight
                    isReceiptMenuPresented = true
                }
            )
        case .customRefund:
            CustomRefundMainView(
                formattedPaidTotal: customVM.formattedPaidTotal,
                refundRecords: customVM.refundRecords,
                onReceiptTap: { entryID in
                    if entryID.hasPrefix("email_") {
                        customVM.dismissAllPopovers()
                        receiptSubFlow = .email
                    } else if entryID.hasPrefix("text_") {
                        customVM.dismissAllPopovers()
                        receiptSubFlow = .text
                    } else if entryID.hasPrefix("print_") {
                        customVM.dismissAllPopovers()
                    } else {
                        customVM.toggleReceiptPopover(entryID: entryID)
                    }
                }
            )
        }
    }

    // MARK: - Right Workspace (state machine routed)

    @ViewBuilder
    private var rightWorkspace: some View {
        VStack(spacing: 0) {
            switch activeTab {
            case .paymentRefund:
                paymentRightContent
            case .customRefund:
                customRightContent
            }
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColors.pageBg)
//        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
//        .shadow(color: AppColors.textPrimary.opacity(0.04), radius: 4, y: 2)
    }

    @ViewBuilder
    private var paymentRightContent: some View {
        switch paymentVM.currentStep {
        case .idle:
            RefundStatusWorkspace(mode: .idle)
        case .enterReason:
            RefundReasonSelector(
                displayedReason: paymentVM.displayedReason,
                selectedPreset: paymentVM.selectedPresetReason,
                isEditable: true,
                onSelectPreset: { paymentVM.selectPresetReason($0) },
                onUpdateReason: { paymentVM.refundReason = $0 },
                onConfirmReason: { paymentVM.confirmReason() },
                onEditReason: nil
            )
        case .enterAmount:
            VStack(spacing: Spacing.lg) {
                // 统一白色卡片：原因行 + 金额计价行合并为一体
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    RefundReasonSelector(
                        displayedReason: paymentVM.displayedReason,
                        selectedPreset: paymentVM.selectedPresetReason,
                        isEditable: false,
                        onSelectPreset: { _ in },
                        onUpdateReason: { _ in },
                        onConfirmReason: {},
                        onEditReason: { paymentVM.editReason() }
                    )
                    // 退款计价行
                    HStack {
                        Text("Refund")
                            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody1Regular)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(paymentVM.formattedRefundAmount)
                            .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletDisplay3Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(Spacing.md)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                        .shadow(color: AppColors.textPrimary.opacity(0.04), radius: 4, y: 2)
                    // Max Refundable 标签
                    HStack {
                        Spacer()
                        Text("Max Refundable: \(paymentVM.formattedMaxRefundable)")
                            .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                // 数字键盘（无金额显示，仅网格 + Refund 按钮）
                RefundAmountPinPad(
                    formattedAmount: paymentVM.formattedRefundAmount,
                    formattedMaxRefundable: paymentVM.formattedMaxRefundable,
                    canSubmit: paymentVM.canSubmitRefund,
                    showAmountCard: false,
                    onDigit: { paymentVM.appendDigit($0) },
                    onDoubleZero: { paymentVM.appendDoubleZero() },
                    onDelete: { paymentVM.deleteLastDigit() },
                    onClear: { paymentVM.clearAmount() },
                    onRefund: { paymentVM.submitRefund() }
                )
            }
        case .fullyRefunded:
            RefundStatusWorkspace(mode: .fullyRefunded(message: "Selected Payment Fully Refunded"))
        case .selectCustomMethod:
            EmptyView()
        }
    }

    @ViewBuilder
    private var customRightContent: some View {
        switch customVM.currentStep {
        case .idle:
            RefundStatusWorkspace(mode: .idle)
        case .enterReason:
            RefundReasonSelector(
                displayedReason: customVM.displayedReason,
                selectedPreset: customVM.selectedPresetReason,
                isEditable: true,
                onSelectPreset: { customVM.selectPresetReason($0) },
                onUpdateReason: { customVM.refundReason = $0 },
                onConfirmReason: { customVM.confirmReason() },
                onEditReason: nil
            )
        case .enterAmount:
            VStack(spacing: Spacing.lg) {
                // 统一白色卡片：原因行 + 金额计价行合并为一体
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    RefundReasonSelector(
                        displayedReason: customVM.displayedReason,
                        selectedPreset: customVM.selectedPresetReason,
                        isEditable: false,
                        onSelectPreset: { _ in },
                        onUpdateReason: { _ in },
                        onConfirmReason: {},
                        onEditReason: { customVM.editReason() }
                    )
                    Divider().foregroundColor(AppColors.line)
                    // 退款计价行
                    HStack {
                        Text("Refund")
                            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text(customVM.formattedRefundAmount)
                            .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletDisplay3Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    // Max Refundable 标签
                    HStack {
                        Spacer()
                        Text("Max Refundable: \(customVM.formattedMaxRefundable)")
                            .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody4Regular)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                // 数字键盘（无金额显示，仅网格 + Refund 按钮）
                RefundAmountPinPad(
                    formattedAmount: customVM.formattedRefundAmount,
                    formattedMaxRefundable: customVM.formattedMaxRefundable,
                    canSubmit: customVM.canSubmitRefund,
                    showAmountCard: false,
                    onDigit: { customVM.appendDigit($0) },
                    onDoubleZero: { customVM.appendDoubleZero() },
                    onDelete: { customVM.deleteLastDigit() },
                    onClear: { customVM.clearAmount() },
                    onRefund: { customVM.submitRefundToMethodSelection() }
                )
            }
        case .selectCustomMethod:
            RefundMethodSelector(
                onSelectMethod: { customVM.selectMethod($0) },
                onGoBack: { customVM.goBackFromMethodSelection() }
            )
        case .fullyRefunded:
            if customVM.isFullyRefunded {
                RefundStatusWorkspace(mode: .fullyRefunded(message: "Payment Fully Refunded"))
            } else {
                RefundStatusWorkspace(mode: .newRefundAvailable(onNewRefund: { customVM.startNewRefund() }))
            }
        }
    }

    // MARK: - Processing Overlay

    @ViewBuilder
    private var processingOverlay: some View {
        let state = activeTab == .paymentRefund ? paymentVM.processingState : customVM.processingState
        switch state {
        case .processing(let amount):
            processingHUD(title: "Processing Refund", amount: amount)
        case .waitingForCard(let amount):
            waitingForCardView(amount: amount)
        case .cashRefundTotal(let amount):
            cashRefundTotalView(amount: amount)
        case .success(let cardTitle, let amount):
            RefundSuccessBaseView(
                cardTitle: cardTitle,
                amount: amount,
                onSelectReceipt: { option in
                    handleReceiptSelection(option)
                }
            )
        default:
            EmptyView()
        }
    }

    private func processingHUD(title: String, amount: Decimal) -> some View {
        ZStack {
            AppColors.pageBg.ignoresSafeArea()
            VStack(spacing: Spacing.lg) {
                Text(title)
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(formatCurrency(amount))
                    .font(AppFont.tabletDisplay3Medium)
                    .foregroundColor(AppColors.textPrimary)
                // Card + return arrow illustration
                Image(systemName: "creditcard")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(AppColors.theme)
                Image(systemName: "hand.point.up.left")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(AppColors.theme)
            }
        }
    }

    private func cashRefundTotalView(amount: Decimal) -> some View {
        ZStack {
            AppColors.pageBg.ignoresSafeArea()
            VStack(spacing: Spacing.lg) {
                Spacer()
                Text("Cash Refund Total")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(formatCurrency(amount))
                    .font(AppFont.tabletDisplay3Medium)
                    .foregroundColor(AppColors.textPrimary)
                // Cash illustration
                Image(systemName: "banknote")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(AppColors.theme)
                Image(systemName: "hand.point.up.left")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(AppColors.theme)
                Spacer()
                Button { customVM.confirmCashRefund() } label: {
                    Text("Done")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(width: 300, height: 54)
                        .background(AppColors.buttonPrimaryBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
                .buttonStyle(.plain)
                Spacer().frame(height: Spacing.xl)
            }
            // Countdown badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    SelfDrivingCountdownBadge(totalSeconds: 10) {
                        customVM.confirmCashRefund()
                    }
                }
            }
            .padding(Spacing.lg)
        }
    }

    private func waitingForCardView(amount: Decimal) -> some View {
        ZStack {
            AppColors.pageBg.ignoresSafeArea()
            VStack(spacing: Spacing.lg) {
                Text("Waiting for Refund")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(formatCurrency(amount))
                    .font(AppFont.tabletDisplay3Medium)
                    .foregroundColor(AppColors.textPrimary)
                Image(systemName: "wave.3.right")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundColor(AppColors.theme)
                Spacer().frame(height: Spacing.xxxl)
                Button {
                    if activeTab == .paymentRefund {
                        paymentVM.cancelWaiting()
                    } else {
                        customVM.cancelWaiting()
                    }
                } label: {
                    Text("Cancel")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 240, height: 54)
                        .background(AppColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Receipt Sub-Flow

    enum ReceiptSubFlow {
        case email
        case text
    }

    @ViewBuilder
    private func receiptSubFlowView(_ flow: ReceiptSubFlow) -> some View {
        switch flow {
        case .email:
            RefundEmailReceiptInputView(
                onSend: { _ in receiptSubFlow = nil; completeCurrentRefund() },
                onGoBack: { receiptSubFlow = nil }
            )
        case .text:
            RefundTextReceiptInputView(
                onSend: { _ in receiptSubFlow = nil; completeCurrentRefund() },
                onGoBack: { receiptSubFlow = nil }
            )
        }
    }

    private func handleReceiptSelection(_ option: RefundReceiptOption) {
        // 必须先清除 processingState，否则 success 遮罩层会挡住收据输入页面
        clearProcessingState()
        switch option {
        case .email:
            receiptSubFlow = .email
        case .text:
            receiptSubFlow = .text
        case .print, .none:
            completeCurrentRefund()
        }
    }

    private func clearProcessingState() {
        if activeTab == .paymentRefund {
            paymentVM.cancelWaiting()
        } else {
            customVM.cancelWaiting()
        }

        }

    /// 处理收据菜单弹窗中的选项点击事件


    /// 完成当前退款流程（收据选择后的最终提交步骤）
    private func completeCurrentRefund() {
        if activeTab == .paymentRefund {
            paymentVM.completeRefund(receiptOption: .none)
        } else {
            customVM.completeRefund(receiptOption: .none)
        }
    }

    /// 格式化金额为美元货币显示字符串
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    private func handleReceiptMenuAction(_ item: AldeloMenuItem) {
        isReceiptMenuPresented = false
        switch item.id {
        case "email":
            receiptSubFlow = .email
        case "text":
            receiptSubFlow = .text
        case "print":
            completeCurrentRefund()
        default:
            completeCurrentRefund()
        }
    }
    }

// MARK: - Preview

#Preview("退款流程容器 - iPad") {
    RefundMainContainerView()
        .environment(\.horizontalSizeClass, .regular)
}
