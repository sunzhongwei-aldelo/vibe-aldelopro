import SwiftUI

struct CashierBaseView: View {
    @State private var selectedMenuItem: CashierMenuItem = .noSale
    @Environment(AppUIManager.self) private var uiManager: AppUIManager?
    var body: some View {
        ZStack {
            AppColors.pageBgDeep.ignoresSafeArea(.all)

            VStack(spacing: 0) {
                // Top Bar
                CashierTopBar(
                    employeeName: "Zhang San",
                    clockInTime: "Clocked In 12:25 PM",
                    onBack: { handleBack() }
                )
                // Content Area
                
                GeometryReader { proxy in
                    ScrollView {
                        HStack(alignment: .top, spacing: Spacing.md) {
                            // Left Panel
                            CashierPanel(selectedItem: $selectedMenuItem)
                            // Main Content
                            
                            contentForSelectedItem
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 0,
                                        bottomLeadingRadius: AppRadius.Tablet.lg, // 左下角
                                        bottomTrailingRadius: AppRadius.Tablet.lg, // 右下角
                                        topTrailingRadius: 0
                                    )
                                )
                        }
                        .frame(height: proxy.size.height)
                    }
                    .scrollDisabled(true)
                }
                .padding(Spacing.md)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all,edges: .bottom)
            }
            
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }

    // MARK: - Content Routing
    @ViewBuilder
    private var contentForSelectedItem: some View {
        switch selectedMenuItem {
        case .payIn:
            CashierPayInView()
        case .payOut:
            CashierPayOutView()
        case .noSale:
            CashierNoSaleView()
                .padding(.horizontal, 150)
        case .editGratuity:
            EditGratuityView()
        case .report:
            CashierReportView(data: .mock)
        case .signOut:
            placeholderView(title: "Sign Out")
        }
    }

    // MARK: - Placeholder
    private func placeholderView(title: String) -> some View {
        VStack {
            Spacer()
            Text(title)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textSecondary)
            Text("Coming Soon")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.white100.opacity(0.5))
        )
    }

    // MARK: - Actions
    private func handleBack() {
        // TODO: Navigate back
    }
}

#Preview {
    CashierBaseView()
}
