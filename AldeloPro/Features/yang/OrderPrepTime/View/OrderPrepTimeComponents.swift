import SwiftUI

// MARK: - Day Card (Expandable)

struct PrepTimeDayCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            if isExpanded {
                content
            }
        }
        .padding(16)
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }
}

// MARK: - Order Type Grid (2 columns)

struct PrepTimeOrderTypeGrid: View {
    let orderTypes: [PrepTimeOrderType]
    let getSelection: (PrepTimeOrderType) -> PrepTimeOption?
    let setSelection: (PrepTimeOrderType, PrepTimeOption) -> Void

    private var rows: [[PrepTimeOrderType]] {
        stride(from: 0, to: orderTypes.count, by: 2).map { i in
            Array(orderTypes[i..<min(i + 2, orderTypes.count)])
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.first?.id) { row in
                HStack(spacing: 16) {
                    ForEach(row) { orderType in
                        PrepTimeDropdownRow(
                            orderType: orderType,
                            selection: getSelection(orderType),
                            onSelect: { setSelection(orderType, $0) }
                        )
                    }
                    if row.count == 1 {
                        Spacer().frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Dropdown Row (icon + label + picker)

struct PrepTimeDropdownRow: View {
    let orderType: PrepTimeOrderType
    let selection: PrepTimeOption?
    let onSelect: (PrepTimeOption) -> Void

    @State private var showPicker = false

    var body: some View {
        HStack(spacing: 8) {
            // Order type chip
            HStack(spacing: 6) {
                Image(systemName: orderType.iconName)
                    .font(.system(size: 9))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Color(hex: orderType.iconColorHex))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text(orderType.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Dropdown button
            Button {
                showPicker.toggle()
            } label: {
                HStack(spacing: 4) {
                    Text(selection?.label ?? "Select Prep Time")
                        .font(.system(size: 12))
                        .foregroundStyle(
                            selection != nil
                                ? AppColors.textPrimary
                                : AppColors.inputPlaceholder
                        )
                    Spacer()
                    Image(systemName: showPicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppColors.line, lineWidth: 1)
                )
            }
            .popover(isPresented: $showPicker) {
                PrepTimePickerGrid(
                    selectedOption: selection,
                    onSelect: { option in
                        onSelect(option)
                        showPicker = false
                    }
                )
                .frame(width: 360, height: 200)
                .presentationCompactAdaptation(.popover)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Picker Grid (5 columns, popover content)

struct PrepTimePickerGrid: View {
    let selectedOption: PrepTimeOption?
    let onSelect: (PrepTimeOption) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(PrepTimeOption.allOptions) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option.label)
                            .font(.system(size: 12))
                            .foregroundStyle(
                                selectedOption == option
                                    ? AppColors.primaryNormal
                                    : AppColors.textPrimary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        selectedOption == option
                                            ? AppColors.primaryNormal
                                            : AppColors.line,
                                        lineWidth: selectedOption == option ? 1.5 : 1
                                    )
                            )
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
    }
}
