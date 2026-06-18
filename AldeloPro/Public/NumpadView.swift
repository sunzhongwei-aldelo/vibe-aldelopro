import SwiftUI

// MARK: - Numpad Style
//定义数字键盘的五种风格
enum NumpadStyle {
    case order
    case share
    case update
    case search
    case quantity
}

// MARK: - Numpad Background Style

enum NumpadBackgroundStyle {
    /// 灰色半透明背景（默认）
    case translucent
    /// 液态玻璃效果（毛玻璃模糊 + 微光边框）
    case liquidGlass
}

// MARK: - Numpad View

struct NumpadView: View {
    @Binding var quantity: Int
    var style: NumpadStyle = .order
    var backgroundStyle: NumpadBackgroundStyle = .translucent
    var onDetails: () -> Void = {}
    var onSoldOut: () -> Void = {}
    var onCommit: () -> Void = {}   //右下角button， order 、 share
    var primaryButtonTitle: String? = nil
    var titleText: String? = nil
    var minValue: Int? = nil
    var maxValue: Int? = nil

    @State private var inputBuffer: String = ""
    @State private var isEditing: Bool = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    private var resolvedButtonTitle: String {
        if let title = primaryButtonTitle { return title }
        switch style {
        case .order: return "Order"
        case .share: return "Share"
        case .update: return "Update"
        case .search: return "Search"
        case .quantity: return "Share"
        }
    }

    private var showsStepper: Bool {
        switch style {
        case .order, .share: return true
        case .update, .search, .quantity: return false
        }
    }

    // MARK: - Limit State

    private var effectiveMax: Int {
        maxValue ?? 999
    }

    private var effectiveMin: Int {
        minValue ?? 0
    }

    private var isAtMax: Bool {
        quantity >= effectiveMax
    }

    private var isAtMin: Bool {
        quantity <= effectiveMin
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            if style == .order {
                actionBar
            }
            if style == .quantity {
                quantityHeader
                quantityInputField
            }
            if showsStepper {
                quantityStepper
            }
            numberGrid
            if style == .search {
                searchButton
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, 20)
        .frame(width: 342)
        .background {
            if backgroundStyle == .liquidGlass {
                // 液态玻璃：直接用 material ShapeStyle 填充，不叠加任何不透明色
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.5)
                    )
            } else {
                // 灰色半透明
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(AppColors.numpadPanelBg.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .shadow(
            color: Color.black.opacity(backgroundStyle == .liquidGlass ? 0.25 : 0.15),
            radius: backgroundStyle == .liquidGlass ? 20 : 10,
            x: 0,
            y: backgroundStyle == .liquidGlass ? 8 : 4
        )
    }


    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: Spacing.md) {
            Button(action: onDetails) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                    Text("Details")
                        .font(AppFont.tabletBody5Regular)
                }
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.buttonSecondaryBg)
                )
            }
            .buttonStyle(.plain)

            Button(action: onSoldOut) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "tag.slash")
                        .font(.system(size: 16, weight: .medium))
                    Text("Sold Out")
                        .font(AppFont.tabletBody5Regular)
                }
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.buttonSecondaryBg)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Quantity Stepper

    private var quantityStepper: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: decrementQuantity) {
                Image(systemName: "minus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isAtMin ? AppColors.textTertiary : AppColors.textEmphasis)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .fill(AppColors.buttonSecondaryBg)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isAtMin)

            Text(displayValue)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(isAtMin ? AppColors.textTertiary : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.buttonSecondaryBg)
                )

            Button(action: incrementQuantity) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isAtMax ? AppColors.textTertiary : AppColors.textEmphasis)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .fill(AppColors.buttonSecondaryBg)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isAtMax)
        }
    }

    // MARK: - Quantity Header & Input

    private var quantityHeader: some View {
        Text(titleText ?? "")
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.white100)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var quantityInputField: some View {
        HStack(spacing: 0) {
            Text(displayValue)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .fill(AppColors.buttonSecondaryBg)
        )
    }

    // MARK: - Number Grid

    private var numberGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: Spacing.sm) {
            ForEach(1...9, id: \.self) { number in
                numberButton("\(number)") { appendDigit(number) }
            }
            backspaceButton
            numberButton("0") { appendDigit(0) }
            gridBottomRightButton
        }
    }

    /// 网格右下角按钮：search 样式用 "Clear" 普通按钮，其余用蓝色主按钮
    @ViewBuilder
    private var gridBottomRightButton: some View {
        switch style {
        case .search:
            clearButton
        case .order, .share, .update, .quantity:
            primaryActionButton
        }
    }

    private func numberButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textEmphasis)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonStrokeBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var backspaceButton: some View {
        Button(action: deleteLastDigit) {
            Image(systemName: "delete.backward")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(AppColors.textEmphasis)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonStrokeBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var primaryActionButton: some View {
        Button(action: {
            commitInput()
            onCommit()
        }) {
            Text(resolvedButtonTitle)
                .font(AppFont.tabletH5Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonPrimaryBg)
                )
        }
        .buttonStyle(.plain)
    }

    /// search 样式中网格右下角的 "Clear" 按钮，与数字按钮同样式
    private var clearButton: some View {
        Button(action: clearInput) {
            Text("Clear")
                .font(AppFont.tabletH5Medium)
                .foregroundColor(AppColors.textEmphasis)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonStrokeBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// search 样式中网格下方的全宽 "Search" 按钮
    private var searchButton: some View {
        Button(action: {
            commitInput()
            onCommit()
        }) {
            Text(resolvedButtonTitle)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.buttonPrimaryBg)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private var displayValue: String {
        isEditing ? inputBuffer : "\(quantity)"
    }

    private func appendDigit(_ digit: Int) {
        let maxLimit = maxValue ?? 999
        let minLimit = minValue ?? 0
        // 当前显示值（用本地状态判断，不依赖 binding）
        let currentValue = isEditing ? (Int(inputBuffer) ?? 0) : quantity

        if !isEditing || currentValue >= maxLimit || currentValue <= minLimit {
            // 未编辑 / 已达最大值 / 已达最小值：从头开始输入（替换）
            let newValue = digit
            guard newValue <= maxLimit else { return }
            isEditing = true
            inputBuffer = "\(digit)"
            quantity = newValue
        } else {
            // 正在编辑且在范围内：追加数字
            let newBuffer = inputBuffer + "\(digit)"
            guard let newValue = Int(newBuffer), newValue <= maxLimit else {
                // 超过最大值，忽略本次输入，保持当前显示不变
                return
            }
            inputBuffer = newBuffer
            quantity = newValue
        }
    }

    private func deleteLastDigit() {
        if isEditing && !inputBuffer.isEmpty {
            inputBuffer = String(inputBuffer.dropLast())
            quantity = Int(inputBuffer) ?? 0
            if inputBuffer.isEmpty {
                isEditing = false
            }
        } else {
            quantity = 0
            isEditing = false
        }
    }

    private func clearInput() {
        inputBuffer = ""
        quantity = 0
        isEditing = false
    }

    private func incrementQuantity() {
        commitInput()
        let maxLimit = maxValue ?? 999
        if quantity < maxLimit {
            quantity += 1
        }
    }

    private func decrementQuantity() {
        commitInput()
        let minLimit = minValue ?? 0
        if quantity > minLimit {
            quantity -= 1
        }
    }

    private func commitInput() {
        if isEditing {
            let maxLimit = maxValue ?? 999
            let val = Int(inputBuffer) ?? quantity
            quantity = min(val, maxLimit)
            isEditing = false
        }
    }
}

// MARK: - Preview

#Preview("Order Style") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(2),
            onDetails: { print("Details") },
            onSoldOut: { print("Sold Out") },
            onCommit: { print("Order") }
        )
    }
}

#Preview("Share Style") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(2),
            style: .share,
            onCommit: { print("Share") }
        )
    }
}

#Preview("Share Style - With Limits") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(5),
            style: .share,
            onCommit: { print("Confirm") },
            primaryButtonTitle: "Confirm",
            minValue: 1,
            maxValue: 5
        )
    }
}

#Preview("Update Style") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(0),
            style: .update,
            onCommit: { print("Update") }
        )
    }
}

#Preview("Search Style") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(0),
            style: .search,
            onCommit: { print("Search") }
        )
    }
}
#Preview("Quantity Style") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        NumpadView(
            quantity: .constant(1),
            style: .quantity,
            onCommit: { print("Share") },
            titleText: "Qty For $100.00"
        )
    }
}
