import SwiftUI

// MARK: - Pay Out Tab Enum

enum PayOutTab: String, CaseIterable, Identifiable {
    case payOut = "Pay Out"
    case tipOut = "Tip Out"
    case safeDrop = "Safe Drop"
    case refund = "Refund"

    var id: String { rawValue }

    var recordsTitle: String {
        switch self {
        case .payOut: return "Pay Out Records"
        case .tipOut: return "Tip Out Records"
        case .safeDrop: return "Safe Drop Records"
        case .refund: return "Refund Records"
        }
    }
}

// MARK: - Record Models

struct PayOutRecord: Identifiable {
    let id = UUID()
    let paidBy: String
    let paidTo: String?
    let date: String
    let amount: String
    let reason: String?
    let orderNo: String?
    let paymentType: String?
    let pmt: String?
}

// MARK: - Main View

struct CashierPayOutView: View {
    @State private var selectedTab: PayOutTab = .payOut
    @State private var records: [PayOutRecord] = PayOutRecord.sampleRecords(for: .payOut)

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // Left: Tab Bar + Content
            VStack(spacing: Spacing.sm) {
                tabBar
                tabContent
            }
            .frame(maxWidth: .infinity)

            // Right: Records List (full height)
            recordsPanel
        }
    }

    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(PayOutTab.allCases) { tab in
                Button(action: {
                    selectedTab = tab
                    records = PayOutRecord.sampleRecords(for: tab)
                }) {
                    Text(tab.rawValue)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(selectedTab == tab ? AppColors.primaryNormal : AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                                .fill(selectedTab == tab ? AppColors.white100 : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.textSecondary, lineWidth: 1)
        )
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .payOut:
            PayOutContentView()
        case .tipOut:
            TipOutContentView()
        case .safeDrop:
            SafeDropContentView()
        case .refund:
            RefundContentView()
        }
    }

    // MARK: - Records Panel
    private var recordsPanel: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(selectedTab.recordsTitle)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            ScrollView {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(records) { record in
                        recordRow(record)
                    }
                }
            }
        }
        .padding(Spacing.sm)
        .frame(maxWidth: 374)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.white100.opacity(0.5))
        )
    }

    // MARK: - Record Row
    private func recordRow(_ record: PayOutRecord) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            if let orderNo = record.orderNo {
                HStack {
                    Text(orderNo)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    if let paymentType = record.paymentType {
                        Text(paymentType)
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xs) {
                        Text(recordLabel(for: selectedTab))
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textMuted)
                        Text(record.paidBy)
                            .font(AppFont.tabletH4Medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    if let paidTo = record.paidTo {
                        HStack(spacing: Spacing.xs) {
                            Text("Paid To")
                                .font(AppFont.tabletH4Medium)
                                .foregroundColor(AppColors.textMuted)
                            Text(paidTo)
                                .font(AppFont.tabletH4Medium)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    if let reason = record.reason {
                        HStack(spacing: Spacing.xs) {
                            Text("Refund Reason")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textMuted)
                            Text(reason)
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    if let pmt = record.pmt {
                        HStack(spacing: Spacing.xs) {
                            Text("PMT")
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textMuted)
                            Text(pmt)
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
                Spacer()
                Text(record.amount)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.primaryNormal)
            }

            Text(record.date)
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.white100)
        )
    }

    private func recordLabel(for tab: PayOutTab) -> String {
        switch tab {
        case .payOut: return "Paid Out By"
        case .tipOut: return "Tip Out By"
        case .safeDrop: return "Safe Drop By"
        case .refund: return "Refund By"
        }
    }
}

// MARK: - Pay Out Content

private struct PayOutContentView: View {
    @State private var payee: String = ""
    @State private var reason: String = ""
    @State private var amountText: String = "0.00"

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Payee dropdown
            dropdownField(
                icon: "person",
                placeholder: "Enter Or Select A Payee",
                text: $payee
            )

            // Reason dropdown
            dropdownField(
                icon: "doc.text",
                placeholder: "Enter Or Select A Reason",
                text: $reason
            )

            // Amount
            amountField(amountText: $amountText)

            // Numpad + Action
            NumpadWithAction(amountText: $amountText, actionTitle: "Pay Out")
        }
    }
}

// MARK: - Tip Out Content

private struct TipOutContentView: View {
    @State private var selectedPayee: String?

    private let employees: [TipOutEmployee] = [
        TipOutEmployee(name: "James Johnson", tips: "$5.00"),
        TipOutEmployee(name: "Tom Williams", tips: "$5.00"),
        TipOutEmployee(name: "Emily Anderson", tips: "$5.00"),
        TipOutEmployee(name: "Alex Brown", tips: "$5.00"),
        TipOutEmployee(name: "Ben Jones", tips: "$5.00"),
        TipOutEmployee(name: "Eva Miller", tips: "$5.00"),
        TipOutEmployee(name: "Sam Wilson", tips: "$5.00"),
        TipOutEmployee(name: "Max Taylor", tips: "$5.00"),
        TipOutEmployee(name: "Nick Thomas", tips: "$5.00"),
        TipOutEmployee(name: "Ella Moore", tips: "$5.00"),
        TipOutEmployee(name: "Anna Martin", tips: "$5.00"),
        TipOutEmployee(name: "Bella Sanchez", tips: "$5.00"),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Select A Payee")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.sm) {
                    ForEach(employees) { emp in
                        employeeCard(emp)
                    }
                }
            }

            Spacer()

            AldeloButton(title: "Tip Out",size: .large) {
                
            }
            .frame(width: 379)

        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.white100.opacity(0.5))
        )
    }

    private func employeeCard(_ employee: TipOutEmployee) -> some View {
        Button(action: { selectedPayee = employee.name }) {
            VStack(spacing: Spacing.sm) {
                Text(employee.name)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Divider()

                VStack(spacing: Spacing.xxs) {
                    Text("Tips Payable")
                        .font(AppFont.tabletBody4Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text(employee.tips)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.primaryNormal)
                }
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity)
            .frame(height: 131)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(AppColors.white100)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(
                        selectedPayee == employee.name ? AppColors.primaryNormal : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TipOutEmployee: Identifiable {
    let id = UUID()
    let name: String
    let tips: String
}

// MARK: - Safe Drop Content

private struct SafeDropContentView: View {
    @State private var amountText: String = "0.00"

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Amount
            amountField(amountText: $amountText)

            // Numpad + Action
            NumpadWithAction(amountText: $amountText, actionTitle: "Safe Drop")
        }
    }
}

// MARK: - Refund Content

private struct RefundContentView: View {
    @State private var orderNo: String = ""
    @State private var reason: String = ""
    @State private var refundType: String = ""
    @State private var amountText: String = "0.00"

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Order No.
            dropdownField(
                icon: "doc.plaintext",
                placeholder: "Search By Order No.",
                text: $orderNo
            )

            // Reason
            dropdownField(
                icon: "doc.text",
                placeholder: "Enter Or Select A Refund Reason",
                text: $reason
            )

            // Refund Type
            dropdownField(
                icon: "creditcard",
                placeholder: "Select Refund Type",
                text: $refundType
            )

            // Amount
            amountField(amountText: $amountText)

            // Numpad + Action
            NumpadWithAction(amountText: $amountText, actionTitle: "Refund")
        }
    }
}

// MARK: - Shared Components

private func dropdownField(icon: String, placeholder: String, text: Binding<String>) -> some View {
    HStack(spacing: Spacing.sm) {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(AppColors.textSecondary)
        TextField(placeholder, text: text)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
        Spacer()
        Image(systemName: "chevron.down")
            .font(.system(size: 14))
            .foregroundColor(AppColors.textSecondary)
    }
    .padding(.horizontal, Spacing.sm)
    .frame(height: 58)
    .background(
        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
            .fill(AppColors.inputBg)
    )
}

private func amountField(amountText: Binding<String>) -> some View {
    HStack {
        Text("Amount")
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textSecondary)
        Spacer()
        Text("$\(amountText.wrappedValue)")
            .font(AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
    }
    .padding(.horizontal, Spacing.sm)
    .frame(height: 62)
    .background(
        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
            .fill(AppColors.inputBg)
    )
}

// MARK: - Numpad With Action Button

struct NumpadWithAction: View {
    @Binding var amountText: String
    let actionTitle: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            numpadGrid
            actionColumn
        }
    }

    private var numpadGrid: some View {
        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                numKey("1"); numKey("2"); numKey("3")
            }
            HStack(spacing: Spacing.sm) {
                numKey("4"); numKey("5"); numKey("6")
            }
            HStack(spacing: Spacing.sm) {
                numKey("7"); numKey("8"); numKey("9")
            }
            HStack(spacing: Spacing.sm) {
                numKey("0")
                doubleZeroKey
            }
        }
    }

    private func numKey(_ value: String) -> some View {
        Button(action: { appendDigit(value) }) {
            Text(value)
                .font(AppFont.tabletDisplay3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.white100)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.line, lineWidth: 1.4)
                )
        }
        .buttonStyle(.plain)
    }

    private var doubleZeroKey: some View {
        Button(action: { appendDigit("00") }) {
            Text("00")
                .font(AppFont.tabletDisplay3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.white100)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.line, lineWidth: 1.4)
                )
        }
        .buttonStyle(.plain)
    }

    private var actionColumn: some View {
        VStack(spacing: Spacing.sm) {
            // Top half: Backspace + Clear (align with rows 1-2)
            VStack(spacing: Spacing.sm) {
                // Backspace
                Button(action: { handleBackspace() }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(AppColors.white100)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(AppColors.line, lineWidth: 1.4)
                        )
                }
                .buttonStyle(.plain)

                // Clear
                Button(action: { amountText = "0.00" }) {
                    Text("C")
                        .font(AppFont.tabletDisplay3Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(AppColors.white100)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(AppColors.line, lineWidth: 1.4)
                        )
                }
                .buttonStyle(.plain)
            }

            // Bottom half: Action button (align with rows 3-4: "9" and "00")
            Button(action: {}) {
                Text(actionTitle)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.white100)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .fill(AppColors.buttonPrimaryBg)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(width: 120)
    }

    private func appendDigit(_ value: String) {
        if amountText == "0.00" {
            amountText = value
        } else {
            amountText += value
        }
    }

    private func handleBackspace() {
        if !amountText.isEmpty {
            amountText.removeLast()
        }
        if amountText.isEmpty {
            amountText = "0.00"
        }
    }
}

// MARK: - Sample Data

extension PayOutRecord {
    static func sampleRecords(for tab: PayOutTab) -> [PayOutRecord] {
        switch tab {
        case .payOut:
            return [
                PayOutRecord(paidBy: "Zhang San", paidTo: "Anderson", date: "2025-09-09  07:58 PM", amount: "-$10.00", reason: nil, orderNo: nil, paymentType: nil, pmt: nil)
            ]
        case .tipOut:
            return [
                PayOutRecord(paidBy: "Mike", paidTo: "Mike", date: "2025-09-09  07:58 PM", amount: "-$5.00", reason: nil, orderNo: nil, paymentType: nil, pmt: nil)
            ]
        case .safeDrop:
            return [
                PayOutRecord(paidBy: "Zhang San", paidTo: nil, date: "2025-09-09  07:58 PM", amount: "-$10.00", reason: nil, orderNo: nil, paymentType: nil, pmt: nil)
            ]
        case .refund:
            return [
                PayOutRecord(paidBy: "Zhang San", paidTo: nil, date: "2025-09-09  07:58 PM", amount: "-$100.00", reason: "Cash Refund", orderNo: "#50324", paymentType: "Cash", pmt: "01KF06FHD5X1RE7Z5ZZGERHB6G")
            ]
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CashierTopBar(
            employeeName: "Zhang San",
            clockInTime: "Clocked In 12:25 PM",
            onBack: { }
        )
        GeometryReader { geometry in
            ScrollView {
                CashierPayOutView()
                    .frame(minHeight: geometry.size.height)
                    .background(AppColors.pageBg)
            }
            .scrollDisabled(true)
            .background(Color.blue)
        }
    }
    .ignoresSafeArea(.container, edges: .bottom)
}
