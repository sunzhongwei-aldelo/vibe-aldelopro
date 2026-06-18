import Foundation

// MARK: - 功能菜单项类型
/// 每种类型对应一个功能入口，用于颜色映射和路由跳转

enum FunctionMenuItemType: String, CaseIterable, Hashable {
    case pos            // 收银
    case floorPlans     // 楼层平面图
    case products       // 产品管理
    case employees      // 员工管理
    case customer       // 客户管理
    case marketing      // 营销推广
    case inventory      // 库存管理
    case reports        // 报表统计
    case devices        // 设备管理
    case integrations   // 集成对接
    case marketplace    // 应用市场
    case dashboard      // 仪表盘
    case ePayConnect    // 电子支付
    case support        // 客服支持
    case settings       // 系统设置
    case timeCard       // 考勤打卡
}

// MARK: - 功能菜单项数据模型
/// 包含图标、标题和类型，用于驱动网格视图

struct FunctionMenuItem: Identifiable, Hashable {
    let id: String
    let type: FunctionMenuItemType
    let icon: String    // SF Symbols 图标名
    let title: String   // 显示标题

    /// 默认菜单项列表（按类型全量生成）
    static let defaultItems: [FunctionMenuItem] = FunctionMenuItemType.allCases.map { type in
        switch type {
        case .pos:
            return FunctionMenuItem(id: "pos", type: .pos, icon: "creditcard.fill", title: "POS")
        case .floorPlans:
            return FunctionMenuItem(id: "floorPlans", type: .floorPlans, icon: "map.fill", title: "Floor Plans")
        case .products:
            return FunctionMenuItem(id: "products", type: .products, icon: "bag.fill", title: "Products")
        case .employees:
            return FunctionMenuItem(id: "employees", type: .employees, icon: "person.2.fill", title: "Employees")
        case .customer:
            return FunctionMenuItem(id: "customer", type: .customer, icon: "person.crop.circle.fill", title: "Customer")
        case .marketing:
            return FunctionMenuItem(id: "marketing", type: .marketing, icon: "megaphone.fill", title: "Marketing")
        case .inventory:
            return FunctionMenuItem(id: "inventory", type: .inventory, icon: "shippingbox.fill", title: "Inventory")
        case .reports:
            return FunctionMenuItem(id: "reports", type: .reports, icon: "chart.bar.fill", title: "Reports")
        case .devices:
            return FunctionMenuItem(id: "devices", type: .devices, icon: "desktopcomputer", title: "Devices")
        case .integrations:
            return FunctionMenuItem(id: "integrations", type: .integrations, icon: "puzzlepiece.fill", title: "Integrations")
        case .marketplace:
            return FunctionMenuItem(id: "marketplace", type: .marketplace, icon: "storefront.fill", title: "Marketplace")
        case .dashboard:
            return FunctionMenuItem(id: "dashboard", type: .dashboard, icon: "square.grid.2x2.fill", title: "Dashboard")
        case .ePayConnect:
            return FunctionMenuItem(id: "ePayConnect", type: .ePayConnect, icon: "banknote.fill", title: "ePay Connect")
        case .support:
            return FunctionMenuItem(id: "support", type: .support, icon: "headphones", title: "Support")
        case .settings:
            return FunctionMenuItem(id: "settings", type: .settings, icon: "gearshape.fill", title: "Settings")
        case .timeCard:
            return FunctionMenuItem(id: "timeCard", type: .timeCard, icon: "clock.fill", title: "Time Card")
        }
    }
}
