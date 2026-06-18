//
//  DeviceFingerprintPlugin.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】一个 AOP 插件示例：在每个请求起飞前，统一注入设备指纹类请求头
//  （User-Agent、设备特征令牌、门店标识）。把这些散落在各处的硬编码 header
//  收拢到一个插件，新增/修改时只动这一处。
//

import Foundation

/// 设备指纹插件：装配 User-Agent + 业务身份头。
///
/// 【为什么不直接读 UIDevice】本项目默认 `@MainActor` 隔离，而 `UIDevice.current`
/// 是 main-actor 隔离的；插件却在 `actor`（非主线程）里被调用，同步访问 UIDevice 会报警。
/// 因此改用与 actor 隔离无关的 nonisolated 安全来源：`utsname` 取机型、`ProcessInfo` 取系统版本。
public nonisolated final class DeviceFingerprintPlugin: NetworkPlugin {

    private let cryptoData: String      // 设备加密特征令牌
    private let tmsStoreGID: String     // 门店全局标识
    private let userAgent: String       // 构造期一次性算好，prepare 时直接用

    /// - Parameters:
    ///   - cryptoData: 设备加密特征令牌（默认占位，生产环境由上层注入真实值）。
    ///   - tmsStoreGID: 门店全局标识。
    ///   - userAgent: 自定义 User-Agent，默认按运行环境自动拼装。
    public init(
        cryptoData: String = "1122",
        tmsStoreGID: String = "GLOBAL_TMS_STORE_GID_MARKER",
        userAgent: String = DeviceFingerprintPlugin.defaultUserAgent()
    ) {
        self.cryptoData = cryptoData
        self.tmsStoreGID = tmsStoreGID
        self.userAgent = userAgent
    }

    /// 起飞前钩子：把三个身份头写进请求并返回新请求（不可变更新）。
    public func prepare(_ request: URLRequest, target: any NetworkTarget) -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        mutableRequest.setValue(cryptoData, forHTTPHeaderField: "crypto-data")
        mutableRequest.setValue(tmsStoreGID, forHTTPHeaderField: "TMSStoreGID")
        return mutableRequest
    }

    /// 拼装高保真 User-Agent：`Aldelo ePay/{ver} ({model}; iOS {os})`，
    /// 例如 `Aldelo ePay/3.2.1 (iPad14,3; iOS 18.4.0)`。
    ///
    /// 全部使用 `nonisolated` 安全的来源（`Bundle` / `utsname` / `ProcessInfo`），
    /// 不触碰 main-actor 隔离的 `UIDevice`，因此可在任意线程零警告构造。
    public static func defaultUserAgent() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let model = hardwareModel()
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        return "Aldelo ePay/\(appVersion) (\(model); iOS \(osString))"
    }

    /// 通过 POSIX `uname(2)` 读取硬件机型标识（如 "iPad14,3"）。
    /// `utsname.machine` 是定长 C 字符数组，用 Mirror 逐字节拼成 Swift String。
    /// 纯 C API，线程安全、无 actor 隔离，且比 `UIDevice.current.model`（只返回笼统的 "iPad"）更精确。
    private static func hardwareModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { result, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            result.append(Character(UnicodeScalar(UInt8(value))))
        }
        return identifier.isEmpty ? "iOS Device" : identifier
    }
}
