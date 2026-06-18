//
//  OrderingPageViewModel.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/03.
//

import Foundation

// MARK: - 点单页面视图模型


// MARK: - Models

/// 点单页面的状态管理器
/// 负责菜品分类加载、购物车管理、数量增减、订单提交等业务逻辑
struct OrderItem: Identifiable, Equatable, Sendable {
    let id: String
    let menuItemId: String
    let name: String
    /*
     规格：杯、份，等等
     */
    let spec: String
    let quantity: Int
    let unitPrice: Decimal
    let totalPrice: Decimal
    var modifier: String?
    let itemNote: String?
    let portionDetails: [String]?
    let guest: Int? // Guest number (1-based)
    var holdDateTime: Double?
    let course: OrderCourse? // Course assignment (Appetizer / Entrée / ...)

    init(
        id: String,
        menuItemId: String,
        name: String,
        spec: String,
        quantity: Int,
        unitPrice: Decimal,
        totalPrice: Decimal,
        modifier: String?,
        itemNote: String?,
        portionDetails: [String]?,
        guest: Int?,
        holdDateTime:Double? = nil,
        course: OrderCourse? = nil
    ) {
        self.id = id
        self.menuItemId = menuItemId
        self.name = name
        self.spec = spec
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
        self.itemNote = itemNote
        self.portionDetails = portionDetails
        self.guest = guest
        self.holdDateTime = holdDateTime
        self.course = course
    }
}

// MARK: - Order Course

/// 菜品所属的出餐顺序（课程）
/// 用于将客单中的菜品按出餐阶段分组展示
enum OrderCourse: String, CaseIterable, Identifiable, Sendable {
    case appetizer = "Appetizer"
    case entree = "Entrée"
    case dessert = "Dessert"
    case drinks = "Drinks"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct GuestCheckInfo: Equatable, Sendable {
    let orderNumber: String
    let tableNumber: String
    var orderType: OrderType
    let orderCode: String
    let serverName: String
    let guestCount: Int
    let openedTime: String
    var holdDateTime: Double?
}

struct PizzaOption: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let price: Decimal?
    var isSelected: Bool
    let imageName: String?
    let actionTitle: String?

    init(id: String, name: String, price: Decimal? = nil, isSelected: Bool, imageName: String? = nil, actionTitle: String? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.isSelected = isSelected
        self.imageName = imageName
        self.actionTitle = actionTitle
    }
}

struct PizzaSection: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let minRequired: Int?
    let options: [PizzaOption]
}

// MARK: - ViewModel

@Observable @MainActor
final class OrderingPageViewModel {
    // Guest Check
    private(set) var guestCheck = GuestCheckInfo(
        orderNumber: "#013", tableNumber: "01",
        orderType: .dineIn, orderCode: "1200002",
        serverName: "Zhang San", guestCount: 4, openedTime: "12:10 PM"
    )

    private(set) var orderNote: String? = "To be by the window, light the aromatherapy"

    private(set) var orderItems: [OrderItem] = [
        OrderItem(id: "1", menuItemId: "d1", name: "Orange Juice", spec: "Small Cup", quantity: 5, unitPrice: 5.00, totalPrice: 25.00, modifier: nil, itemNote: nil, portionDetails: nil, guest: 1),
        OrderItem(id: "2", menuItemId: "d4", name: "Wine", spec: "Bottle", quantity: 1, unitPrice: 5.00, totalPrice: 5.00, modifier: "Lafite,Vintage 1992", itemNote: "I need to sober up early,I need to sober up early,I need to sober up early", portionDetails: nil, guest: 1),
        OrderItem(id: "3", menuItemId: "d3", name: "Mango Juice", spec: "Small Cup", quantity: 1, unitPrice: 5.00, totalPrice: 5.00, modifier: nil, itemNote: nil, portionDetails: nil, guest: 1),
        OrderItem(id: "4", menuItemId: "pizza1", name: "Pizza", spec: "6 inches", quantity: 1, unitPrice: 25.00, totalPrice: 25.00, modifier: nil, itemNote: nil, portionDetails: [
            "1st 1/4: Normal, Lemon, Fruit Pieces",
            "2nd 1/4: Normal, Lemon",
            "3rd 1/4: Half Sugar, Lemon",
            "4th 1/4: Normal, Lemon, Beef"
        ], guest: 2),
    ]

    var selectedItemId: String?
    var selectedGuestId: Int?

    /// Items grouped by guest number, ordered by guest (nil guests last)
    var guestGroupedItems: [(guest: Int?, items: [OrderItem])] {
        guestGroups(in: orderItems)
    }

    /// 把给定的菜品集合按客人编号分组，按客人升序排列（nil 客人排在最后）。
    /// 供「课程分组内再按客人分组」复用——传入某个课程的 items 即可。
    func guestGroups(in items: [OrderItem]) -> [(guest: Int?, items: [OrderItem])] {
        let grouped = Dictionary(grouping: items, by: \.guest)
        let sortedKeys = grouped.keys.sorted { lhs, rhs in
            switch (lhs, rhs) {
            case (nil, nil): return false
            case (nil, _): return false
            case (_, nil): return true
            case let (l?, r?): return l < r
            }
        }
        return sortedKeys.map { guest in
            (guest: guest, items: grouped[guest] ?? [])
        }
    }

    /// Items filtered by selectedGuestId; shows all when nil
    var filteredOrderItems: [OrderItem] {
        guard let guestId = selectedGuestId else { return orderItems }
        return orderItems.filter { $0.guest == guestId }
    }

    // MARK: - Course Grouping

    /// 当前选中的出餐顺序（用于新加菜品的默认归类，以及高亮课程标题）
    var selectedCourseId: OrderCourse?

    /// 已添加到客单的出餐顺序分组：即使暂时没有菜品，其分组标题也会显示。
    /// 通过 CourseMenuPopover 选择课程时写入；一旦添加则保留，方便后续往里加菜。
    private(set) var activeCourses: [OrderCourse] = []

    /// Items grouped by course, ordered by the canonical course order.
    /// 已有菜品、或已通过 CourseMenuPopover 显式添加的空分组，都会显示并统一排在最上面。
    /// 注意：未归类（course == nil）的菜品**不**包含在此，改由 `uncategorizedItems` 单独提供。
    var courseGroupedItems: [(course: OrderCourse?, items: [OrderItem])] {
        let grouped = Dictionary(grouping: orderItems, by: \.course)
        return OrderCourse.allCases.compactMap { course -> (course: OrderCourse?, items: [OrderItem])? in
            let items = grouped[course] ?? []
            // 有菜品，或已被显式添加的空分组，都要显示
            guard !items.isEmpty || activeCourses.contains(course) else { return nil }
            return (course: course, items: items)
        }
    }

    /// 未归类（course == nil）的菜品，保持原始顺序。
    /// 在客单中单独成区（排在所有课程分组之后），区内再按客人分组、无课程标题。
    var uncategorizedItems: [OrderItem] {
        orderItems.filter { $0.course == nil }
    }
    private(set) var discount: Decimal = -5.00
    private(set) var subtotal: Decimal = 124.00
    private(set) var tax: Decimal = 2.50
    private(set) var total: Decimal = 126.50
    private(set) var cashBalance: Decimal = 10.00
    private(set) var balanceDue: Decimal = 10.50
    
    // Pizza Builder
    var selectedDivision: String = "Halves" {
        didSet { selectedPortion = 0 }
    }
    let divisions = ["Whole", "Halves", "Thirds", "Quarters"]
    var selectedPortion: Int = 0

    var portionCount: Int {
        switch selectedDivision {
        case "Whole": return 1
        case "Halves": return 2
        case "Thirds": return 3
        case "Quarters": return 4
        default: return 1
        }
    }

    private(set) var pizzaSections: [PizzaSection] = [
        PizzaSection(id: "size", title: "Size", minRequired: nil, options: [
            PizzaOption(id: "s1", name: "6 Inches", price: 8.00, isSelected: true),
            PizzaOption(id: "s2", name: "4 Inches", price: 6.00, isSelected: false),
            PizzaOption(id: "s3", name: "3 Inches", price: 5.00, isSelected: false)
        ]),
        PizzaSection(id: "crust", title: "Crust", minRequired: nil, options: [
            PizzaOption(id: "c1", name: "Hand-Tossed", price: nil, isSelected: true),
            PizzaOption(id: "c2", name: "Thin Crust", price: nil, isSelected: false),
            PizzaOption(id: "c3", name: "Thick Crust", price: nil, isSelected: false),
            PizzaOption(id: "c4", name: "Stuffed Crust", price: nil, isSelected: false)
        ]),
        PizzaSection(id: "type", title: "Type", minRequired: nil, options: [
            PizzaOption(id: "t1", name: "Margherita", price: nil, isSelected: true),
            PizzaOption(id: "t2", name: "Pepperoni", price: nil, isSelected: false),
            PizzaOption(id: "t3", name: "Hawaiian", price: nil, isSelected: false),
            PizzaOption(id: "t4", name: "Cheese", price: nil, isSelected: false)
        ]),
        PizzaSection(id: "sauce", title: "Sauce", minRequired: 2, options: [
            PizzaOption(id: "sa1", name: "Tomato Sauce", price: nil, isSelected: true),
            PizzaOption(id: "sa2", name: "Soybean Paste", price: nil, isSelected: true),
            PizzaOption(id: "sa3", name: "Hot Sauce", price: nil, isSelected: false)
        ]),
        PizzaSection(id: "toppings", title: "Toppings", minRequired: 3, options: [
            PizzaOption(id: "tp1", name: "Lemon", price: nil, isSelected: true, imageName: "NoPaymentsToTipAdjust", actionTitle: "Double"),
            PizzaOption(id: "tp2", name: "Fruit Pieces", price: nil, isSelected: true, imageName: "NoPaymentsToTipAdjust", actionTitle: nil),
            PizzaOption(id: "tp3", name: "Ice Cubes", price: nil, isSelected: false, imageName: "NoPaymentsToTipAdjust", actionTitle: nil),
            PizzaOption(id: "tp4", name: "Cream", price: nil, isSelected: false, imageName: "NoPaymentsToTipAdjust", actionTitle: nil),
            PizzaOption(id: "tp5", name: "Mustard", price: nil, isSelected: false, imageName: "NoPaymentsToTipAdjust", actionTitle: nil),
            PizzaOption(id: "tp6", name: "Chili", price: nil, isSelected: false, imageName: "NoPaymentsToTipAdjust", actionTitle: nil)
        ])
    ]

    // Guest Assignment
    let guestList: [String] = ["Guest 1", "Guest 2", "Guest 3", "Guest 4", "Guest 5"]
    /// Available guests derived from orderItems, excluding the selected item's current guest
//    var guestList: [String] {
//        let currentGuest: Int? = {
//            guard let id = selectedItemId,
//                  let item = orderItems.first(where: { $0.id == id }) else { return nil }
//            return item.guest
//        }()
//        let allGuests = Set(orderItems.map(\.guest)).sorted()
//        return allGuests
//            .filter { $0 != currentGuest }
//            .map { "Guest \($0)" }
//    }

    // MARK: - Computed

    func orderedQuantity(for menuItemId: String) -> Int {
        orderItems
            .filter { $0.menuItemId == menuItemId }
            .reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Actions

    func selectItem(_ id: String) { selectedItemId = id }

    func selectGuest(_ guest: Int?) {
        if selectedGuestId == guest {
            selectedGuestId = nil
        } else {
            selectedGuestId = guest
        }
    }

    /// 选择一个出餐顺序（来自 CourseMenuPopover 或左侧课程标题）：
    /// - 若该分组尚未出现在客单中，则新增该分组（即使暂无菜品也会显示其标题，统一排在最上面）；
    /// - 若已存在，则选中并高亮。
    /// 选中的课程同时作为后续加菜的默认归类；若当前有选中的菜品，则立即把它归入该课程。
    func selectCourse(_ course: OrderCourse?) {
        if let course {
            // 没有则添加该分组
            if !activeCourses.contains(course) {
                activeCourses.append(course)
            }
            // 选中高亮
            selectedCourseId = course
        } else {
            selectedCourseId = nil
        }
        assignCourse(course)
        // 加新分组后，清除其它“空分组”（activeCourses 中底下没有 item 的占位分组），
        // 避免空占位分组不断堆积；当前选中/新增的分组除外。
        pruneEmptyCourses(keeping: course)
    }

    /// 清除 activeCourses 中的空分组（orderItems 里没有该课程的菜品），保留 `kept` 指定的分组。
    /// 空分组 = 仅作为占位标题显示、底下没有任何 item 的课程分组。
    private func pruneEmptyCourses(keeping kept: OrderCourse?) {
        activeCourses.removeAll { existing in
            existing != kept && !orderItems.contains(where: { $0.course == existing })
        }
    }

    /// 切换某个课程分组标签的选中状态（用于左侧客单 GuestCheckPanelView 的课程标题点击）：
    /// 未选中则选中，已选中则取消选中。选中时把当前选中的菜品归入该课程；取消时仅清除高亮。
    func toggleCourseSelection(_ course: OrderCourse?) {
        if selectedCourseId == course {
            selectedCourseId = nil
        } else {
            selectedCourseId = course
            assignCourse(course)
        }
    }

    /// 把当前选中的菜品归入指定课程
    func assignCourse(_ course: OrderCourse?) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let item = orderItems[index]
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: item.spec,
            quantity: item.quantity, unitPrice: item.unitPrice, totalPrice: item.totalPrice,
            modifier: item.modifier, itemNote: item.itemNote, portionDetails: item.portionDetails,
            guest: item.guest, course: course
        )
    }

    func addMenuItem(_ menuItem: MenuItem) {
        // 仅当存在「同一菜品且同一出餐顺序」的行时才合并数量；
        // 出餐顺序不同则视为不同的行，单独新增，不自动合并。
        if let index = orderItems.firstIndex(where: { $0.menuItemId == menuItem.id && $0.course == selectedCourseId }) {
            let existing = orderItems[index]
            let newQty = existing.quantity + 1
            orderItems[index] = OrderItem(
                id: existing.id, menuItemId: existing.menuItemId,
                name: existing.name, spec: existing.spec,
                quantity: newQty, unitPrice: existing.unitPrice,
                totalPrice: existing.unitPrice * Decimal(newQty),
                modifier: existing.modifier,
                itemNote: existing.itemNote,
                portionDetails: existing.portionDetails,
                guest: existing.guest, course: existing.course
            )
            selectedItemId = existing.id
        } else {
            let newId = UUID().uuidString
            let newItem = OrderItem(
                id: newId, menuItemId: menuItem.id,
                name: menuItem.name, spec: "",
                quantity: 1, unitPrice: menuItem.price,
                totalPrice: menuItem.price,
                modifier: nil,
                itemNote: nil, portionDetails: nil,
                guest: selectedGuestId,
                holdDateTime: guestCheck.holdDateTime
            )
            orderItems.append(newItem)
            selectedItemId = newId
        }
    }

    func assignGuest(_ guest: String) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        // Extract guest number from "Guest N"
        let guestNumber = Int(guest.replacingOccurrences(of: "Guest ", with: "")) ?? 1
        let item = orderItems[index]
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: item.spec,
            quantity: item.quantity, unitPrice: item.unitPrice, totalPrice: item.totalPrice,
            modifier: item.modifier,
            itemNote: item.itemNote, portionDetails: item.portionDetails, guest: guestNumber
        )
    }

    /// 将备注与套用数量写回当前选中菜品（保持不可变重建模式）
    /// - Parameters:
    ///   - note: 备注文本，空字符串归一化为 nil
    ///   - quantity: 套用数量（来自备注弹窗的 Qty 步进器），nil 表示不修改数量
    func updateItemNote(_ note: String, quantity: Int? = nil) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let item = orderItems[index]
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let newQty = item.quantity//quantity.map { max(1, $0) } ?? item.quantity
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: item.spec,
            quantity: newQty, unitPrice: item.unitPrice,
            totalPrice: item.unitPrice * Decimal(newQty),
            modifier: item.modifier,
            itemNote:  trimmed.isEmpty ? nil : trimmed, portionDetails: item.portionDetails,
            guest: item.guest, holdDateTime: item.holdDateTime
        )
    }

    func updateItemHoldDateTime(dateTime: Double?) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        orderItems[index].holdDateTime = dateTime
    }

    /// 修改当前选中菜品的单价与备注（数量不变，总价按新单价×原数量重算，保持不可变重建模式）
    /// - Parameters:
    ///   - price: 新单价（元）
    ///   - note: 改价备注，空字符串归一化为 nil
    func updateItemPrice(_ price: Decimal, note: String) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let item = orderItems[index]
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: item.spec,
            quantity: item.quantity, unitPrice: price,
            totalPrice: price * Decimal(item.quantity),
            modifier: item.modifier,
            itemNote: trimmed.isEmpty ? nil : trimmed, portionDetails: item.portionDetails,
            guest: item.guest, holdDateTime: item.holdDateTime, course: item.course
        )
    }
    
    func updateOrderNote(note: String?) {
        orderNote = note
    }

    /// 更新当前客单的订单类型
    func updateOrderType(_ type: OrderType) {
        guestCheck.orderType = type
    }
    
    func updateOrderHoldDateTime(dateTime: Double?) {
        let oldHoldTime = guestCheck.holdDateTime
        guestCheck.holdDateTime = dateTime
        
        for i in 0 ..< orderItems.count {
            if let dateTime {// Set HoldDateTime
                if orderItems[i].holdDateTime == nil || orderItems[i].holdDateTime == oldHoldTime {
                    orderItems[i].holdDateTime = dateTime
                }
            }else {// Remove HoldDateTime
                if orderItems[i].holdDateTime == oldHoldTime {
                    orderItems[i].holdDateTime = nil
                }
            }
        }
    }
    
    func updateQuantity(delta: Int) {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let item = orderItems[index]
        let newQty = max(1, item.quantity + delta)
        let newTotal = item.unitPrice * Decimal(newQty)
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: item.spec,
            quantity: newQty, unitPrice: item.unitPrice, totalPrice: newTotal,
            modifier: item.modifier,
            itemNote: item.itemNote, portionDetails: item.portionDetails, guest: item.guest
        )
    }

    func togglePizzaOption(sectionId: String, optionId: String) {
        guard let si = pizzaSections.firstIndex(where: { $0.id == sectionId }) else { return }
        var options = pizzaSections[si].options
        guard let oi = options.firstIndex(where: { $0.id == optionId }) else { return }

        if pizzaSections[si].minRequired != nil {
            // Multi-select: toggle individual option
            options[oi].isSelected.toggle()
        } else {
            // Single-select: only one can be active
            for i in options.indices {
                options[i].isSelected = (i == oi)
            }
        }
        pizzaSections[si] = PizzaSection(id: pizzaSections[si].id, title: pizzaSections[si].title, minRequired: pizzaSections[si].minRequired, options: options)
    }

    func choicesLeft(for section: PizzaSection) -> Int? {
        guard let min = section.minRequired else { return nil }
        let left = min - section.options.filter(\.isSelected).count
        return left > 0 ? left : nil
    }

    // MARK: - Pizza Builder Support

    var selectedItemHasPortions: Bool {
        guard let id = selectedItemId,
              let item = orderItems.first(where: { $0.id == id }) else { return false }
        return item.portionDetails != nil
    }

    var selectedOrderItem: OrderItem? {
        guard let id = selectedItemId else { return nil }
        return orderItems.first(where: { $0.id == id })
    }

    func savePizzaConfig() {
        guard let id = selectedItemId,
              let index = orderItems.firstIndex(where: { $0.id == id }) else { return }
        let item = orderItems[index]
        let details = buildPortionDetails()
        let selectedSize = pizzaSections.first(where: { $0.id == "size" })?
            .options.first(where: \.isSelected)?.name ?? item.spec
        let selectedPrice = pizzaSections.first(where: { $0.id == "size" })?
            .options.first(where: \.isSelected)?.price ?? item.unitPrice
        orderItems[index] = OrderItem(
            id: item.id, menuItemId: item.menuItemId, name: item.name, spec: selectedSize,
            quantity: item.quantity, unitPrice: selectedPrice, totalPrice: selectedPrice * Decimal(item.quantity),
            modifier: item.modifier,
            itemNote: item.itemNote, portionDetails: details, guest: item.guest
        )
    }

    func deselectItem() {
        selectedItemId = nil
    }

    private func buildPortionDetails() -> [String] {
        var details: [String] = []
        for portionIndex in 0..<portionCount {
            let label: String
            switch portionCount {
            case 1: label = "Whole"
            case 2: label = portionIndex == 0 ? "1st Half" : "2nd Half"
            case 3: label = ["1st 1/3", "2nd 1/3", "3rd 1/3"][portionIndex]
            case 4: label = ["1st 1/4", "2nd 1/4", "3rd 1/4", "4th 1/4"][portionIndex]
            default: label = "Portion \(portionIndex + 1)"
            }
            let selectedOptions = pizzaSections
                .flatMap { $0.options.filter(\.isSelected) }
                .map(\.name)
                .joined(separator: ", ")
            details.append("\(label): \(selectedOptions)")
        }
        return details
    }
}
