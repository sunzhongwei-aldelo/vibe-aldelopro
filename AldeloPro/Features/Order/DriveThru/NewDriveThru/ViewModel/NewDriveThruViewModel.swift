//
//  NewDriveThruViewModel.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import Foundation

// MARK: - 领域值类型 (Domain Value Types)

/// 车型分流矩阵中可点选的单个车型剪影。
/// `iconName` 映射到一个 SF Symbol，使整排卡片无需依赖打包图片资源即可渲染。
/// 标记 `nonisolated`：这是纯 Sendable 数据类型，不应受工程默认 MainActor 隔离约束，
/// 否则 `presets` 静态属性无法在默认参数（nonisolated）等上下文中被引用。
nonisolated struct VehicleType: Identifiable, Equatable {
    let id: String
    let iconName: String

    // 以下 SF Symbol 名称已于 2026-06-11 通过 UIImage(systemName:) 在本工程的部署目标上逐个验证可用。
    // 该部署目标不存在任何 `van.*` 符号，因此 van 槽位改用 `bus.fill`（最接近的可用剪影）。
    static let presets: [VehicleType] = [
        VehicleType(id: "sedan", iconName: "car.fill"),
        VehicleType(id: "truck", iconName: "truck.box.fill"),
        VehicleType(id: "sports", iconName: "car.side.fill"),
        VehicleType(id: "convertible", iconName: "car.side.rear.open.fill"),
        VehicleType(id: "wagon", iconName: "car.2.fill"),
        VehicleType(id: "suv", iconName: "suv.side.fill"),
        VehicleType(id: "pickup", iconName: "truck.pickup.side.fill"),
        VehicleType(id: "van", iconName: "bus.fill")
    ]
}

/// 收银员可记录的单个车身颜色。
/// `hex` 仅供 View 层消费（Color 属于 UI 关注点，故不在此处存储）。
/// 标记 `nonisolated`：纯 Sendable 数据类型，理由同 `VehicleType`。
nonisolated struct VehicleColorOption: Identifiable, Equatable {
    let id: String
    let hex: String
    /// 浅色填充需用一圈极细描边来对抗浅色页面背景，防止"视觉融化"。
    let needsLightStrokeDefense: Bool

    static let presets: [VehicleColorOption] = [
        VehicleColorOption(id: "white", hex: "#FFFFFF", needsLightStrokeDefense: true),
        VehicleColorOption(id: "black", hex: "#1C1C1E", needsLightStrokeDefense: false),
        VehicleColorOption(id: "silver", hex: "#D9D9DC", needsLightStrokeDefense: true),
        VehicleColorOption(id: "green", hex: "#3E9314", needsLightStrokeDefense: false),
        VehicleColorOption(id: "blue", hex: "#007CFF", needsLightStrokeDefense: false),
        VehicleColorOption(id: "yellow", hex: "#FFC919", needsLightStrokeDefense: false),
        VehicleColorOption(id: "orange", hex: "#FF6A01", needsLightStrokeDefense: false),
        VehicleColorOption(id: "purple", hex: "#A020F0", needsLightStrokeDefense: false),
        VehicleColorOption(id: "red", hex: "#FF4343", needsLightStrokeDefense: false)
    ]
}

// MARK: - 业务状态机 (Workflow State)

/// 汽车外卖创建控制台的顺序生命周期。
enum DriveThruWorkflowState: Equatable {
    case initialVehicleTriage   // 状态 1：初始车流分流（仅展示人数 + 车型 + 车色）
    case customerIntakePhone    // 状态 2：电话框聚焦，软键盘弹起
    case customerIntakeName     // 状态 3：姓名框聚焦，软键盘弹起
}

/// 标识当前由哪个顾客字段持有键盘焦点。
/// 放在 ViewModel 中，使 View 的 @FocusState 能绑定到一个领域概念。
enum CustomerField: Hashable {
    case phone
    case name
}

// MARK: - ViewModel

@MainActor
@Observable
final class NewDriveThruViewModel {

    // MARK: 配置项（构造注入 —— 禁止 Singleton）
    let orderNumber: String
    let stationNumber: String
    let serverName: String
    let vehicleTypes: [VehicleType]
    let vehicleColors: [VehicleColorOption]

    private let minGuests: Int
    private let maxGuests: Int

    // MARK: 状态（对外只读）
    private(set) var workflowState: DriveThruWorkflowState = .initialVehicleTriage
    private(set) var guestCount: Int
    private(set) var selectedVehicleID: String?
    private(set) var selectedColorID: String?
    private(set) var rawPhoneDigits: String = ""
    private(set) var customerName: String = ""

    // MARK: 初始化
    init(
        orderNumber: String = "#016",
        stationNumber: String = "1200002",
        serverName: String = "Zhang San",
        vehicleTypes: [VehicleType] = VehicleType.presets,
        vehicleColors: [VehicleColorOption] = VehicleColorOption.presets,
        initialGuestCount: Int = 1,
        minGuests: Int = 1,
        maxGuests: Int = 99
    ) {
        self.orderNumber = orderNumber
        self.stationNumber = stationNumber
        self.serverName = serverName
        self.vehicleTypes = vehicleTypes
        self.vehicleColors = vehicleColors
        self.guestCount = max(minGuests, min(maxGuests, initialGuestCount))
        self.minGuests = minGuests
        self.maxGuests = maxGuests
        // 与设计图一致的合理默认值：默认预选第一个车型 + 第一个颜色（白色）。
        self.selectedVehicleID = vehicleTypes.first?.id
        self.selectedColorID = vehicleColors.first?.id
    }

    // MARK: 派生值 (Derived Values)

    /// 将电话数字实时格式化为北美格式 `(NXX) NXX-XXXX`，随输入逐位拼接。
    var formattedPhone: String {
        Self.formatNANP(rawPhoneDigits)
    }

    var canStepDown: Bool { guestCount > minGuests }
    var canStepUp: Bool { guestCount < maxGuests }

    var isPhoneActive: Bool { workflowState == .customerIntakePhone }
    var isNameActive: Bool { workflowState == .customerIntakeName }
    /// 一旦进入录入阶段，即展开 Customer 分组。
    var isCustomerSectionVisible: Bool { workflowState != .initialVehicleTriage }

    /// 将业务状态映射到应持有键盘焦点的字段（triage 阶段为 nil）。
    var focusedField: CustomerField? {
        switch workflowState {
        case .initialVehicleTriage: return nil
        case .customerIntakePhone:  return .phone
        case .customerIntakeName:   return .name
        }
    }

    // MARK: 动作 —— 人数 (Guests)

    func incrementGuests() {
        guard canStepUp else { return }
        guestCount += 1
    }

    func decrementGuests() {
        guard canStepDown else { return }
        guestCount -= 1
    }

    // MARK: 动作 —— 车型 / 车色 (Vehicle)

    func selectVehicle(_ id: String) {
        selectedVehicleID = id
    }

    func selectColor(_ id: String) {
        selectedColorID = id
    }

    func isVehicleSelected(_ id: String) -> Bool { selectedVehicleID == id }
    func isColorSelected(_ id: String) -> Bool { selectedColorID == id }

    // MARK: 动作 —— 状态机流转 (Workflow transitions)

    /// 进入 / 重新聚焦电话框（状态 2）。
    func beginPhoneIntake() {
        workflowState = .customerIntakePhone
    }

    /// 将焦点交棒给姓名框（状态 3）。
    func beginNameIntake() {
        workflowState = .customerIntakeName
    }

    /// 由头栏 `Continue` 按钮驱动的正向流转：
    /// triage → 电话录入 → 姓名录入。位于姓名录入时，Continue 将交棒给
    /// 下一阶段的开单流程（不在本视图职责范围内）。
    func advanceFromContinue() {
        switch workflowState {
        case .initialVehicleTriage: workflowState = .customerIntakePhone
        case .customerIntakePhone:  workflowState = .customerIntakeName
        case .customerIntakeName:   break
        }
    }

    /// 由头栏 `Back` 按钮驱动的反向流转：
    /// 姓名 → 电话 → triage。位于 triage 时，Back 将关闭本视图
    /// （由上层呈现协调者处理，不在此职责范围内）。
    func goBack() {
        switch workflowState {
        case .customerIntakeName:   workflowState = .customerIntakePhone
        case .customerIntakePhone:  workflowState = .initialVehicleTriage
        case .initialVehicleTriage: break
        }
    }

    /// 根据 View 端焦点变化（点击 / Tab 键）反向同步业务状态。
    func syncFocus(to field: CustomerField?) {
        switch field {
        case .phone: workflowState = .customerIntakePhone
        case .name:  workflowState = .customerIntakeName
        case .none:  break // 失去焦点不会收起整个分组
        }
    }

    // MARK: 动作 —— 输入 (Input)

    /// 接收来自键盘的电话原始文本，仅保留最多 10 位数字。
    func updatePhone(rawInput: String) {
        let digits = rawInput.filter(\.isNumber)
        rawPhoneDigits = String(digits.prefix(10))
    }

    func updateName(_ value: String) {
        customerName = value
    }

    // MARK: 格式化辅助 (Formatting Helpers)

    /// 将最多 10 位数字渐进式格式化为 `(NXX) NXX-XXXX`。
    static func formatNANP(_ digits: String) -> String {
        let d = Array(digits.prefix(10))
        switch d.count {
        case 0:
            return ""
        case 1...3:
            return "(\(String(d))"
        case 4...6:
            let area = String(d[0..<3])
            let prefix = String(d[3..<d.count])
            return "(\(area)) \(prefix)"
        default:
            let area = String(d[0..<3])
            let prefix = String(d[3..<6])
            let line = String(d[6..<d.count])
            return "(\(area)) \(prefix)-\(line)"
        }
    }
}
