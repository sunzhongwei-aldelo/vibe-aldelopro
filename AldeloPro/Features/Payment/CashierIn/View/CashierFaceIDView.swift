//
//  CashierFaceIDView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI

// MARK: - 面部识别登录视图

/// 通过前置摄像头进行 AI 面部识别登录
/// 扫描过程：
/// 1. 圆形区域内显示浅绿色扫描线动画（圆形，与扫描框等大）
/// 2. 检测到面部后变为 "Recognizing..." + 蓝色进度环
/// 3. 失败时提供 "重新扫描" 和 "使用密码登录" 两个选项
/// - 页面内容竖直居中
/// - 所有尺寸按 screenWidth/1440 比例缩放，适配横竖屏
struct CashierFaceIDView: View {
    // MARK: - 依赖
    @Bindable var viewModel: CashierInViewModel
    @Environment(\.horizontalSizeClass) private var hSizeClass

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isCompact = hSizeClass == .compact
            let isLandscape = w > h
            // iPad: width/1440, iPhone横屏: height/960, iPhone竖屏: width/390
            let scale = isCompact
                ? (isLandscape ? h / 960 : w / 390)
                : w / 1440

            // 整体竖直居中，iPhone横屏可滚动
            ScrollView(showsIndicators: false) {
                VStack(spacing: scale * 24) {
                    Spacer(minLength: 0)
                    titleSection
                    cameraCircle(scale: scale, isCompact: isCompact)
                    if viewModel.currentStep == .faceIDFailed {
                        failedActions(scale: scale, isCompact: isCompact)
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: h)
            }
        }
        .task {
            if viewModel.faceScanState == .idle {
                viewModel.startFaceScan()
                await viewModel.performFaceScan()
            }
        }
    }

    // MARK: - 标题区域

    /// 根据当前步骤显示不同标题和副标题
    private var titleSection: some View {
        VStack(spacing: Spacing.xs) {
            Text(titleText)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            if let subtitle = subtitleText {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                    Text(subtitle)
                        .font(AppFont.tabletBody4Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    /// 主标题文本
    private var titleText: String {
        switch viewModel.currentStep {
        case .faceIDScanning:
            return "Cashier In By Scanning Your Face"
        case .faceIDRecognizing:
            return "Recognizing..."
        case .faceIDFailed:
            return "Unable To Recognize"
        default:
            return ""
        }
    }

    /// 副标题文本（仅扫描中和失败时显示）
    private var subtitleText: String? {
        switch viewModel.currentStep {
        case .faceIDScanning:
            return "Please Face The Camera And Align Your Face Within The Frame"
        case .faceIDFailed:
            return "Please Try Face Recognition Again Or Use Another Login Method"
        default:
            return nil
        }
    }

    // MARK: - 摄像头圆形区域

    /// 圆形扫描区域（比例缩放）
    /// 设计稿: 圆形区域约 390px 直径, iPhone 上缩小适配
    private func cameraCircle(scale: CGFloat, isCompact: Bool) -> some View {
        let circleSize = isCompact ? min(scale * 390, 220) : scale * 390

        return ZStack {
            // 外圈边框
            Circle()
                .stroke(AppColors.line, lineWidth: 3)
                .frame(width: circleSize + 20, height: circleSize + 20)

            // 蓝色进度环（识别中显示）
            if case .recognizing(let progress) = viewModel.faceScanState {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AppColors.primaryNormal,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: circleSize + 20, height: circleSize + 20)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: progress)
            }

            // 摄像头画面（实际摄像头预览或占位背景）
            ZStack {
                Circle()
                    .fill(AppColors.pageBgDeep)
                    .frame(width: circleSize, height: circleSize)

                // 如果有摄像头预览图层，显示实时画面
                CameraPreviewView(previewLayer: viewModel.cameraPreviewLayer)
                    .frame(width: circleSize, height: circleSize)
                    .clipShape(Circle())
            }

            // 浅绿色圆形扫描动画（与扫描框等大，仅扫描中显示）
            if viewModel.faceScanState == .scanning {
                ScanLineAnimation(circleSize: circleSize)
            }

            // 人脸占位图标
            Image(systemName: "person.fill")
                .font(.system(size: circleSize * 0.4))
                .foregroundColor(AppColors.textTertiary)
        }
    }

    // MARK: - 识别失败操作按钮

    /// 失败后的两个操作：重新扫描 / 使用密码登录（比例缩放）
    private func failedActions(scale: CGFloat, isCompact: Bool) -> some View {
        let buttonLayout = isCompact
        return Group {
            if buttonLayout {
                // iPhone：竖排按钮，避免横向溢出
                VStack(spacing: Spacing.sm) {
                    rescanButton(scale: scale, isCompact: isCompact)
                    usePasswordButton(scale: scale, isCompact: isCompact)
                }
            } else {
                // iPad：横排按钮
                HStack(spacing: scale * 16) {
                    rescanButton(scale: scale, isCompact: isCompact)
                    usePasswordButton(scale: scale, isCompact: isCompact)
                }
            }
        }
    }

    /// 重新扫描按钮
    private func rescanButton(scale: CGFloat, isCompact: Bool) -> some View {
        Button {
            viewModel.rescan()
            Task {
                viewModel.startFaceScan()
                await viewModel.performFaceScan()
            }
        } label: {
            Text("Rescan")
                .font(isCompact ? AppFont.tabletButton4Medium : AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.primaryNormal)
                .frame(width: isCompact ? nil : scale * 240)
                .frame(maxWidth: isCompact ? .infinity : nil)
                .padding(.vertical, isCompact ? Spacing.sm : scale * 20)
                .padding(.horizontal, isCompact ? Spacing.lg : 0)
                .background(AppColors.white100)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.xl)
                        .stroke(AppColors.primaryNormal, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// 使用密码登录按钮
    private func usePasswordButton(scale: CGFloat, isCompact: Bool) -> some View {
        Button {
            viewModel.switchToPassword()
        } label: {
            Text("Use Password To Log In")
                .font(isCompact ? AppFont.tabletButton4Medium : AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(width: isCompact ? nil : scale * 300)
                .frame(maxWidth: isCompact ? .infinity : nil)
                .padding(.vertical, isCompact ? Spacing.sm : scale * 20)
                .padding(.horizontal, isCompact ? Spacing.lg : 0)
                .background(AppColors.buttonPrimaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xl))
        }
        .buttonStyle(.plain)
    }

}

// MARK: - 扫描线动画组件

/// 圆形浅绿色半透明扫描动画，与扫描框等大
/// 从上到下循环扫描，使用圆形裁剪
private struct ScanLineAnimation: View {
    let circleSize: CGFloat
    @State private var offset: CGFloat = -0.5

    var body: some View {
        // 渐变扫描条（高度为圆直径的 20%）
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.green.opacity(0),
                        Color.green.opacity(0.25),
                        Color.green.opacity(0.08),
                        Color.green.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: circleSize, height: circleSize)
            .mask(
                // 用矩形 mask 实现扫描条效果，再被外层 clipShape 圆裁剪
                Rectangle()
                    .frame(height: circleSize * 0.2)
                    .offset(y: offset * circleSize * 0.5)
            )
            .clipShape(Circle())
            .frame(width: circleSize, height: circleSize)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = 0.5
                }
            }
    }
}

// MARK: - Preview

#Preview("扫描中") {
    CashierFaceIDView(viewModel: .preview(step: .faceIDScanning))
}

#Preview("识别失败") {
    let vm = CashierInViewModel.preview(step: .faceIDFailed)
    CashierFaceIDView(viewModel: vm)
}
