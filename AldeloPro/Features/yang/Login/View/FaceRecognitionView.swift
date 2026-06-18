import SwiftUI
import AVFoundation
import Combine

// MARK: - Face Recognition View

struct FaceRecognitionView: View {
    @ObservedObject var viewModel: ClockInOutViewModel
    @State private var scanProgress: CGFloat = 0
    @State private var dotsCount: Int = 0

    private let frameSize: CGFloat = 335
    private let innerSize: CGFloat = 315
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            titleSection
                .padding(.top, 40)

            hintSection
                .padding(.top, 16)

            cameraFrame
                .padding(.top, 32)

            Spacer()

            if viewModel.faceState == .failed {
                rescanButton
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            if viewModel.faceState == .idle {
                viewModel.startFaceRecognition()
            }
        }
        .onReceive(timer) { _ in
            if viewModel.faceState == .recognizing {
                dotsCount = (dotsCount + 1) % 4
            }
        }
    }

    // MARK: - Title (dots animation during recognizing)

    private var titleSection: some View {
        Text(titleText)
            .font(AppFont.tabletDisplay7Medium)
            .foregroundColor(Color(hex: "#262626"))
    }

    private var titleText: String {
        switch viewModel.faceState {
        case .idle:
            return "Face Recognition"
        case .recognizing:
            let dots = String(repeating: ".", count: dotsCount)
            return "Recognizing\(dots)"
        case .failed:
            return "Unable To Recognize"
        }
    }

    // MARK: - Hint

    private var hintSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryNormal)
            Text(hintText)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(Color(hex: "#595959"))
        }
    }

    private var hintText: String {
        switch viewModel.faceState {
        case .idle, .recognizing:
            return "Please Face The Camera And Align Your Face Within The Frame"
        case .failed:
            return "Please Try Face Recognition Again Or Use Passcode"
        }
    }

    // MARK: - Camera Frame

    private var cameraFrame: some View {
        ZStack {
            // Outer border ring
            Circle()
                .stroke(AppColors.primaryLight, lineWidth: 6)
                .frame(width: frameSize, height: frameSize)

            // Camera preview fills full inner circle (no white area)
            CameraPreviewViewClockIn()
                .frame(width: innerSize, height: innerSize)
                .clipShape(Circle())

            // Scanning overlay + line (only during recognizing)
            if viewModel.faceState == .recognizing {
                scanningOverlay
                animatedScanLine
                
            }
        }
        .frame(width: frameSize, height: frameSize)
    }

    // MARK: - Scanning overlay (below scan line, gradient cyan)

    private var scanningOverlay: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#7EF6FF").opacity(0.25),
                            Color(hex: "#7EF6FF").opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: innerSize * (1 - scanProgress))
        }
        .frame(width: innerSize, height: innerSize)
        .clipShape(Circle())
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                scanProgress = 1.0
            }
        }
    }

    // MARK: - Animated scan line (follows overlay bottom edge)

    private var animatedScanLine: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#44F2FF").opacity(0),
                        Color(hex: "#44F2FF").opacity(0.9),
                        Color(hex: "#44F2FF").opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: innerSize - 20, height: 3)
            .offset(y: innerSize * (scanProgress - 0.5))
    }

    // MARK: - Rescan Button

    private var rescanButton: some View {
        Button {
            scanProgress = 0
            viewModel.rescan()
        } label: {
            Text("Rescan")
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.primaryNormal)
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color.white)
                .cornerRadius(AppRadius.Tablet.lg)
        }
        .padding(.horizontal, 80)
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewViewClockIn: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraUIView {
        CameraUIView()
    }

    func updateUIView(_ uiView: CameraUIView, context: Context) {}
}

class CameraUIView: UIView {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCamera()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .medium

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        layer.addSublayer(preview)

        captureSession = session
        previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    deinit {
        captureSession?.stopRunning()
    }
}
