//
//  CashierInViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import Foundation
import AVFoundation

// MARK: - 收银员登录步骤枚举

/// 收银员登录流程中的各个步骤
enum CashierInStep: Equatable {
    /// 面部识别扫描中
    case faceIDScanning
    /// 面部识别中（带进度）
    case faceIDRecognizing
    /// 面部识别失败
    case faceIDFailed
    /// 密码输入页面
    case passwordEntry
    /// 登录成功（显示用户信息）
    case signedInSuccess(CashierSession)
    /// 设置开班金额
    case startAmount(CashierSession)
}

// MARK: - 面部扫描状态

/// 面部扫描过程中的状态
enum FaceScanState: Equatable {
    /// 空闲状态
    case idle
    /// 扫描中（显示绿色扫描线动画）
    case scanning
    /// 识别中（显示蓝色进度环）
    case recognizing(progress: Double)
    /// 扫描失败
    case failed
}

// MARK: - 收银员登录 ViewModel

/// 管理收银员登录流程的所有状态和业务逻辑
/// 支持面部识别和密码两种登录方式
@Observable @MainActor
final class CashierInViewModel {
    // MARK: - 对外状态（只读）

    /// 当前登录步骤
    private(set) var currentStep: CashierInStep = .faceIDScanning
    /// 面部扫描状态
    private(set) var faceScanState: FaceScanState = .idle
    /// 密码输入缓存
    private(set) var passcodeInput: String = ""
    /// 开班金额输入（以分为单位的字符串）
    private(set) var startAmountInput: String = "0"
    /// 加载状态
    private(set) var loadingState: LoadingState = .idle
    /// 错误弹窗信息（需要可写，供 .alert(item:) 绑定）
    var alertError: AlertError?
    /// 当前登录会话
    private(set) var session: CashierSession?

    /// 默认登录方式（依赖设置项）
    var defaultLoginMethod: CashierLoginMethod = .faceID

    // MARK: - 计算属性

    /// 格式化后的金额显示（如 "$12.50"）
    var formattedStartAmount: String {
        let cents = Int(startAmountInput) ?? 0
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
    }

    /// 金额的 Decimal 值（单位：美元）
    var startAmountDecimal: Decimal {
        let cents = Int(startAmountInput) ?? 0
        return Decimal(cents) / 100
    }

    /// 密码遮盖显示（用圆点代替实际字符）
    var maskedPasscode: String {
        String(repeating: "●", count: passcodeInput.count)
    }

    /// 摄像头预览图层（供 CameraPreviewView 使用）
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer? {
        faceScanService?.previewLayer
    }

    // MARK: - 依赖

    private let authService: CashierAuthServiceProtocol
    /// 面部扫描服务（摄像头 + Vision + API）
    private let faceScanService: FaceScanServiceProtocol?

    // MARK: - 初始化

    /// - Parameters:
    ///   - authService: 认证服务（Protocol 注入）
    ///   - faceScanService: 面部扫描服务（可选，nil 时使用模拟流程）
    ///   - defaultLogin: 默认登录方式，取决于系统设置
    init(
        authService: CashierAuthServiceProtocol,
        faceScanService: FaceScanServiceProtocol? = nil,
        defaultLogin: CashierLoginMethod = .faceID
    ) {
        self.authService = authService
        self.faceScanService = faceScanService
        self.defaultLoginMethod = defaultLogin
        self.currentStep = defaultLogin == .faceID ? .faceIDScanning : .passwordEntry
    }

    // MARK: - Face ID 相关操作

    /// 开始面部扫描
    func startFaceScan() {
        faceScanState = .scanning
        currentStep = .faceIDScanning
    }

    /// 执行面部扫描和识别
    /// 流程：启动摄像头 → 循环捕获帧 → Vision 检测面部 → 调用 API 识别 → 返回结果
    func performFaceScan() async {
        // 启动摄像头
        if let service = faceScanService {
            do {
                try await service.startSession()
            } catch {
                faceScanState = .failed
                currentStep = .faceIDFailed
                return
            }
        }

        // 循环捕获直到检测到面部或超时
        var attempts = 0
        let maxAttempts = 20  // 最多尝试 20 次（约 10 秒）

        while attempts < maxAttempts {
            try? await Task.sleep(nanoseconds: 500_000_000)
            attempts += 1

            guard let service = faceScanService else {
                // 无摄像头服务时使用模拟流程
                await simulateRecognizing()
                return
            }

            // 捕获并检测面部
            guard let imageData = try? await service.captureAndDetectFace() else {
                continue  // 未检测到面部，继续尝试
            }

            // 检测到面部，切换到识别状态
            faceScanState = .recognizing(progress: 0)
            currentStep = .faceIDRecognizing

            // 进度动画 + API 调用
            for i in 1...5 {
                try? await Task.sleep(nanoseconds: 150_000_000)
                faceScanState = .recognizing(progress: Double(i) / 10.0)
            }

            // 调用认证 API
            do {
                let result = try await authService.authenticateWithFaceID(imageData: imageData)
                // 识别成功
                faceScanState = .recognizing(progress: 1.0)
                service.stopSession()
                session = result
                currentStep = .signedInSuccess(result)
                return
            } catch {
                // 识别失败
                service.stopSession()
                faceScanState = .failed
                currentStep = .faceIDFailed
                return
            }
        }

        // 超时未检测到面部
        faceScanService?.stopSession()
        faceScanState = .failed
        currentStep = .faceIDFailed
    }

    /// 模拟面部识别过程（无摄像头时的兜底流程）
    func simulateRecognizing() async {
        faceScanState = .recognizing(progress: 0)
        currentStep = .faceIDRecognizing

        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 200_000_000)
            faceScanState = .recognizing(progress: Double(i) / 10.0)
        }

        do {
            let fakeImageData = Data()
            let result = try await authService.authenticateWithFaceID(imageData: fakeImageData)
            session = result
            currentStep = .signedInSuccess(result)
        } catch {
            faceScanState = .failed
            currentStep = .faceIDFailed
        }
    }

    /// 重新扫描
    func rescan() {
        faceScanState = .idle
        currentStep = .faceIDScanning
    }

    // MARK: - 密码登录相关操作

    /// 切换到密码登录页面
    func switchToPassword() {
        passcodeInput = ""
        currentStep = .passwordEntry
    }

    /// 切换回面部识别页面
    func switchToFaceID() {
        faceScanState = .idle
        currentStep = .faceIDScanning
    }

    /// 追加一位密码数字
    func appendPasscodeDigit(_ digit: String) {
        guard passcodeInput.count < 8 else { return }
        passcodeInput += digit
    }

    /// 删除最后一位密码数字
    func deletePasscodeDigit() {
        guard !passcodeInput.isEmpty else { return }
        passcodeInput = String(passcodeInput.dropLast())
    }

    /// 提交密码进行认证
    func submitPasscode() async {
        loadingState = .loading
        do {
            let result = try await authService.authenticateWithPassword(passcode: passcodeInput)
            session = result
            loadingState = .loaded
            currentStep = .signedInSuccess(result)
        } catch let error as CashierAuthError {
            loadingState = .error(error.localizedDescription)
            alertError = AlertError(
                title: "登录失败",
                message: error == .invalidPasscode
                    ? "密码错误，请重试。"
                    : "发生错误，请重试。"
            )
            passcodeInput = ""
        } catch {
            loadingState = .error(error.localizedDescription)
            alertError = AlertError(
                title: "错误",
                message: error.localizedDescription
            )
            passcodeInput = ""
        }
    }

    // MARK: - 开班金额相关操作

    /// 进入设置开班金额步骤
    func proceedToStartAmount() {
        guard let session else { return }
        startAmountInput = "0"
        currentStep = .startAmount(session)
    }

    /// 追加一位金额数字
    func appendAmountDigit(_ digit: String) {
        guard startAmountInput.count < 8 else { return }
        if startAmountInput == "0" {
            startAmountInput = digit
        } else {
            startAmountInput += digit
        }
    }

    /// 追加两个零（快捷输入"00"）
    func appendDoubleZero() {
        guard startAmountInput.count < 7 else { return }
        if startAmountInput == "0" { return }
        startAmountInput += "00"
    }

    /// 删除金额最后一位
    func deleteAmountDigit() {
        if startAmountInput.count <= 1 {
            startAmountInput = "0"
        } else {
            startAmountInput = String(startAmountInput.dropLast())
        }
    }

    /// 清空金额输入
    func clearAmount() {
        startAmountInput = "0"
    }

    /// 确认开班（提交金额并完成 CashierIn）
    func cashierIn() async {
        guard let session else { return }
        loadingState = .loading
        do {
            try await authService.setCashierStartAmount(startAmountDecimal, session: session)
            loadingState = .loaded
            // 导航由父级处理
        } catch {
            loadingState = .error(error.localizedDescription)
            alertError = AlertError(
                title: "错误",
                message: "设置开班金额失败，请重试。"
            )
        }
    }

    // MARK: - 弹窗

    /// 关闭错误弹窗
    func dismissAlert() {
        alertError = nil
    }
}

// MARK: - Preview 工厂方法

extension CashierInViewModel {
    /// 创建 Preview 用的 ViewModel
    /// - Parameter step: 初始步骤
    static func preview(step: CashierInStep = .faceIDScanning) -> CashierInViewModel {
        let vm = CashierInViewModel(authService: MockCashierAuthService())
        vm.currentStep = step
        return vm
    }
}

// MARK: - 弹窗错误模型

/// 用于 .alert(item:) 的错误信息结构
struct AlertError: Identifiable, Equatable {
    let id = UUID()
    /// 弹窗标题
    let title: String
    /// 弹窗正文
    let message: String

    static func == (lhs: AlertError, rhs: AlertError) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 加载状态枚举

/// 统一的异步加载状态
enum LoadingState: Equatable {
    /// 空闲
    case idle
    /// 加载中
    case loading
    /// 加载完成
    case loaded
    /// 加载出错
    case error(String)
}
