//
//  ScanReceiptView.swift
//  AldeloPro
//
//  Created by AI on 2026/06/05.
//

import SwiftUI
import Combine
import AVFoundation
import Vision

// MARK: - Scan Mode

enum ScanMode: String, CaseIterable {
    case aiTipScan = "AI Tip Scan"
    case paymentQR = "Payment QR"
}

// MARK: - ScanReceiptView

struct ScanReceiptView: View {
    @StateObject private var viewModel = ScanReceiptViewModel()
    @Environment(AppUIManager.self) private var uiManager: AppUIManager?
    var onBack: () -> Void = {}
    /// Called when AI Tip Scan recognizes "ARA" or "AAA" with the current camera frame
    var onTipTextRecognized: ((UIImage) -> Void)?
    /// Called when Payment QR mode recognizes a QR code
    var onQRCodeRecognized: ((String) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            segmentedControl
                .padding(.top, Spacing.lg)
            cameraViewfinder
                .padding(.top, Spacing.lg)
            infoRow
                .padding(.top, Spacing.md)
            Spacer()
            bottomButtons
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.lg)
        .background(AppColors.white100)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .onAppear {
            viewModel.onTipTextRecognized = onTipTextRecognized
            viewModel.onQRCodeRecognized = onQRCodeRecognized
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                viewModel.startSession()
            }
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }

    // MARK: - Title

    private var titleBar: some View {
        HStack {
            Text("Scan Receipt")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                segmentButton(for: mode)
            }
        }
        .frame(height: 56)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(Color(hex: "#6B7785"), lineWidth: 1)
        )
    }

    private func segmentButton(for mode: ScanMode) -> some View {
        Button {
            viewModel.switchMode(to: mode)
        } label: {
            Text(mode.rawValue)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(viewModel.currentMode == mode ? AppColors.primaryNormal : Color(hex: "#808080"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    viewModel.currentMode == mode
                        ? AppColors.primaryLight
                        : Color.clear
                )
                .cornerRadius(AppRadius.Tablet.xs)
                .padding(Spacing.xxs)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Camera Viewfinder

    @State private var scanLineOffset: CGFloat = 0

    private var cameraViewfinder: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#91A6C2").opacity(0.15))

            // Camera preview
            ScanCameraPreviewView(previewLayer: viewModel.previewLayer)
                .clipShape(RoundedRectangle(cornerRadius: Spacing.md))

            // Animated scan line with gradient trail
            GeometryReader { geo in
                let height = geo.size.height

                VStack(spacing: 0) {
                    // Gradient trail above the scan line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#44F2FF").opacity(0),
                                    Color(hex: "#44F2FF").opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 120)

                    // Scan line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#44F2FF").opacity(0),
                                    Color(hex: "#44F2FF"),
                                    Color(hex: "#44F2FF").opacity(0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                }
                .offset(y: scanLineOffset - 120)
                .onAppear {
                    startScanAnimation(height: height)
                }
                .onChange(of: height) { _, newHeight in
                    startScanAnimation(height: newHeight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Corner brackets
            cornerBrackets
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(728.0 / 448.0, contentMode: .fit)
    }

    private func startScanAnimation(height: CGFloat) {
        scanLineOffset = 0
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
        ) {
            scanLineOffset = height
        }
    }

    private var cornerBrackets: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let bracketLen: CGFloat = 40
            let inset: CGFloat = 0

            Path { path in
                // Top-left
                path.move(to: CGPoint(x: inset + bracketLen, y: inset))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset, y: inset + bracketLen))

                // Top-right
                path.move(to: CGPoint(x: w - inset - bracketLen, y: inset))
                path.addLine(to: CGPoint(x: w - inset, y: inset))
                path.addLine(to: CGPoint(x: w - inset, y: inset + bracketLen))

                // Bottom-left
                path.move(to: CGPoint(x: inset + bracketLen, y: h - inset))
                path.addLine(to: CGPoint(x: inset, y: h - inset))
                path.addLine(to: CGPoint(x: inset, y: h - inset - bracketLen))

                // Bottom-right
                path.move(to: CGPoint(x: w - inset - bracketLen, y: h - inset))
                path.addLine(to: CGPoint(x: w - inset, y: h - inset))
                path.addLine(to: CGPoint(x: w - inset, y: h - inset - bracketLen))
            }
            .stroke(AppColors.primaryNormal, lineWidth: 5)
        }
    }

    // MARK: - Info Row

    private var infoRow: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColors.primaryNormal)
                .font(.system(size: 16))

            Text("Please Align the Receipt for Scanning")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(Color(hex: "#6B7785"))

            Spacer()

            rearCameraButton
        }
    }

    private var rearCameraButton: some View {
        Button {
            viewModel.toggleCamera()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "camera.rotate")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textPrimary)
                Text("Rear Camera")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.white100)
            .cornerRadius(AppRadius.Tablet.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        Button {
            onBack()
        } label: {
            Text("Back")
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#F8F8F8"))
                .cornerRadius(AppRadius.Tablet.lg)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

private struct ScanCameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> OrientationAwarePreviewView {
        let view = OrientationAwarePreviewView()
        if let layer = previewLayer {
            layer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(layer)
            view.previewLayer = layer
        }
        return view
    }

    func updateUIView(_ uiView: OrientationAwarePreviewView, context: Context) {
        if let layer = previewLayer {
            layer.frame = uiView.bounds
            uiView.updateConnectionOrientation()
        }
    }
}

/// UIView subclass that updates preview layer orientation on device rotation
private final class OrientationAwarePreviewView: UIView {
    weak var previewLayer: AVCaptureVideoPreviewLayer?

    var currentRotationAngle: CGFloat {
        rotationAngleForCurrentOrientation()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        updateConnectionOrientation()
    }

    @objc private func orientationDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.updateConnectionOrientation()
        }
    }

    func updateConnectionOrientation() {
        let angle = rotationAngleForCurrentOrientation()
        if let connection = previewLayer?.connection, connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }

    private func rotationAngleForCurrentOrientation() -> CGFloat {
        // Primary: use windowScene interfaceOrientation (most reliable on iPad)
//        if let scene = window?.windowScene {
//            switch scene.interfaceOrientation {
//            case .portrait:
//                return 90
//            case .portraitUpsideDown:
//                return 270
//            case .landscapeRight:
//                // Home button on right → camera native landscape → 0°
//                return 0
//            case .landscapeLeft:
//                // Home button on left → 180°
//                return 180
//            default:
//                break
//            }
//        }

        // Fallback: UIDevice orientation (for when windowScene isn't available yet)
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return 270
        case .landscapeLeft:
            // Device left side down → interface landscapeRight → 0°
            return 0
        case .landscapeRight:
            // Device right side down → interface landscapeLeft → 180°
            return 180
        default:
            return 90
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ScanReceiptViewModel: ObservableObject {
    @Published var currentMode: ScanMode = .aiTipScan
    @Published var isSessionRunning = false

    var onTipTextRecognized: ((UIImage) -> Void)?
    var onQRCodeRecognized: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.aldelo.scanreceipt.session")
    private let outputDelegate: ScanOutputDelegate
    let previewLayer: AVCaptureVideoPreviewLayer

    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var recognitionStopped = false

    init() {
        let session = captureSession
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        outputDelegate = ScanOutputDelegate()
        outputDelegate.viewModel = self
        outputDelegate.cachedMode = currentMode
    }

    func switchMode(to mode: ScanMode) {
        guard currentMode != mode else { return }
        currentMode = mode
        outputDelegate.cachedMode = mode
        recognitionStopped = false
    }

    
    func startSession() {
        guard !isSessionRunning else { return }

        // 1. 在主线程提前设置好 delegate，避免把主线程隔离的 delegate 传进后台闭包
        let outputQueue = DispatchQueue(label: "com.aldelo.scanreceipt.output")
        videoOutput.setSampleBufferDelegate(outputDelegate, queue: outputQueue)

        // 使用 nonisolated(unsafe) 绕过 session 和 output 的跨线程检查
        nonisolated(unsafe) let session = captureSession
        nonisolated(unsafe) let output = videoOutput
        let position = currentCameraPosition

        sessionQueue.async {
            session.beginConfiguration()
            session.sessionPreset = .high

            // Remove existing inputs
            session.inputs.forEach { session.removeInput($0) }

            // Add camera input
            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: position
            ) else {
                session.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            } catch {
                session.commitConfiguration()
                return
            }

            // Add video output for frame processing
            if session.outputs.isEmpty {
                output.alwaysDiscardsLateVideoFrames = true
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
            }

            // Set video output orientation to match device
            if let connection = output.connection(with: .video) {
                connection.videoRotationAngle = 90
            }

            session.commitConfiguration()
            session.startRunning()

            // 2. 现代 Swift 6 推荐使用 Task { @MainActor in } 替代 DispatchQueue.main.async
            // 这样编译器能明确知道内部代码跑在主线程上
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let connection = self.previewLayer.connection {
                    let angle = self.currentPreviewRotationAngle()
                    if connection.isVideoRotationAngleSupported(angle) {
                        connection.videoRotationAngle = angle
                    }
                }
            }
        }

        isSessionRunning = true
    }
    
//    func startSession() {
//        guard !isSessionRunning else { return }
//
//        nonisolated(unsafe) let session = captureSession
//        nonisolated(unsafe) let output = videoOutput
//        let delegate = outputDelegate
//        let position = currentCameraPosition
//
//        sessionQueue.async {
//            session.beginConfiguration()
//            session.sessionPreset = .high
//
//            // Remove existing inputs
//            session.inputs.forEach { session.removeInput($0) }
//
//            // Add camera input
//            guard let camera = AVCaptureDevice.default(
//                .builtInWideAngleCamera,
//                for: .video,
//                position: position
//            ) else {
//                session.commitConfiguration()
//                return
//            }
//
//            do {
//                let input = try AVCaptureDeviceInput(device: camera)
//                if session.canAddInput(input) {
//                    session.addInput(input)
//                }
//            } catch {
//                session.commitConfiguration()
//                return
//            }
//
//            // Add video output for frame processing
//            if session.outputs.isEmpty {
//                output.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "com.aldelo.scanreceipt.output"))
//                output.alwaysDiscardsLateVideoFrames = true
//                if session.canAddOutput(output) {
//                    session.addOutput(output)
//                }
//            }
//
//            // Set video output orientation to match device
//            if let connection = output.connection(with: .video) {
//                connection.videoRotationAngle = 90
//            }
//
//            session.commitConfiguration()
//            session.startRunning()
//
//            // Update preview layer connection orientation after session starts
//            // (connection is nil until session is running)
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                if let connection = self.previewLayer.connection {
//                    let angle = self.currentPreviewRotationAngle()
//                    if connection.isVideoRotationAngleSupported(angle) {
//                        connection.videoRotationAngle = angle
//                    }
//                }
//            }
//        }
//
//        isSessionRunning = true
//    }

    func stopSession() {
        nonisolated(unsafe) let session = captureSession
        sessionQueue.async {
            session.stopRunning()
        }
        isSessionRunning = false
    }

    private func currentPreviewRotationAngle() -> CGFloat {
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            return 90
        case .portraitUpsideDown:
            return 270
        case .landscapeLeft:
            return 0
        case .landscapeRight:
            return 180
        default:
            return 90
        }
    }

    func toggleCamera() {
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        stopSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startSession()
        }
    }

    // MARK: - Recognition Handling

    func handleRecognizedText(_ text: String, image: UIImage) {
        guard !recognitionStopped else { return }
        let uppercased = text.uppercased()
        if uppercased.contains("ARA") || uppercased.contains("AAA") {
            recognitionStopped = true
            onTipTextRecognized?(image)
        }
    }

    func handleRecognizedQR(_ payload: String) {
        guard !recognitionStopped else { return }
        recognitionStopped = true
        onQRCodeRecognized?(payload)
    }
}

// MARK: - Video Output Delegate

private nonisolated final class ScanOutputDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    weak var viewModel: ScanReceiptViewModel?
    private var isProcessing = false
    private var lastProcessTime: CFTimeInterval = 0
    private let processingInterval: CFTimeInterval = 0.5 // Process at most every 0.5s
    /// 缓存当前扫描模式：输出回调在后台串行队列直接读取它来选择识别分支，避免跳回主线程。
    var cachedMode: ScanMode = .aiTipScan
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Throttle: skip frames if processing or too soon since last process
        guard !isProcessing else { return }
        let now = CACurrentMediaTime()
        guard (now - lastProcessTime) >= processingInterval else { return }

        isProcessing = true
        lastProcessTime = now

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            isProcessing = false
            return
        }

        // 本委托在专用串行输出队列上回调，Vision 直接在此同步执行：
        // 无需跳转到主线程，非 Sendable 的 pixelBuffer 也就不会跨越任何并发边界。
        switch cachedMode {
        case .aiTipScan:
            performTextRecognition(on: pixelBuffer)
        case .paymentQR:
            performQRRecognition(on: pixelBuffer)
        }
    }

    // MARK: - Text Recognition (Vision)

    private func performTextRecognition(on pixelBuffer: CVPixelBuffer) {
        let request = VNRecognizeTextRequest { [weak self] request, error in
            defer { self?.isProcessing = false }
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let recognizedStrings = observations.compactMap {
                $0.topCandidates(1).first?.string
            }

            let fullText = recognizedStrings.joined(separator: " ")

            // Only create UIImage when text matches, to avoid expensive conversion per frame
            let needsImage = fullText.uppercased().contains("ARA") || fullText.uppercased().contains("AAA")
            guard needsImage, let self else { return }

            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            guard let cgImage = self.ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
            let uiImage = UIImage(cgImage: cgImage)

            Task { @MainActor [weak self] in
                self?.viewModel?.handleRecognizedText(fullText, image: uiImage)
            }
        }
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            isProcessing = false
        }
    }

    // MARK: - QR Code Recognition (Vision)

    private func performQRRecognition(on pixelBuffer: CVPixelBuffer) {
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            defer { self?.isProcessing = false }
            guard error == nil,
                  let observations = request.results as? [VNBarcodeObservation] else { return }

            for observation in observations {
                if observation.symbology == .qr,
                   let payload = observation.payloadStringValue {
                    Task { @MainActor [weak self] in
                        self?.viewModel?.handleRecognizedQR(payload)
                    }
                    return
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            isProcessing = false
        }
    }
}

// MARK: - Preview

#Preview {
    ScanReceiptView()
        .frame(width: 780 * 0.85, height: 896 * 0.85)
}
