//
//  CashCountView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 现金盘点视图


// MARK: - Anchor Preference Key

private struct DenomAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

// MARK: - CashCountView

/// 收银员交班时的现金盘点页面
/// 以面额网格形式录入各币种数量，实时计算总额
struct CashCountView: View {

    // MARK: - ViewModel

    @State private var viewModel: CashierSignOutViewModel

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var hSizeClass

    // MARK: - Callbacks

    let onBack: () -> Void

    // MARK: - Init

    init(
        expectedAmount: Decimal = 100.00,
        onBack: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CashierSignOutViewModel(expectedAmount: expectedAmount))
        self.onBack = onBack
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isCompact = hSizeClass == .compact
            let isLandscape = w > h
            // iPad: width/1440, iPhone landscape: height/960, iPhone portrait: width/390
            let scale = isCompact
                ? (isLandscape ? h / 960 : w / 390)
                : w / 1440
            let sidePadding = isCompact
                ? Spacing.md
                : scale * 160

            ZStack {
                AppColors.pageBg.ignoresSafeArea()

                switch viewModel.step {
                case .cashCounting:
                    cashCountingLayout(sidePadding: sidePadding, isCompact: isCompact)
                case .processing:
                    cashCountingLayout(sidePadding: sidePadding, isCompact: isCompact)
                        .allowsHitTesting(false)
                    AldeloLoading(text: viewModel.loadingPhase.rawValue)
                case .success:
                    CashierSignOutSuccessView(onDone: { viewModel.exitSignOut() })
                }

                // Numpad: dismiss tap layer (numpad itself is in overlayPreferenceValue)
                if viewModel.editingDenominationID != nil {
                    numpadDismissLayer
                }

                // Clear All confirm alert
                if viewModel.showClearAllAlert {
                    AldeloAlert(
                        style: .warning,
                        title: "Clear All?",
                        onConfirm: { viewModel.clearAll() },
                        onCancel: { viewModel.showClearAllAlert = false }
                    )
                }

                // Done confirm alert
                if viewModel.showDoneAlert {
                    AldeloAlert(
                        style: .info,
                        title: "Submit Cash Count?",
                        confirmTitle: "Confirm",
                        onConfirm: {
                            viewModel.showDoneAlert = false
                            Task { await viewModel.submitCashCount() }
                        },
                        onCancel: { viewModel.showDoneAlert = false }
                    )
                }
            }
            .overlayPreferenceValue(DenomAnchorKey.self) { anchor in
                numpadAnchorOverlay(anchor: anchor)
            }
        }
        .onAppear { viewModel.onExit = onBack }
    }

    // MARK: - Grid Columns

    private func gridColumns(isCompact: Bool) -> [GridItem] {
        let count = isCompact ? 3 : 5
        return Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: count)
    }

    // MARK: - Cash Counting Layout

    private func cashCountingLayout(sidePadding: CGFloat, isCompact: Bool) -> some View {
        VStack(spacing: 0) {
            // 迁移至通用 AldeloModalHeaderView（C 族 + AI 中心槽）：
            // keyboard 图标 + "Cashier" 标题 LEFT，AI 条 CENTER(391/1440)，
            // 用户簇(头像+姓名+打卡) + Back 经 customTrailing 原样保留 RIGHT。
            AldeloModalHeaderView(
                leadingIcon: "keyboard",
                title: "Cashier",
                aiState: .idle,
                customTrailing: {
                    AnyView(
                        HStack(spacing: Spacing.lg) {
                            // User info
                            HStack(spacing: Spacing.sm) {
                                Circle()
                                    .fill(AppColors.theme.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text("Z")
                                            .font(AppFont.tabletH5Medium)
                                            .foregroundColor(AppColors.theme)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Zhang San")
                                        .font(AppFont.tabletCaption1Regular)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("Clocked In 12:25 PM")
                                        .font(AppFont.tabletCaption2Regular)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }

                            // Back button
                            Button(action: onBack) {
                                Text("Back")
                                    .font(AppFont.tabletH5Medium)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, Spacing.lg)
                                    .padding(.vertical, Spacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                            .fill(AppColors.card)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    )
                },
                background: AppColors.pageBgDeep
            )

            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Cash Count")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.textPrimary)

                    CashSummaryCard(
                        expectedFormatted: viewModel.expectedAmountFormatted,
                        actualFormatted: viewModel.actualTotalFormatted,
                        matchStatus: viewModel.matchStatus
                    )

                    denominationGridView(isCompact: isCompact)
                }
                .padding(.horizontal, sidePadding)
                .padding(.top, Spacing.md)
                .padding(.bottom, 100)
            }

            // Bottom action bar
            BottomActionBar(buttons: [
                .init(title: "Clear All", style: .secondary, action: {
                    viewModel.showClearAllAlert = true
                }),
                .init(title: "Done", style: .primary, action: {
                    viewModel.showDoneAlert = true
                })
            ])
        }
    }

    // MARK: - Denomination Grid

    private func denominationGridView(isCompact: Bool) -> some View {
        LazyVGrid(columns: gridColumns(isCompact: isCompact), spacing: Spacing.md) {
            ForEach(Array(viewModel.denominations.enumerated()), id: \.element.id) { _, denom in
                let isEditing = viewModel.editingDenominationID == denom.id

                DenominationGridItem(
                    denomination: denom,
                    isSelected: isEditing,
                    onTap: { viewModel.startEditDenomination(denom.id) }
                )
                .anchorPreference(key: DenomAnchorKey.self, value: .bounds) { anchor in
                    isEditing ? anchor : nil
                }
            }
        }
    }

    // MARK: - Numpad Anchor Overlay

    /// 键盘浮层：使用 anchor preference 精确定位在选中卡片右侧/左侧
    @ViewBuilder
    private func numpadAnchorOverlay(anchor: Anchor<CGRect>?) -> some View {
        if let anchor,
           let denom = viewModel.denominations.first(where: { $0.id == viewModel.editingDenominationID }) {
            GeometryReader { geo in
                let cardRect = geo[anchor]
                let isCompact = hSizeClass == .compact
                let numpadWidth: CGFloat = isCompact ? 280 : 342
                let gap: CGFloat = Spacing.sm
                let containerWidth = geo.size.width
                let containerHeight = geo.size.height

                // 决定放右侧还是左侧
                let spaceOnRight = containerWidth - cardRect.maxX
                let placeOnRight = spaceOnRight >= (numpadWidth + gap)
                let xPos = placeOnRight
                    ? cardRect.maxX + gap
                    : cardRect.minX - numpadWidth - gap

                // 如果键盘超出底部，改为底部对齐
                let numpadEstHeight: CGFloat = isCompact ? 420 : 480
                let yPos: CGFloat = (cardRect.minY + numpadEstHeight > containerHeight)
                    ? max(0, cardRect.maxY - numpadEstHeight)
                    : cardRect.minY

                NumpadView(
                    quantity: Binding(
                        get: { viewModel.editingQuantityValue },
                        set: { viewModel.editingQuantityValue = $0 }
                    ),
                    style: .quantity,
                    backgroundStyle: .liquidGlass,
                    onCommit: { viewModel.confirmDenominationQuantity() },
                    primaryButtonTitle: "Confirm",
                    titleText: "Qty For \(denom.label)"
                )
                .frame(width: numpadWidth)
                .fixedSize(horizontal: false, vertical: true)
                .offset(x: max(0, xPos), y: max(0, yPos))
                .transition(.opacity)
                .animation(.easeOut(duration: 0.15), value: viewModel.editingDenominationID)
            }
        }
    }

    // MARK: - Numpad Dismiss Layer

    private var numpadDismissLayer: some View {
        Color.black.opacity(0.001)
            .ignoresSafeArea()
            .onTapGesture { viewModel.dismissDenominationKeypad() }
    }

}

// MARK: - Preview

#Preview("Cash Count - iPad") {
    CashCountView(expectedAmount: 100.00, onBack: {})
}

