import Foundation

// MARK: - 功能菜单页面枚举
/// 定义功能菜单模块内的所有页面路由

enum FunctionMenuAppPage: Hashable {
    /// 主功能菜单（九宫格）
    case functionMenu
    /// 点餐页面
    case order
    /// 分账页面
    case splitAmount
}
