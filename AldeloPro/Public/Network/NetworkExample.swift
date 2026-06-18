//
//  NetworkExample.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  ╔══════════════════════════════════════════════════════════════════════╗
//  ║   网络框架使用教程 —— 从简单到复杂，循序渐进（LEVEL 1 → 5）              ║
//  ╠══════════════════════════════════════════════════════════════════════╣
//  ║  LEVEL 1  最简单：一个无参 GET，3 步跑通                                 ║
//  ║  LEVEL 2  进阶：POST 带参数 + 解析成强类型模型                            ║
//  ║  LEVEL 3  实战：多源域名分流 + 动态超时 + 复合参数（一个 Endpoint 管多 API）║
//  ║  LEVEL 4  封装：用 Repository 收口业务调用 + 挂载 AOP 插件                ║
//  ║  LEVEL 5  高级：现代并发合流 + 加密 SAF + SwiftUI 离线 Preview            ║
//  ╚══════════════════════════════════════════════════════════════════════╝
//
//  本文件是"可编译的活文档"，正式接入业务后可整体删除。
//  阅读建议：从 LEVEL 1 顺着往下读，每一级只比上一级多一个新概念。
//

import Foundation
import SwiftUI

// ============================================================================
// MARK: - LEVEL 1 ▸ 最简单：一个无参 GET
// ============================================================================
//
// 目标：感受框架最小用法。声明一个端点 → 创建 provider → await 请求。
//
// 【3 个步骤】
//   ① 定义一个 enum 遵循 NetworkTarget，描述"请求长什么样"
//   ② 创建 NetworkProvider 实例
//   ③ try await provider.request(...) 拿到响应，toString()/toData() 读取
//
// 只需实现协议要求的 5 个属性，其余（headers/超时/校验/假数据）都走默认值。

/// LEVEL 1 端点：查询服务器健康状态（无参 GET）。
public nonisolated enum HealthEndpoint: NetworkTarget {
    case ping

    public var baseURL: URL { URL(string: "https://api.aldeloepay.com")! }
    public var path: String { "health/ping" }
    public var httpMethod: HTTPMethod { .get }
    public var task: NetworkTask { .requestPlain }          // 无 Body 的纯请求
}

/// LEVEL 1 调用示例：最小可运行代码。
public func level1_simplestGet() async {
    // ② 创建 provider（不挂任何插件、走真实网络）
    let provider = NetworkProvider<HealthEndpoint>()
    do {
        // ③ 发请求；返回的 NetworkResponsable 可转 String / Data / JSON / 模型
        let response = try await provider.request(.ping)
        print("LEVEL1 服务器返回：\(response.toString() ?? "")")
    } catch {
        // 框架抛的都是 NetworkError，已带中文文案
        print("LEVEL1 失败：\(error.localizedDescription)")
    }
}

// ============================================================================
// MARK: - LEVEL 2 ▸ 进阶：POST 带参数 + 解析强类型模型
// ============================================================================
//
// 新概念：① 带参数的 POST（requestParameters）；② 把响应解析成 Codable 模型（toModel）。
//
// 注意模型用 camelCase（loginToken），服务端用 snake_case（login_token）——
// 框架的 toModel 已开启 convertFromSnakeCase，自动对齐，无需写 CodingKeys。

/// 登录响应模型。
/// 【重要】Swift 6.2 默认 @MainActor 工程下，要喂给 actor 内 `toModel<T: Decodable & Sendable>`
/// 的模型必须标 `nonisolated`，否则其 Decodable 一致性被 main-actor 隔离、无法满足 Sendable 约束。
public nonisolated struct LoginResult: Decodable, Sendable {
    public let userId: String       // ← 自动对齐服务端 "user_id"
    public let loginToken: String   // ← 自动对齐服务端 "login_token"
}

/// LEVEL 2 端点：登录（POST + JSON 参数）。
public nonisolated enum AuthEndpoint: NetworkTarget {
    case login(username: String, password: String)

    public var baseURL: URL { URL(string: "https://base.aldeloepay.com")! }
    public var path: String { "appsigninnew" }
    public var httpMethod: HTTPMethod { .post }

    public var task: NetworkTask {
        switch self {
        case let .login(username, password):
            // 字典参数 + JSON 编码 → 自动写进 Body 并设 Content-Type
            return .requestParameters(
                parameters: ["username": username, "password": password],
                encoding: .json
            )
        }
    }
}

/// LEVEL 2 调用示例：拿到响应后解析成模型。
public func level2_postAndDecode() async {
    let provider = NetworkProvider<AuthEndpoint>()
    do {
        let response = try await provider.request(.login(username: "Sen", password: "123456"))
        let result = try response.toModel(LoginResult.self)   // 字节流 → 强类型模型
        print("LEVEL2 登录成功，token=\(result.loginToken)")
    } catch {
        print("LEVEL2 失败：\(error.localizedDescription)")
    }
}

// ============================================================================
// MARK: - LEVEL 3 ▸ 实战：多源域名分流 + 动态超时 + 复合参数
// ============================================================================
//
// 新概念：一个 enum 管理一个业务域的【多个】API，每个 case 可以有：
//   ① 不同的 baseURL（多源分流：Base / TMS / ePay 三套集群）
//   ② 不同的超时（登录要快、日志上传容忍久）
//   ③ 不同的编码（含最复杂的"URL Query + Body 同时存在"的复合参数）
//
// 这是真实项目里 Endpoint 的典型形态。

/// 订单领域端点：4 个 API 各有不同的域名/方法/超时/参数。
public nonisolated enum OrderEndpoint: NetworkTarget {
    case signIn(username: String)                            // 登录（Base 集群）
    case getActiveOrders(tmsStoreGID: String, status: String) // 查订单（复合参数）
    case editPriceSafVoid(payload: EncryptedOrderModel)       // 离线撤销（加密，见 LEVEL 5）
    case uploadTerminalLog(localURL: URL)                     // 日志上传（TMS 集群）

    /// ① 多源域名分流：不同 case 路由到不同服务器集群。
    public var baseURL: URL {
        switch self {
        case .signIn:
            return URL(string: "https://base.aldeloepay.com")!          // 登录走 Base
        case .uploadTerminalLog:
            return URL(string: "https://tms.aldeloepay.com")!           // 日志走 TMS
        case .getActiveOrders, .editPriceSafVoid:
            return URL(string: "https://api.aldeloepay.com/epayapp/v1")! // 业务走 ePay
        }
    }

    public var path: String {
        switch self {
        case .signIn: return "appsigninnew"
        case .getActiveOrders: return "merchantstore/terminal/list"
        case .editPriceSafVoid: return "callback/void/saf"
        case .uploadTerminalLog: return "uploadlogfile"
        }
    }

    public var httpMethod: HTTPMethod {
        switch self {
        case .getActiveOrders: return .get
        default: return .post
        }
    }

    /// ② 动态超时红线：按业务风险/耗时分别设定。
    public var timeoutInterval: TimeInterval {
        switch self {
        case .editPriceSafVoid: return 60.0     // 支付清算：高危长延迟，给足 60s
        case .uploadTerminalLog: return 120.0   // 大日志上传：容忍 120s
        case .signIn: return 15.0               // 登录：求快，15s 不通就报错
        default: return 30.0                    // 其余默认 30s
        }
    }

    public var task: NetworkTask {
        switch self {
        case let .signIn(username):
            return .requestParameters(parameters: ["username": username], encoding: .json)

        case let .getActiveOrders(tmsStoreGID, status):
            // ③ 复合参数：TMSStoreGID 拼到 URL query，status 放进 JSON body
            return .requestCompositeParameters(
                bodyParameters: ["status": status],
                bodyEncoding: .json,
                urlParameters: ["TMSStoreGID": tmsStoreGID]
            )

        case let .editPriceSafVoid(payload):
            // 加密 SAF 包（详见 LEVEL 5）
            return .requestEncryptedJSON(payload, encryptKey: "POS_DES_SECRET_KEY_99", isGzip: true)

        case let .uploadTerminalLog(fileURL):
            return .uploadFile(fileURL)         // 按文件路径直接上传
        }
    }

    public var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }

    /// 离线假数据：供 LEVEL 5 的 stub Preview 使用，按 case 返回不同样本。
    public var sampleData: Data {
        switch self {
        case .getActiveOrders:
            return #"[{"order_id":"015","server_name":"Sen"}]"#.data(using: .utf8) ?? Data()
        case .signIn:
            return #"{"user_id":"u-001","display_name":"Sen"}"#.data(using: .utf8) ?? Data()
        default:
            return #"{"is_success":true}"#.data(using: .utf8) ?? Data()
        }
    }
}

// ============================================================================
// MARK: - LEVEL 4 ▸ 封装：Repository 收口 + AOP 插件
// ============================================================================
//
// 新概念：① 用 Repository 把"端点细节 + 解析"封装起来，业务层只调语义化方法；
//        ② 创建 provider 时挂载插件（设备指纹、签名），所有请求自动带上安全头。
//
// 好处：业务层（ViewModel）完全不碰 NetworkTarget/NetworkProvider，只认 Repository；
//       切换真实/Mock 只需换注入的 provider，业务零改动。

/// 订单仓储：对外暴露语义化方法，对内封装端点与解析。
public nonisolated final class OrderRepository: Sendable {

    private let provider: NetworkProvider<OrderEndpoint>

    /// 依赖注入：生产传真实 provider，测试/Preview 传 stub provider，一秒热插拔。
    public init(provider: NetworkProvider<OrderEndpoint>) {
        self.provider = provider
    }

    /// ② 生产装配：挂载"设备指纹 + 签名"两个 AOP 插件。
    /// 注意插件顺序——先指纹（可能改 body 之外的头），后签名（对最终 body 算签名）。
    public static func live() -> OrderRepository {
        let provider = NetworkProvider<OrderEndpoint>(
            plugins: [DeviceFingerprintPlugin(), CryptoSignaturePlugin()]
        )
        return OrderRepository(provider: provider)
    }

    /// 业务方法：查活跃订单。内部完成"发请求 + 解析 + DTO→领域模型"全流程。
    public func fetchActiveOrders(storeGID: String) async throws -> [OrderEntity] {
        let response = try await provider.request(.getActiveOrders(tmsStoreGID: storeGID, status: "OPEN"))
        let dtos = try response.toModel([OrderDTO].self)
        return dtos.map { $0.toDomain() }    // DTO（数据层）→ Entity（领域层）
    }
}

// ============================================================================
// MARK: - LEVEL 5 ▸ 高级：并发合流 + 加密 SAF + 离线 Preview
// ============================================================================

public extension OrderRepository {

    /// 【高级 A】现代并发双向合流：两个请求同时起飞，一起 await。
    /// 用 `async let` 替代老式 DispatchGroup/信号量——更安全、无死锁、可取消。
    func fetchDashboardParallelData(storeGID: String) async throws -> (UserDTO, [OrderDTO]) {
        // 两个请求并行发出（此处尚未 await，二者同时在途）
        async let userTask = provider.request(.signIn(username: "Sen"))
        async let ordersTask = provider.request(.getActiveOrders(tmsStoreGID: storeGID, status: "OPEN"))

        // 在这里统一等待两者都到齐
        let (userResponse, ordersResponse) = try await (userTask, ordersTask)
        let user = try userResponse.toModel(UserDTO.self)
        let orders = try ordersResponse.toModel([OrderDTO].self)
        return (user, orders)
    }

    /// 【高级 B】加密 SAF 撤销交易：使用 requestEncryptedJSON 任务类型。
    /// 框架负责标记 gzip/octet-stream，实际加密由 CryptoSignaturePlugin/工具链完成。
    func voidOrderOffline(orderId: String) async throws {
        let payload = EncryptedOrderModel(orderId: orderId)
        _ = try await provider.request(.editPriceSafVoid(payload: payload))
    }
}

// MARK: - 伴随 DTO / Entity（数据层模型）
//
// 【Swift 6.2 隔离提醒】下面这些会跨 actor 边界 / 传入 `Sendable` 约束泛型的模型，
// 必须显式 `nonisolated`，否则其 Codable 一致性被 main-actor 隔离 → 编译报错。
// 数据传输对象本就不该绑定任何 actor，`nonisolated` 语义正确且必需。

/// 订单 DTO（数据层，对应服务端 JSON 结构）。
public nonisolated struct OrderDTO: Decodable, Sendable {
    public let orderId: String
    /// DTO → 领域 Entity 的转换（数据层不外泄到业务层）。
    public func toDomain() -> OrderEntity { OrderEntity(id: orderId) }
}

/// 用户 DTO。
public nonisolated struct UserDTO: Decodable, Sendable {
    public let userId: String
    public let displayName: String
}

/// 加密订单负载（用于 SAF 撤销）。
public nonisolated struct EncryptedOrderModel: Encodable, Sendable {
    public let orderId: String
    public init(orderId: String) { self.orderId = orderId }
}

/// 订单领域实体（业务层模型，与传输细节解耦）。
public nonisolated struct OrderEntity: Identifiable, Sendable {
    public let id: String
}

// MARK: - 【高级 C】SwiftUI 离线 Preview
//
// stubBehavior 设为 .delayed 后，provider 完全不碰真实网络，
// 直接按延迟返回 sampleData——因此 Preview 可在 100% 离线下跑通 Loading→数据 全流程，
// 非常适合审计骨架屏/加载态。

#Preview("Network Stub Demo") {
    NetworkExampleView()
}

/// 演示视图：离线 stub 跑通"加载中 → 显示订单号"。
private struct NetworkExampleView: View {
    @State private var orderID: String = "loading..."

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Network Subsystem Demo")
                .font(AppFont.tabletH2Medium)
            Text("Mock Order: \(orderID)")
                .font(AppFont.tabletBody1Regular)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(Spacing.xl)
        .task {
            // 关键：stubBehavior = .delayed → 离线返回 sampleData，真实网络完全不参与
            let mockProvider = NetworkProvider<OrderEndpoint>(
                plugins: [DeviceFingerprintPlugin()],
                stubBehavior: .delayed(seconds: 0.6)     // 模拟 0.6s 弱网，看得到 loading 态
            )
            let repository = OrderRepository(provider: mockProvider)
            do {
                let orders = try await repository.fetchActiveOrders(storeGID: "01")
                orderID = orders.first?.id ?? "empty"
            } catch {
                orderID = error.localizedDescription
            }
        }
    }
}
