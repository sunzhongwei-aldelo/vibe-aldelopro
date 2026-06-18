import SwiftUI

struct OrderCreationView: View {
    @StateObject private var viewModel: OrderCreationViewModel

    init(orderType: OrderCreationType = .dineIn,
         orderNumber: String = "#015",
         tableNumber: String = "01",
         serverName: String = "Zhang San") {
        _viewModel = StateObject(wrappedValue: OrderCreationViewModel(
            orderType: orderType,
            orderNumber: orderNumber,
            tableNumber: tableNumber,
            serverName: serverName
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            OrderCreationHeaderView(viewModel: viewModel)

            ScrollView {
                formContent
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .sheet(isPresented: $viewModel.showLimitedAuth) {
            limitedAuthSheet
        }
        .fullScreenCover(isPresented: $viewModel.showCardTap) {
            CardTapView(
                mode: viewModel.cardTapMode,
                onCancel: { viewModel.onCardTapCancel() },
                onVerified: { viewModel.onCardVerified() }
            )
        }
        .fullScreenCover(isPresented: $viewModel.showApproved) {
            AuthApprovedView(
                amount: approvedAmount,
                onDone: { viewModel.onDone() }
            )
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        VStack(spacing: Spacing.lg) {
            guestsCountSection

            if viewModel.orderType.hasTabNameOption {
                barModeToggle
                barFormContent
            } else {
                customerSection
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Guests Count

    private var guestsCountSection: some View {
        HStack {
            Text("Guests Count")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            HStack(spacing: Spacing.xs) {
                Button(action: { viewModel.decrementGuests() }) {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(AppColors.pageBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                }

                Text("\(viewModel.guestsCount)")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 80, height: 40)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(AppColors.line, lineWidth: 1)
                    )

                Button(action: { viewModel.incrementGuests() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(AppColors.pageBg)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                }
            }
        }
    }

    // MARK: - Customer Section

    private var customerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Customer")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: Spacing.md) {
                // Phone Number
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Phone Number")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)

                    TextField(viewModel.phonePlaceholder, text: $viewModel.phoneNumber)
                        .font(AppFont.tabletBody2Regular)
                        .keyboardType(.asciiCapableNumberPad)
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 44)
                        .background(AppColors.inputBg)
                        .cornerRadius(AppRadius.Tablet.sm)
                }
                .frame(maxWidth: .infinity)

                // Name
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Name")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)

                    TextField(viewModel.namePlaceholder, text: $viewModel.customerName)
                        .font(AppFont.tabletBody2Regular)
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 44)
                        .background(AppColors.inputBg)
                        .cornerRadius(AppRadius.Tablet.sm)
                }
                .frame(maxWidth: .infinity)
            }

            // Address
            if viewModel.config.addressRequirement != .hidden {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Address")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)

                    TextField(viewModel.addressPlaceholder, text: $viewModel.address)
                        .font(AppFont.tabletBody2Regular)
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 44)
                        .background(AppColors.inputBg)
                        .cornerRadius(AppRadius.Tablet.sm)
                }
            }
        }
    }

    // MARK: - Bar Mode

    private var barModeToggle: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                ForEach(BarInputMode.allCases, id: \.rawValue) { mode in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.barInputMode = mode
                        }
                    }) {
                        Text(mode.rawValue)
                            .font(AppFont.tabletButton4Medium)
                            .foregroundColor(viewModel.barInputMode == mode ? AppColors.primaryNormal : AppColors.textSecondary)
                            .frame(width: 120, height: 36)
                            .background(viewModel.barInputMode == mode ? Color.white : Color.clear)
                            .cornerRadius(AppRadius.Tablet.sm)
                    }
                }
            }
            .padding(4)
            .background(AppColors.segmentBg)
            .cornerRadius(AppRadius.Tablet.md)
            Spacer()
        }
    }

    private var barFormContent: some View {
        Group {
            if viewModel.barInputMode == .tabName {
                tabNameSection
            } else {
                customerSection
            }
        }
    }

    private var tabNameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Tab Name")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            TextField("Enter tab name", text: $viewModel.tabName)
                .font(AppFont.tabletBody2Regular)
                .padding(.horizontal, Spacing.md)
                .frame(height: 44)
                .background(AppColors.inputBg)
                .cornerRadius(AppRadius.Tablet.sm)
        }
    }

    // MARK: - Limited Auth Sheet

    private var limitedAuthSheet: some View {
        Group {
            switch viewModel.limitedAuthMode {
            case .numpad:
                LimitedAuthView(viewModel: viewModel)
            case .amountGrid:
                LimitedAuthGridView(viewModel: viewModel)
            }
        }
    }

    private var approvedAmount: Decimal? {
        if case .preAuth(let amount) = viewModel.cardTapMode {
            return amount
        }
        return nil
    }
}

// MARK: - Preview

#Preview {
    OrderCreationView(orderType: .dineIn)
}

#Preview("Delivery") {
    OrderCreationView(orderType: .delivery, orderNumber: "#015")
}

#Preview("Take Out") {
    OrderCreationView(orderType: .takeOut, orderNumber: "#016")
}

#Preview("Bar") {
    OrderCreationView(orderType: .bar, orderNumber: "#016")
}
