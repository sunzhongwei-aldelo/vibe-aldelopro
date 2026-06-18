import Foundation

// MARK: - 功能菜单 ViewModel
/// 管理功能菜单页面的状态和业务逻辑
/// 遵循 MVVM 架构，不导入 SwiftUI，所有依赖通过初始化注入

@Observable
final class FunctionMenuViewModel {
    // MARK: - 状态属性

    /// 菜单项列表
    private(set) var menuItems: [FunctionMenuItem] = FunctionMenuItem.defaultItems
    /// 门店名称
    private(set) var storeName: String
    /// 门店 ID
    private(set) var storeId: String
    /// 门店营业状态（true=营业中, false=已打烊）
    private(set) var isStoreOpen: Bool
    /// 未读通知数量
    private(set) var unreadNotificationCount: Int
    /// 当前选中的页面
    var selectedPage: FunctionMenuAppPage = .functionMenu

    // MARK: - 初始化

    init(
        storeName: String = "Super Delicious Flagship Store",
        storeId: String = "10000130001",
        isStoreOpen: Bool = true,
        notificationCount: Int = 0
    ) {
        self.storeName = storeName
        self.storeId = storeId
        self.isStoreOpen = isStoreOpen
        self.unreadNotificationCount = notificationCount
    }

    // MARK: - 用户操作

    /// 点击菜单项，根据类型进行页面路由
    func selectMenuItem(_ item: FunctionMenuItem) {
        switch item.type {
        case .pos:
            selectedPage = .order
        default:
            break
        }
    }

    /// 返回主菜单
    func navigateBack() {
        selectedPage = .functionMenu
    }
}
