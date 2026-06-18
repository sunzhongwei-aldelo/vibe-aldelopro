//
//  FaceScanCameraService.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

@preconcurrency import AVFoundation
import UIKit

// MARK: - 面部扫描摄像头服务

/// 基于 AVFoundation 的面部扫描实现
/// 职责：
/// 1. 管理前置摄像头 AVCaptureSession
/// 2. 捕获照片并检测面部数量（通过 Utility.check_face_count）
/// 3. 压缩照片为 JPEG 数据供 AI API 使用
/// 4. 调用 AI API 进行面部搜索（预留接口）
///
/// 使用 @MainActor 确保 previewLayer 和 UI 相关操作在主线程执行
@MainActor
final class FaceScanCameraService: FaceScanServiceProtocol {

    // MARK: - 属性

    /// 摄像头捕获会话
    private let captureSession = AVCaptureSession()
    /// 照片输出
    private let photoOutput = AVCapturePhotoOutput()
    /// 串行队列保护会话启停操作
    private let sessionQueue = DispatchQueue(label: "com.aldelo.facescan.session")
    /// 预览图层（UI 展示用）
    let previewLayer: AVCaptureVideoPreviewLayer?
    /// 照片捕获代理（桥接 delegate → async）
    private let photoCaptureDelegate = PhotoCaptureDelegate()
    /// 是否使用 InsightFace API
    private let enableInsightFace: Bool

    // MARK: - 初始化

    /// - Parameter enableInsightFace: 是否启用 InsightFace API（默认 false，使用标准 API）
    init(enableInsightFace: Bool = false) {
        self.enableInsightFace = enableInsightFace
        let session = captureSession
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.previewLayer = layer
    }

    // MARK: - FaceScanServiceProtocol

    /// 配置并启动摄像头会话
    func startSession() async throws {
        guard let frontCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            throw CashierAuthError.cameraUnavailable
        }

        // 检查摄像头权限
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            guard granted else { throw CashierAuthError.cameraUnavailable }
        } else if status != .authorized {
            throw CashierAuthError.cameraUnavailable
        }

        // 在后台队列配置会话（避免阻塞主线程）
        // nonisolated(unsafe) 消除 Sendable 闭包捕获警告（串行队列保护线程安全）
        nonisolated(unsafe) let session = captureSession
        nonisolated(unsafe) let output = photoOutput
        nonisolated(unsafe) let camera = frontCamera

        await withCheckedContinuation { continuation in
            sessionQueue.async {
                session.beginConfiguration()
                session.sessionPreset = .photo

                // 添加输入
                do {
                    let input = try AVCaptureDeviceInput(device: camera)
                    if session.canAddInput(input) {
                        session.addInput(input)
                    }
                } catch {
                    session.commitConfiguration()
                    continuation.resume()
                    return
                }

                // 添加照片输出
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                // 锁定预览方向，防止画面随设备旋转而翻转
                if let connection = output.connection(with: .video) {
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = true
                    }
                }

                session.commitConfiguration()
                session.startRunning()
                continuation.resume()
            }
        }
    }

    /// 停止摄像头会话
    func stopSession() {
        nonisolated(unsafe) let session = captureSession
        sessionQueue.async {
            session.stopRunning()
        }
    }

    /// 捕获照片并进行面部检测
    /// - Returns: 检测到恰好 1 张面部时返回 JPEG 数据，否则返回 nil
    func captureAndDetectFace() async throws -> Data? {
        // 通过代理捕获照片
        let imageData = try await photoCaptureDelegate.capturePhoto(using: photoOutput)
        guard let imageData else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }

        // 使用 Utility 检测面部数量（参考已有实现 Utility.check_face_count）
        let (faceCount, correctedImage) = Self.checkFaceCount(img: image)

        if faceCount == 1 {
            // 正好检测到一张面部，压缩为 JPEG 供 API 使用
            return correctedImage.jpegData(compressionQuality: 0.8)
        }
        // 面部数量不为 1（0 或多张），返回 nil 让调用方重试
        return nil
    }

    /// 调用面部搜索 API
    /// - Parameter imageData: JPEG 格式面部照片
    /// - Returns: 匹配到的员工 ID
    func searchFace(imageData: Data) async throws -> Int64 {
        // TODO: 接入实际 AIAPI
        // 参考实现：
        // if enableInsightFace {
        //     return try await AIAPI().search_face_insight(p_data: imageData)
        // } else {
        //     let base64 = imageData.base64EncodedString(options: .lineLength64Characters)
        //     return try await AIAPI().search_face(photoData: base64, limit: hasLimit)
        // }
        throw CashierAuthError.faceNotRecognized
    }

    // MARK: - 面部检测（预留接口）

    /// 检测图片中面部数量
    /// - Parameter img: 待检测的图片
    /// - Returns: (面部数量, 处理后的图片)
    /// - Note: 实际项目中对接 Utility.check_face_count(img:)
    private static func checkFaceCount(img: UIImage) -> (Int, UIImage) {
        // TODO: 对接实际的 Utility.check_face_count(img:)
        // let (count, processedImg) = Utility.check_face_count(img: img)
        // return (count, processedImg)

        // 临时实现：假设始终检测到 1 张面部（便于开发调试）
        return (1, img)
    }
}

// MARK: - 照片捕获代理

/// 封装 AVCapturePhotoCaptureDelegate，桥接 async/await
/// 使用 @unchecked Sendable 因为 continuation 仅在单次拍照流程中使用
private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    /// 存储 continuation 用于 async 桥接
    private var continuation: CheckedContinuation<Data?, Error>?

    /// 异步捕获照片
    /// - Parameter output: 照片输出源
    /// - Returns: 捕获的照片数据（JPEG），失败时返回 nil
    func capturePhoto(using output: AVCapturePhotoOutput) async throws -> Data? {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            output.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    /// 照片处理完成回调
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            continuation?.resume(throwing: error)
            continuation = nil
            return
        }
        let data = photo.fileDataRepresentation()
        continuation?.resume(returning: data)
        continuation = nil
    }

    /// 静音快门声
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}

// MARK: - Mock 实现（Preview / 测试用）

/// 模拟面部扫描服务，不使用实际摄像头
@MainActor
final class MockFaceScanService: FaceScanServiceProtocol {
    /// 预览图层（Mock 中为 nil）
    let previewLayer: AVCaptureVideoPreviewLayer? = nil
    /// 控制是否模拟检测到面部
    var shouldDetectFace: Bool = true

    func startSession() async throws {}
    func stopSession() {}

    func captureAndDetectFace() async throws -> Data? {
        try await Task.sleep(nanoseconds: 500_000_000)
        return shouldDetectFace ? Data([0xFF, 0xD8]) : nil
    }

    func searchFace(imageData: Data) async throws -> Int64 {
        try await Task.sleep(nanoseconds: 300_000_000)
        return 1001
    }
}
