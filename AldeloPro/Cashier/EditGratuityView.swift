import SwiftUI

// MARK: - Data Models

struct GratuityTransaction: Identifiable {
    let id = UUID()
    let index: Int
    let orderType: OrderTypeIcon
    let ticketNumber: String
    let authCode: String
    let server: String
    let cardInfo: String
    let cardBadge: String?
    let pmtId: String
    let dateTime: String
    let transactionType: String
    let saleAmount: String
    var tipAmount: String
    let totalAmount: String
    let cardBalance: String?
    let status: GratuityStatus
}

enum GratuityStatus {
    case open
    case adjusted

    var label: String {
        switch self {
        case .open: return "Open"
        case .adjusted: return "Adjusted"
        }
    }

    var textColor: Color {
        switch self {
        case .open: return AppColors.primaryNormal
        case .adjusted: return AppColors.successNormal
        }
    }

    var bgColor: Color {
        switch self {
        case .open: return AppColors.primaryNormal.opacity(0.08)
        case .adjusted: return AppColors.successNormal.opacity(0.08)
        }
    }

    var strokeColor: Color {
        switch self {
        case .open: return AppColors.primaryNormal
        case .adjusted: return AppColors.successNormal
        }
    }
}

enum OrderTypeIcon {
    case dineIn
    case takeOut
    case bar
    case delivery
    case retail
    case driveThru

    var color: Color {
        switch self {
        case .dineIn: return AppColors.orderTypeDineIn
        case .takeOut: return AppColors.orderTypeTakeOut
        case .bar: return AppColors.orderTypeBar
        case .delivery: return AppColors.orderTypeDelivery
        case .retail: return AppColors.orderTypeRetail
        case .driveThru: return AppColors.orderTypeDriveThru
        }
    }

    var iconName: String {
        switch self {
        case .dineIn: return "fork.knife"
        case .takeOut: return "bag"
        case .bar: return "wineglass"
        case .delivery: return "car"
        case .retail: return "cart"
        case .driveThru: return "person.crop.rectangle"
        }
    }
}

enum GratuityFilterTab: String, CaseIterable {
    case all = "All"
    case open = "Open"
    case adjusted = "Adjusted"
}

enum GratuitySearchField: String, CaseIterable {
    case orderNumber = "Order Number"
    case cardNumber = "Card Number"
    case authCode = "Auth Code"
}



// MARK: - Main View

struct EditGratuityView: View {
    @State private var selectedTab: GratuityFilterTab = .all
    @State private var searchField: GratuitySearchField = .orderNumber
    @State private var searchText: String = ""
    @State private var showSearchFieldDropdown = false
    @State private var transactions: [GratuityTransaction] = GratuityTransaction.sampleData
    @State private var editingTransactionId: UUID?
    @State private var editingTipValue: Double = 0
    @State private var originalTipValue: Double = 0
    @State private var tipButtonFrame: CGRect = .zero
    @State private var showSearchNumpad = false
    @State private var searchNumpadValue: Double = 0
    @State private var searchByFrame: CGRect = .zero
    @State private var showScanReceipt = false

    @Environment(AppUIManager.self) private var uiManager: AppUIManager?
    var filteredTransactions: [GratuityTransaction] {
        var result = transactions
        if selectedTab == .open {
            result = result.filter { $0.status == .open }
        } else if selectedTab == .adjusted {
            result = result.filter { $0.status == .adjusted }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.ticketNumber.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                filterAndSearchBar
                    .zIndex(10)
                ScrollView {
                    LazyVStack(spacing: Spacing.xs) {
                        ForEach(filteredTransactions) { transaction in
                            TransactionCard(
                                transaction: transaction,
                                isEditing: editingTransactionId == transaction.id,
                                editingTipValue: editingTransactionId == transaction.id ? editingTipValue : 0,
                                onTipTapped: { frame in
                                    tipButtonFrame = frame
                                    openNumpad(for: transaction)
                                },
                                onTipUpdated: { newTip in
                                    updateTip(for: transaction.id, newTip: newTip)
                                }
                            )
                        }
                    }
                    //.padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.xs)
                    .padding(.bottom, Spacing.md)
                }
                bottomBar
            }



            // Full-screen numpad overlay for tip editing
            if editingTransactionId != nil {
                Color.black.opacity(0.01)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        cancelEditing()
                    }

                GeometryReader { geo in
                    let screenHeight = geo.size.height
                    let numpadHeight: CGFloat = 320
                    let desiredY = tipButtonFrame.maxY + Spacing.xs
                    let clampedY = min(desiredY, screenHeight - numpadHeight - Spacing.md)
                    let posX = tipButtonFrame.midX

                    HalfNumpadView(
                        value: $editingTipValue,
                        buttonTitle: "Update",
                        onCommit: {
                            commitEditing()
                        }
                    )
                    .position(x: posX - 140, y: clampedY + numpadHeight / 2 + 50)
                }
                .allowsHitTesting(true)
            }

            // Full-screen numpad overlay for search
            if showSearchNumpad {
                Color.black.opacity(0.01)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showSearchNumpad = false
                    }

                GeometryReader { geo in
                    let screenHeight = geo.size.height
                    let numpadHeight: CGFloat = 320
                    let desiredY = searchByFrame.maxY + Spacing.xs
                    let clampedY = min(desiredY, screenHeight - numpadHeight - Spacing.md)
                    let posX = searchByFrame.midX

                    HalfNumpadView(
                        value: $searchNumpadValue,
                        buttonTitle: "Search",
                        onCommit: {
                            performSearch()
                        }
                    )
                    .position(x: posX - 80, y: clampedY + numpadHeight / 2 + 50)
                }
                .allowsHitTesting(true)
            }
        }
        .coordinateSpace(name: "editGratuityRoot")
        .background(AppColors.pageBgDeep)
//        .fullScreenCover(isPresented: $showScanReceipt) {
//            ZStack {
////                Color.black.opacity(0.5)
////                    .ignoresSafeArea()
////                    .onTapGesture {
////                        showScanReceipt = false
////                    }
//
//                ScanReceiptView(onBack: {
//                    showScanReceipt = false
//                })
//                .frame(width: 660, height: 760)
//                .background(AppColors.card)
//                .cornerRadius(AppRadius.Tablet.lg)
//                .shadow(color: AppColors.black8, radius: 24, y: 8)
//            }
//            .presentationBackground(.ultraThinMaterial)
//            
//        }
        
    }

    private func openNumpad(for transaction: GratuityTransaction) {
        let parsed = parseCurrency(transaction.tipAmount)
        originalTipValue = parsed
        editingTipValue = parsed
        editingTransactionId = transaction.id
    }

    private func cancelEditing() {
        editingTipValue = originalTipValue
        editingTransactionId = nil
    }

    private func commitEditing() {
        guard let id = editingTransactionId else { return }
        let newTipString = formatAsCurrency(editingTipValue)
        updateTip(for: id, newTip: newTipString)
        editingTransactionId = nil
    }

    private func performSearch() {
        let searchValue = Int(searchNumpadValue)
        searchText = searchValue > 0 ? String(searchValue) : ""
        showSearchNumpad = false
    }

    private func parseCurrency(_ str: String) -> Double {
        let cleaned = str.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned) ?? 0
    }

    private func formatAsCurrency(_ value: Double) -> String {
        return String(format: "$%.2f", value)
    }

    private func updateTip(for id: UUID, newTip: String) {
        guard let index = transactions.firstIndex(where: { $0.id == id }) else { return }
        transactions[index].tipAmount = newTip
    }

    // MARK: - Filter & Search Bar

    private var filterAndSearchBar: some View {
        HStack(spacing: 0) {
            filterTabs
            searchArea
        }
        
        .padding(.bottom, Spacing.xs)
    }

    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(GratuityFilterTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(selectedTab == tab ? AppColors.primaryNormal : AppColors.textTertiary)
                        .frame(width: 102, height: 40)
                        .background(
                            selectedTab == tab
                                ? AppColors.primaryLight
                                : Color.clear
                        )
                        .cornerRadius(AppRadius.Tablet.sm)
                        .padding(Spacing.xxs)
                        
                }
            }
        }
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
    }

    private var searchArea: some View {
        HStack(spacing: 0) {
            searchFieldSelector
                .zIndex(2)

            Rectangle()
                .fill(AppColors.line)
                .frame(width: 1)

            GeometryReader { geo in
                HStack(spacing: Spacing.xs) {
                    if searchNumpadValue > 0 || !searchText.isEmpty {
                        Text(searchNumpadValue > 0 ? String(Int(searchNumpadValue)) : searchText)
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textPrimary)
                    } else {
                        Text("Search By \(searchField.rawValue)")
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textTertiary)
                    }
                    Spacer()
                    if searchNumpadValue > 0 || !searchText.isEmpty {
                        Button {
                            searchNumpadValue = 0
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.textTertiary)
                                .font(.system(size: 18))
                        }
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textTertiary)
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, Spacing.md)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    searchByFrame = geo.frame(in: .named("editGratuityRoot"))
                    searchNumpadValue = 0
                    showSearchNumpad = true
                }
            }
        }
        .frame(height: 48)
        .background(AppColors.card.cornerRadius(AppRadius.Tablet.sm))
        .padding(.leading, Spacing.xs)
    }

    private var searchFieldSelector: some View {
        ZStack(alignment: .topLeading) {
            Button {
                showSearchFieldDropdown.toggle()
            } label: {
                HStack(spacing: Spacing.xs) {
                    Text(searchField.rawValue)
                        .font(AppFont.tabletH5Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, Spacing.md)
                .frame(width: 180, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .fill(AppColors.primaryLight)
                        .padding(Spacing.xxs)
                )
            }
            .overlay(alignment: .topLeading) {
                if showSearchFieldDropdown {
                    ZStack(alignment: .topLeading) {
                        // Full-screen dismiss layer behind dropdown
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showSearchFieldDropdown = false
                            }
                            .offset(x: -200, y: -100)

                        VStack(spacing: 0) {
                            ForEach(GratuitySearchField.allCases, id: \.self) { field in
                                Button {
                                    searchField = field
                                    showSearchFieldDropdown = false
                                } label: {
                                    Text(field.rawValue)
                                        .font(AppFont.tabletH4Medium)
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, Spacing.md)
                                        .padding(.vertical, Spacing.sm)
                                }
                                if field != GratuitySearchField.allCases.last {
                                    Divider()
                                }
                            }
                        }
                        .background(AppColors.card)
                        .cornerRadius(AppRadius.Tablet.sm)
                        .shadow(color: AppColors.black8, radius: 8, y: 4)
                        .frame(width: 180)
                        .offset(y: 52)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColors.primaryNormal)
                .font(.system(size: 16))
            Text("Tip Adjust Not Available On Gift Card Remote Redemptions.")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)

            Spacer()

            //Scan Receipt Button
            AldeloButton(title: "Scan Receipt", icon: Image(systemName: "viewfinder")) {
                uiManager?.presentCover {
                    ScanReceiptView(onBack: {
                        uiManager?.dismissCover()
                    })
                    .frame(width: 660, height: 760)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
                    .shadow(color: AppColors.black8, radius: 24, y: 8)
                }
                
            }.frame(width: 223)
            
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(AppColors.card)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColors.line)
                .frame(height: 1)
        }
    }
}

// MARK: - Transaction Card

struct TransactionCard: View {
    let transaction: GratuityTransaction
    var isEditing: Bool = false
    var editingTipValue: Double = 0
    var onTipTapped: ((_ frame: CGRect) -> Void)?
    var onTipUpdated: ((String) -> Void)?

    /// Badge shape: only top-right and bottom-left corners are rounded (8pt)
    private let badgeShape = UnevenRoundedRectangle(
        topLeadingRadius: 0,
        bottomLeadingRadius: AppRadius.Tablet.sm,
        bottomTrailingRadius: 0,
        topTrailingRadius: AppRadius.Tablet.sm
    )

    var body: some View {
        HStack(spacing: 0) {
            // Left: info rows
            VStack(alignment: .leading, spacing: Spacing.sm) {
                topLeftRow
                detailRow1
                detailRow2
            }

            Spacer(minLength: Spacing.md)

            // Right: amounts
            amountsSection
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(alignment: .topTrailing) {
            statusBadge
        }
    }

    // MARK: - Top Left Row

    private var topLeftRow: some View {
        HStack(spacing: Spacing.sm) {
            Text("#\(String(format: "%02d", transaction.index))")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            // Order type icon
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .fill(transaction.orderType.color)
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: transaction.orderType.iconName)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.white100)
                )

            Text(transaction.ticketNumber)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)

            // Order view button
            Button {
                // view order
            } label: {
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.line, lineWidth: 1)
                    .frame(width: 35, height: 35)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.sm)
                    .overlay(
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textPrimary)
                    )
            }
        }
    }

    // MARK: - Detail Row 1: Auth Code + Card

    private var detailRow1: some View {
        HStack(spacing: Spacing.lg) {
            detailItem(label: "Auth Code", value: transaction.authCode, valueFont: AppFont.tabletBody5Regular)

            HStack(spacing: Spacing.xs) {
                detailItem(label: "Card", value: transaction.cardInfo, valueFont: AppFont.tabletH6Medium)
                if let badge = transaction.cardBadge {
                    Text(badge)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.primaryNormal)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(AppColors.primaryNormal.opacity(0.08))
                        .cornerRadius(AppRadius.Tablet.xs)
                }
            }
        }
    }

    // MARK: - Detail Row 2: Server + PMT + DateTime

    private var detailRow2: some View {
        HStack(spacing: Spacing.lg) {
            detailItem(
                label: "Server",
                value: transaction.server,
                valueFont: AppFont.tabletCaption1Regular,
                labelFont: AppFont.tabletCaption1Regular
            )
            detailItem(
                label: "PMT",
                value: transaction.pmtId,
                valueFont: AppFont.tabletCaption1Regular,
                labelFont: AppFont.tabletCaption1Regular
            )

            Text(transaction.dateTime)
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Amounts Section

    private var amountsSection: some View {
        HStack(alignment: .top, spacing: Spacing.lg) {
            if let cardBal = transaction.cardBalance {
                amountColumn(title: "Card Bal", value: cardBal, valueColor: AppColors.warningNormal)
            }

            amountColumn(title: transaction.transactionType, value: transaction.saleAmount, valueColor: AppColors.textPrimary)

            // Tip (tappable, opens numpad)
            tipField

            amountColumn(title: "Total", value: transaction.totalAmount, valueColor: AppColors.textPrimary)
        }
    }

    // MARK: - Tip Field

    private var tipField: some View {
        VStack(spacing: Spacing.xs) {
            Text("Tip")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)

            tipButton
        }
    }

    private var tipButton: some View {
        Text(displayedTipAmount)
            .font(AppFont.tabletH5Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(AppColors.primaryLight)
            .cornerRadius(6)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let frame = geo.frame(in: .named("editGratuityRoot"))
                            onTipTapped?(frame)
                        }
                }
            )
    }

    private var displayedTipAmount: String {
        if isEditing {
            return String(format: "$%.2f", editingTipValue)
        }
        return transaction.tipAmount
    }

    private func amountColumn(title: String, value: String, valueColor: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFont.tabletH5Medium)
                .foregroundColor(valueColor)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
        }
    }

    // MARK: - Detail Item Helper

    private func detailItem(
        label: String,
        value: String,
        valueFont: Font,
        labelFont: Font = AppFont.tabletBody5Regular
    ) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(labelFont)
                .foregroundColor(AppColors.textTertiary)
            Text(value)
                .font(valueFont)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Status Badge

    private var statusBadge: some View {
        Text(transaction.status.label)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(transaction.status.textColor)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                badgeShape
                    .fill(transaction.status.bgColor)
            )
            .overlay(
                badgeShape
                    .stroke(transaction.status.strokeColor, lineWidth: 1)
            )
            .clipShape(badgeShape)
    }
}

// MARK: - Sample Data

extension GratuityTransaction {
    static let sampleData: [GratuityTransaction] = [
        GratuityTransaction(
            index: 1, orderType: .dineIn, ticketNumber: "1200001",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Visa xxxx1234", cardBadge: nil,
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Auth", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: nil, status: .open
        ),
        GratuityTransaction(
            index: 2, orderType: .takeOut, ticketNumber: "1200002",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Visa xxxx1234", cardBadge: nil,
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Sale", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: nil, status: .open
        ),
        GratuityTransaction(
            index: 3, orderType: .bar, ticketNumber: "1200003",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Gift Card xxxx1234", cardBadge: "Code Entry",
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Sale", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: "$90.00", status: .open
        ),
        GratuityTransaction(
            index: 4, orderType: .delivery, ticketNumber: "1200004",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Gift Card xxxx1234", cardBadge: "QR Scan",
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Sale", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: "$90.00", status: .open
        ),
        GratuityTransaction(
            index: 5, orderType: .retail, ticketNumber: "1200005",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Visa xxxx1234", cardBadge: nil,
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Sale", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: nil, status: .adjusted
        ),
        GratuityTransaction(
            index: 6, orderType: .driveThru, ticketNumber: "1200006",
            authCode: "000478", server: "Zhang San",
            cardInfo: "Visa xxxx1234", cardBadge: nil,
            pmtId: "01KERJJ25N80GEDBPTPWYNFMF3",
            dateTime: "2025-09-09  07:58 PM",
            transactionType: "Sale", saleAmount: "$10.00",
            tipAmount: "$2.00", totalAmount: "$12.00",
            cardBalance: nil, status: .adjusted
        ),
    ]
}

// MARK: - Preview

#Preview {
    EditGratuityView()
}
