//
//  NetworkProvider.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】整个网络框架的"发动机"。NetworkTarget 描述请求长什么样，
//  NetworkProvider 负责把它真正发出去并拿回响应。它是一个 Swift 6 `actor`，
//  天然串行化内部状态访问，无需手写锁。
//
//  【三条核心设计】
//   1. 零侵入依赖：公开 API 不出现任何 Alamofire 类型 → 没装 Alamofire 也能编译，
//      stub 模式照常工作；用 SPM/Pod 装上 Alamofire 后，真实请求分支由
//      `#if canImport(Alamofire)` 自动启用，无需手工改一行代码。
//   2. 原生参数编码：JSON / URL Query / 表单编码全用 Foundation 实现，不依赖第三方。
//   3. 协同取消：响应 Task 取消信号，视图 dismiss 时能熔断在途请求。
//

import Foundation
#if canImport(Alamofire)
import Alamofire
#endif

/// 基于 `actor` 的网络核心调度器。泛型 `Target` 绑定一个具体的端点枚举。
///
/// 用法：`let provider = NetworkProvider<OrderEndpoint>(plugins: [...])`
/// 然后 `try await provider.request(.someCase)`。
public actor NetworkProvider<Target: NetworkTarget> {

    /// AOP 插件管道。请求经过每个插件的 prepare/willSend/didReceive。
    private let plugins: [any NetworkPlugin]
    /// 测试桩开关。`.never` 走真网，其余走假数据。
    private let stubBehavior: NetworkStubBehavior

    #if canImport(Alamofire)
    /// Alamofire 会话。只在引入依赖时编译进来；未引入时这个属性根本不存在。
    private let afSession: Session
    #endif

    /// 创建调度器。
    /// - Parameters:
    ///   - plugins: AOP 插件（设备指纹、签名、HUD、埋点…）。按数组顺序依次执行。
    ///   - stubBehavior: 测试桩行为，默认 `.never`（生产走真实网络）。
    public init(
        plugins: [any NetworkPlugin] = [],
        stubBehavior: NetworkStubBehavior = .never
    ) {
        self.plugins = plugins
        self.stubBehavior = stubBehavior
        #if canImport(Alamofire)
        self.afSession = Session.default
        #endif
    }

    // MARK: - Public Entry（统一请求入口）

    /// 发起一次请求并返回响应。这是业务唯一需要调用的方法。
    ///
    /// 整条流水线：stub 分流 → 构建 URLRequest → 插件 prepare → 插件 willSend →
    /// 执行 → 成功/失败都通知插件 didReceive。
    public func request(_ target: Target) async throws -> any NetworkResponsable {
        // 1) 测试桩分流：非 .never 直接回填假数据，根本不碰物理网络。
        if case .never = stubBehavior {
            // 落到下面真实流程。
        } else {
            return try await executeStub(target, behavior: stubBehavior)
        }

        // 2) 把 target 翻译成一个原生 URLRequest（含参数编码）。
        var urlRequest = try buildURLRequest(target)

        // 3) 插件链：起飞前加工（注入指纹/签名头等）。每个插件返回新请求，链式传递。
        for plugin in plugins {
            urlRequest = plugin.prepare(urlRequest, target: target)
        }

        // 4) 插件链：通知"即将发出"（点亮 HUD 等）。
        for plugin in plugins {
            plugin.willSend(urlRequest, target: target)
        }

        // 5) 真正执行；无论成败都通知插件 didReceive，再决定返回还是抛错。
        do {
            let data = try await execute(urlRequest, target: target)
            let response = NetworkResponse(data: data)
            notifyReceived(.success(response), target: target)
            return response
        } catch {
            let mapped = mapError(error)                 // 统一映射成 NetworkError
            notifyReceived(.failure(mapped), target: target)
            throw mapped
        }
    }

    // MARK: - Stub（离线假数据）

    /// 测试桩执行：可选延迟后返回 `target.sampleData`。
    private func executeStub(
        _ target: Target,
        behavior: NetworkStubBehavior
    ) async throws -> any NetworkResponsable {
        if case let .delayed(seconds) = behavior {
            // 用可取消的 sleep 模拟网络延迟；被取消则按"任务取消"处理。
            do {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            } catch {
                throw NetworkError.taskCanceled
            }
        }
        if Task.isCancelled { throw NetworkError.taskCanceled }
        let response = NetworkResponse(data: target.sampleData)
        notifyReceived(.success(response), target: target)   // stub 也走插件通知，行为一致
        return response
    }

    // MARK: - Request Building（原生参数编码）

    /// 把 `NetworkTarget` 翻译成 `URLRequest`：设置 URL、方法、超时、头、Body。
    private func buildURLRequest(_ target: Target) throws -> URLRequest {
        var request = URLRequest(url: target.requestURL)
        request.httpMethod = target.httpMethod.rawValue
        request.timeoutInterval = target.timeoutInterval     // 动态超时在此挂载

        if let headers = target.headers {
            for (name, value) in headers.dictionary {
                request.setValue(value, forHTTPHeaderField: name)
            }
        }

        try configureTask(target.task, into: &request)        // 根据 task 类型构造 Body
        return request
    }

    /// 根据 `NetworkTask` 的具体类型，把请求体/查询串填进 request。
    private func configureTask(_ task: NetworkTask, into request: inout URLRequest) throws {
        switch task {
        case .requestPlain:
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case let .requestData(data):
            request.httpBody = data

        case let .requestJSONEncodable(encodable):
            request.httpBody = try encodeJSON(encodable)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case let .requestCustomJSONEncodable(encodable, encoderProvider):
            do {
                request.httpBody = try encoderProvider().encode(encodable)
            } catch {
                throw NetworkError.encodingFailed
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case let .requestEncryptedJSON(encodable, _, isGzip):
            // 这里只写入原始 JSON 字节 + 标记 gzip/octet-stream；
            // 真正的加密在 CryptoSignaturePlugin（或硬件工具链）的 prepare 阶段完成。
            request.httpBody = try encodeJSON(encodable)
            if isGzip { request.setValue("gzip", forHTTPHeaderField: "Content-Encoding") }
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        case let .requestParameters(parameters, encoding):
            try encode(parameters: parameters, encoding: encoding, into: &request)

        case let .requestCompositeParameters(bodyParameters, bodyEncoding, urlParameters):
            // 先把 urlParameters 拼到 query，再把 bodyParameters 编码进 body。
            try encode(parameters: urlParameters, encoding: .urlQuery, into: &request)
            try encode(parameters: bodyParameters, encoding: bodyEncoding, into: &request)

        case let .uploadFile(fileURL):
            request.httpBody = try? Data(contentsOf: fileURL)
        }
    }

    /// 把 Encodable 模型编码成 JSON Data，失败统一转 `.encodingFailed`。
    private func encodeJSON(_ encodable: any Encodable) throws -> Data {
        do {
            return try JSONEncoder().encode(encodable)
        } catch {
            throw NetworkError.encodingFailed
        }
    }

    /// 字典参数的三种编码实现（Foundation 原生，不依赖 Alamofire）。
    private func encode(
        parameters: Parameters,
        encoding: ParameterEncoding,
        into request: inout URLRequest
    ) throws {
        switch encoding {
        case .json:
            // [String: any Sendable] 先擦除成 [String: Any] 才能交给 JSONSerialization。
            let object = parameters.mapValues { $0 as Any }
            guard JSONSerialization.isValidJSONObject(object) else {
                throw NetworkError.encodingFailed
            }
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: object)
            } catch {
                throw NetworkError.encodingFailed
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case .urlQuery:
            // 把参数追加到现有 URL 的 query。key 排序保证输出稳定（便于缓存/测试）。
            guard let url = request.url,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw NetworkError.invalidRequest
            }
            var items = components.queryItems ?? []
            for key in parameters.keys.sorted() {
                items.append(URLQueryItem(name: key, value: stringify(parameters[key])))
            }
            components.queryItems = items
            guard let newURL = components.url else { throw NetworkError.invalidRequest }
            request.url = newURL

        case .urlForm:
            // application/x-www-form-urlencoded：key=value&key=value，需百分号转义。
            let pairs = parameters.keys.sorted().map { key -> String in
                "\(percentEncode(key))=\(percentEncode(stringify(parameters[key])))"
            }
            request.httpBody = pairs.joined(separator: "&").data(using: .utf8)
            request.setValue(
                "application/x-www-form-urlencoded; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
        }
    }

    /// 把任意 Sendable 值转成字符串（用于 query/form 拼装）。
    private func stringify(_ value: (any Sendable)?) -> String {
        guard let value else { return "" }
        return String(describing: value)
    }

    /// URL 百分号转义。在系统 urlQueryAllowed 基础上再剔除子分隔符，
    /// 避免 `&`、`=` 等被当作结构字符导致歧义。
    private func percentEncode(_ string: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: ":#[]@!$&'()*+,;=")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }

    // MARK: - Execution（Alamofire 隔离区）

    /// 真正发出请求并取回 Data。这是唯一与 Alamofire 耦合的地方，已用 `#if` 隔离。
    private func execute(_ request: URLRequest, target: Target) async throws -> Data {
        #if canImport(Alamofire)
        // —— 已引入 Alamofire：走真实网络 ——
        if Task.isCancelled { throw NetworkError.taskCanceled }

        let dataRequest = afSession.request(request)
        // 按 target 的策略挂载状态码校验。
        switch target.validationType {
        case .successCodes:
            _ = dataRequest.validate(statusCode: 200..<300)
        case let .customCodes(range):
            _ = dataRequest.validate(statusCode: range)
        case .none:
            break
        }

        // async/await 等待响应（Alamofire 的现代并发 API）。
        let response = await dataRequest.serializingData().response
        if Task.isCancelled { throw NetworkError.taskCanceled }   // 取消的二次检查

        switch response.result {
        case let .success(data):
            return data
        case let .failure(afError):
            // 失败时尽量从响应体里抠出服务端的错误文案，给用户更准确的提示。
            let serverMessage = extractServerMessage(from: response.data)
            throw mapAFError(
                afError,
                statusCode: response.response?.statusCode,
                serverMessage: serverMessage
            )
        }
        #else
        // —— 未引入 Alamofire：真实请求不可用，但 stub 模式完全正常 ——
        // 装上 Alamofire 后本分支自动消失、上面的真实分支自动启用，无需改码。
        _ = request
        _ = target
        throw NetworkError.dependencyMissing("Alamofire")
        #endif
    }

    // MARK: - Error Mapping（错误归一化）

    /// 把任意 Error 收敛成 NetworkError，保证抛给业务的永远是统一类型。
    private func mapError(_ error: Error) -> NetworkError {
        if let netError = error as? NetworkError { return netError }   // 已经是了，直接透传
        if error is CancellationError { return .taskCanceled }
        return .unknown(error.localizedDescription)
    }

    /// 尝试从响应体 JSON 里提取服务端错误文案（兼容三种常见字段名）。
    private func extractServerMessage(from data: Data?) -> String? {
        guard let data,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return (object["errorMessage"] as? String)
            ?? (object["message"] as? String)
            ?? (object["error"] as? String)
    }

    #if canImport(Alamofire)
    /// 把 Alamofire 的 AFError + HTTP 状态码翻译成业务 NetworkError。
    private func mapAFError(
        _ error: AFError,
        statusCode: Int?,
        serverMessage: String?
    ) -> NetworkError {
        if error.isExplicitlyCancelledError { return .taskCanceled }

        if let code = statusCode {
            // 服务端给了明确文案就优先用它（最贴近真实原因）。
            if let message = serverMessage, !message.isEmpty {
                return .serverError(statusCode: code, message: message)
            }
            switch code {
            case 400: return .badRequest
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 500...599: return .serverError(statusCode: code, message: "服务器系统故障 (\(code))")
            default: break
            }
        }

        // 没有状态码 → 多半是连接层问题，进一步看底层 URLError。
        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                return .noNetwork
            case .cancelled:
                return .taskCanceled
            default:
                break
            }
        }

        return .unknown(error.localizedDescription)
    }
    #endif

    // MARK: - Plugin Notification

    /// 统一向所有插件广播"响应已落地"。
    private func notifyReceived(
        _ result: Result<any NetworkResponsable, Error>,
        target: Target
    ) {
        for plugin in plugins {
            plugin.didReceive(result, target: target)
        }
    }
}
