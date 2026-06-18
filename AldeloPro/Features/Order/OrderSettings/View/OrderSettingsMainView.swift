//
//  OrderSettingsMainView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 输入焦点枚举

/// 标识当前聚焦的输入框，用于控制数字键盘事件路由
enum OrderSettingsField: Hashable {
    case price
    case phone
    case firstName
    case lastName
}

// MARK: - 订单类型

/// 订单类型渠道枚举
enum OrderType: String, CaseIterable, Identifiable {
    case dineIn = "Dine In"
    case takeOut = "Take Out"
    case bar = "Bar"
    case delivery = "Delivery"
    case retail = "Retail"
    case driveThru = "Drive Thru"

    var id: String { rawValue }

    /// SF Symbol icon name for this order type
    var assetImageName: String {
        switch self {
        case .dineIn: return "dineIn"
        case .takeOut: return "takeOut"
        case .bar: return "bar"
        case .delivery: return "delivery"
        case .retail: return "retail"
        case .driveThru: return "driveThru"
        }
    }

    /// 该订单类型对应的主题色（用于圆点 / 图标背景）
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
}

// MARK: - 弹窗类型枚举

/// 订单设置弹窗的三种模式
enum OrderSettingsType: Equatable {
    case editPrice(originalPrice: String, itemQuantity: Int, note: String)
    case switchOrderType(currentType: OrderType)
    case updateOrderInfo(orderNumber: String, guestsCount: Int)

    static func == (lhs: OrderSettingsType, rhs: OrderSettingsType) -> Bool {
        switch (lhs, rhs) {
        case (.editPrice, .editPrice): return true
        case (.switchOrderType, .switchOrderType): return true
        case (.updateOrderInfo, .updateOrderInfo): return true
        default: return false
        }
    }
}

// MARK: - 主容器视图

/// 订单设置统一模态容器
/// 无论 iPad/iPhone 均渲染为：全屏半透明遮罩 + 居中浮动白色卡片
/// 父级必须通过 .fullScreenCover(backgroundContent: .clear) 或 .overlay 呈现
struct OrderSettingsMainView: View {
    let type: OrderSettingsType
    var onConfirm: () -> Void = {}
    var onDismiss: () -> Void = {}
    /// switchOrderType 模式下点击 Confirm 时回传选中的订单类型
    var onConfirmOrderType: ((OrderType) -> Void)? = nil
    /// editPrice 模式下点击 Confirm 时回传 (新单价, 套用数量, 备注)
    var onConfirmEditPrice: ((Decimal, Int, String) -> Void)? = nil

    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    // MARK: - 内部状态

    /// 价格以分为单位存储（如 730 = $7.30）
    @State private var priceCents: Int = 0
    @State private var quantity: Int = 1
    @State private var note: String = ""
    @State private var selectedOrderType: OrderType = .dineIn
    @State private var guestsCount: Int = 1
    @State private var phoneNumber: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @FocusState private var focusedField: OrderSettingsField?

    init(type: OrderSettingsType,
         onConfirm: @escaping () -> Void = {},
         onDismiss: @escaping () -> Void = {},
         onConfirmOrderType: ((OrderType) -> Void)? = nil,
         onConfirmEditPrice: ((Decimal, Int, String) -> Void)? = nil) {
        self.type = type
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        self.onConfirmOrderType = onConfirmOrderType
        self.onConfirmEditPrice = onConfirmEditPrice
        switch type {
        case .editPrice(_, let qty, let note):
            _quantity = State(initialValue: qty)
            _note = State(initialValue: note)
        case .switchOrderType(let current):
            _selectedOrderType = State(initialValue: current)
        case .updateOrderInfo(_, let guests):
            _guestsCount = State(initialValue: guests)
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 全屏半透明黑色遮罩
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { onDismiss() }

                // 居中悬浮白色模态卡片
                VStack(spacing: 0) {
                    headerBar
                    Divider().overlay(AppColors.line)
                    mainContent
                    Divider().overlay(AppColors.line)
                    bottomBar
                }
                .frame(
                    width: cardWidth(in: geo.size),
                    height: cardHeight(in: geo.size)
                )
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - 卡片尺寸计算

    /// 卡片宽度：iPad 固定 860/680，iPhone 取屏幕宽度 - 32
    private func cardWidth(in size: CGSize) -> CGFloat {
        let target: CGFloat = showsNumpad ? 860 : 680
        return min(target, size.width - 32)
    }

    /// 卡片高度：iPad 固定 640/520，iPhone 取屏幕高度 - 80
    private func cardHeight(in size: CGSize) -> CGFloat {
        let target: CGFloat = showsNumpad ? 640 : 520
        return min(target, size.height - 80)
    }

    // MARK: - 顶部标题栏

    private var headerBar: some View {
        HStack {
            Text(headerTitle)
                .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: isPad ? 22 : 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, isPad ? Spacing.xl : Spacing.lg)
        .padding(.vertical, isPad ? Spacing.lg : Spacing.md)
    }

    private var headerTitle: String {
        switch type {
        case .editPrice:
            return "Edit Price"
        case .switchOrderType:
            return "#013 - Switch Order Type"
        case .updateOrderInfo(let order, _):
            return "\(order) - Update Order Info"
        }
    }

    // MARK: - 主体内容区

    @ViewBuilder
    private var mainContent: some View {
        if showsNumpad {
            // 带数字键盘的左右分栏（editPrice / updateOrderInfo）
            HStack(spacing: 0) {
                // 左侧表单（50%）
                ScrollView(.vertical, showsIndicators: false) {
                    formContent
                        .padding(isPad ? Spacing.xl : Spacing.lg)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 竖向分割线
                Rectangle()
                    .fill(AppColors.line)
                    .frame(width: 1)

                // 右侧 3x4 数字键盘（50%）
                OrderSettingsNumpadView(
                    isPad: isPad,
                    onDigit: handleDigit,
                    onBackspace: handleBackspace,
                    onClear: handleClear
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(isPad ? Spacing.lg : Spacing.md)
            }
            .frame(maxHeight: .infinity)
        } else {
            // 无键盘的纯内容（switchOrderType）
            ScrollView(.vertical, showsIndicators: false) {
                formContent
                    .padding(isPad ? Spacing.xl : Spacing.lg)
            }
            .frame(maxHeight: .infinity)
        }
    }

    // MARK: - 表单内容路由

    @ViewBuilder
    private var formContent: some View {
        switch type {
        case .editPrice(let original, _, _):
            EditPriceSettingView(
                priceDisplayText: priceDisplayText,
                quantity: $quantity,
                note: $note,
                originalPrice: original,
                isPad: isPad,
                focusedField: $focusedField
            )
        case .switchOrderType:
            SwitchOrderTypeView(
                selectedType: $selectedOrderType,
                isPad: isPad
            )
        case .updateOrderInfo:
            UpdateOrderInfoView(
                guestsCount: $guestsCount,
                phoneNumber: $phoneNumber,
                firstName: $firstName,
                lastName: $lastName,
                isPad: isPad,
                focusedField: $focusedField
            )
        }
    }

    private var showsNumpad: Bool {
        switch type {
        case .editPrice, .updateOrderInfo: return true
        case .switchOrderType: return false
        }
    }

    /// 将分值格式化为美元显示文本 (如 730 -> "7.30")
    private var priceDisplayText: String {
        let dollars = priceCents / 100
        let cents = priceCents % 100
        return String(format: "%d.%02d", dollars, cents)
    }

    // MARK: - 底部按钮栏

    private var bottomBar: some View {
        HStack(spacing: isPad ? Spacing.md : Spacing.sm) {
            Button(action: onDismiss) {
                Text("Cancel")
                    .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: isPad ? 56 : 44)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }

            Button(action: handleConfirm) {
                Text("Confirm")
                    .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: isPad ? 56 : 44)
                    .background(AppColors.theme)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
            }
        }
        .padding(.horizontal, isPad ? Spacing.xl : Spacing.lg)
        .padding(.vertical, isPad ? Spacing.lg : Spacing.md)
    }

    // MARK: - 确认事件

    /// Confirm 按钮：按模式回传对应数据，再走默认 onConfirm
    private func handleConfirm() {
        switch type {
        case .switchOrderType:
            onConfirmOrderType?(selectedOrderType)
        case .editPrice:
            let newPrice = Decimal(priceCents) / 100
            onConfirmEditPrice?(newPrice, quantity, note)
        default:
            break
        }
        onConfirm()
    }

    // MARK: - 数字键盘事件

    private func handleDigit(_ digit: String) {
        switch focusedField {
        case .price:
            // 金融收银级分位右移：每次输入将已有值左移一位再加新数字
            guard let d = Int(digit) else { return }
            priceCents = priceCents * 10 + d
        case .phone:
            let digits = phoneNumber.filter { $0.isNumber }
            guard digits.count < 10 else { return }
            phoneNumber = formatPhoneAppend(current: phoneNumber, digit: digit)
        default:
            guard let d = Int(digit) else { return }
            priceCents = priceCents * 10 + d
        }
    }

    private func handleBackspace() {
        switch focusedField {
        case .price:
            // 分位左移：去掉最右一位数字
            priceCents = priceCents / 10
        case .phone:
            let digits = phoneNumber.filter { $0.isNumber }
            if !digits.isEmpty {
                phoneNumber = formatPhoneFromDigits(String(digits.dropLast()))
            }
        default:
            priceCents = priceCents / 10
        }
    }

    private func handleClear() {
        switch focusedField {
        case .price: priceCents = 0
        case .phone: phoneNumber = ""
        default: priceCents = 0
        }
    }

    // MARK: - 电话格式化

    private func formatPhoneAppend(current: String, digit: String) -> String {
        let digits = current.filter { $0.isNumber } + digit
        return formatPhoneFromDigits(digits)
    }

    private func formatPhoneFromDigits(_ digits: String) -> String {
        let limited = String(digits.prefix(10))
        var result = ""
        for (index, char) in limited.enumerated() {
            switch index {
            case 0: result += "(\(char)"
            case 2: result += "\(char)) "
            case 5: result += "\(char)-"
            default: result += String(char)
            }
        }
        return result
    }
}

// MARK: - Preview

#Preview("iPad - Edit Price (图79)") {
    OrderSettingsMainView(
        type: .editPrice(originalPrice: "$5.00", itemQuantity: 5, note: "")
    )
}

#Preview("iPad - Switch Order Type (图80)") {
    OrderSettingsMainView(
        type: .switchOrderType(currentType: .dineIn)
    )
}

#Preview("iPad - Update Order Info (图81)") {
    OrderSettingsMainView(
        type: .updateOrderInfo(orderNumber: "#013", guestsCount: 4)
    )
}

#Preview("Dark - Update Order Info") {
    OrderSettingsMainView(
        type: .updateOrderInfo(orderNumber: "#013", guestsCount: 4)
    )
    .preferredColorScheme(.dark)
}
