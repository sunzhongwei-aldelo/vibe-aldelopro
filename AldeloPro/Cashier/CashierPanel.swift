import SwiftUI

enum CashierMenuItem: String, CaseIterable, Identifiable {
    case payIn = "Pay In"
    case payOut = "Pay Out"
    case noSale = "No Sale"
    case editGratuity = "Edit Gratuity"
    case report = "Report"
    case signOut = "Sign Out"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .payIn: return "creditcard"
        case .payOut: return "creditcard"
        case .noSale: return "tray"
        case .editGratuity: return "pencil.and.list.clipboard"
        case .report: return "chart.xyaxis.line"
        case .signOut: return "rectangle.portrait.and.arrow.right"
        }
    }
}

struct CashierPanel: View {
    @Binding var selectedItem: CashierMenuItem

    var body: some View {
        VStack(spacing: Spacing.md) {
            ForEach(CashierMenuItem.allCases) { item in
                CashierPanelButton(
                    item: item,
                    isSelected: selectedItem == item
                ) {
                    selectedItem = item
                }
            }
            //Spacer()
        }
        .padding(Spacing.md)
        .frame(width: 142)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.card.opacity(0.5))
        )
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}

struct CashierPanelButton: View {
    let item: CashierMenuItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: item.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.textEmphasis)
                    .frame(height: 35)
                Text(item.rawValue)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textEmphasis)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .fill(isSelected ? AppColors.optionSelectedFill : AppColors.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        isSelected ? AppColors.primaryNormal : Color.clear,
                        lineWidth: isSelected ? 3 : 0
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CashierPanel(selectedItem: .constant(.payIn))
        .frame(height: 694)
        .background(AppColors.pageBg)
}
