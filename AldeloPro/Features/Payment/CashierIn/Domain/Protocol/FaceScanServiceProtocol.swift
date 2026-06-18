//
//  FaceScanServiceProtocol.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import Foundation
import AVFoundation

// MARK: - 面部扫描服务协议

/// 面部扫描服务的抽象接口
/// 负责摄像头管理、面部检测和照片捕获
/// 由 Data 层提供具体实现，ViewModel 通过此协议交互
/// 标记 @MainActor 因为 previewLayer 必须在主线程访问
@MainActor
protocol FaceScanServiceProtocol {
    /// 摄像头预览图层（用于 UIViewRepresentable 展示实时画面）
    var previewLayer: AVCaptureVideoPreviewLayer? { get }

    /// 启动摄像头会话
    /// - Throws: CashierAuthError.cameraUnavailable
    func startSession() async throws

    /// 停止摄像头会话
    func stopSession()

    /// 捕获当前帧并进行面部检测
    /// - Returns: 检测到单张面部时返回 JPEG 图片数据，否则为 nil
    func captureAndDetectFace() async throws -> Data?

    /// 使用面部图片数据调用 AI 识别 API
    /// - Parameter imageData: JPEG 格式的面部照片
    /// - Returns: 识别成功返回员工 ID，失败抛出错误
    func searchFace(imageData: Data) async throws -> Int64
}
