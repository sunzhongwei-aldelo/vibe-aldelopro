//
//  NetworkPlugin.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】面向切面编程（AOP）插件契约。把"每个请求都要做的横切逻辑"
//  （加签名头、点亮 HUD、埋点日志）从业务里抽离成可插拔的插件，
//  在请求生命周期的固定时点被引擎自动回调。新增一种横切能力 = 新增一个插件，
//  无需改动引擎或业务代码（开闭原则）。
//

import Foundation

/// 网络全生命周期 AOP 插件协议。
///
/// 三个时点对应请求的三个阶段：
///   prepare（起飞前加工）→ willSend（即将发出）→ didReceive（落地/失败）
///
/// 实现类需 `Sendable`（会被持有在 `actor` 里跨线程调用）。
public nonisolated protocol NetworkPlugin: Sendable {
    /// 【起飞前】请求发出前最后一刻触发。可返回加工后的**新请求**
    /// （追加安全头、时间戳、签名等）。遵循不可变规范：返回新副本而非原地改入参。
    func prepare(_ request: URLRequest, target: any NetworkTarget) -> URLRequest

    /// 【即将发出】请求挂载网络链路的瞬间触发。适合点亮全局 Loading / HUD。
    func willSend(_ request: URLRequest, target: any NetworkTarget)

    /// 【已落地】响应成功或失败的瞬间触发。适合审计日志、埋点清算、关闭 HUD。
    func didReceive(_ result: Result<any NetworkResponsable, Error>, target: any NetworkTarget)
}

// MARK: - Default Implementations

/// 全部方法给空默认实现：插件只需实现自己关心的时点。
/// 例如只做"加签名头"的插件，仅实现 `prepare` 即可，无需写空的 willSend/didReceive。
public nonisolated extension NetworkPlugin {
    func prepare(_ request: URLRequest, target: any NetworkTarget) -> URLRequest { request }
    func willSend(_ request: URLRequest, target: any NetworkTarget) {}
    func didReceive(_ result: Result<any NetworkResponsable, Error>, target: any NetworkTarget) {}
}
