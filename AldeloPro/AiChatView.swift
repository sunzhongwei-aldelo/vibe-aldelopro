import SwiftUI

// MARK: - AiChatView

struct AiChatView: View {
    @State private var isVoiceMode: Bool = false
    @State private var inputText: String = ""
    var onClose: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                
            VStack(spacing: 0) {
                headerBar
                Divider()
                chatContent
                Spacer(minLength: 0)
                hintText
                bottomBar
            }
            .frame(maxWidth: 1000, maxHeight: 900)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("AI Voice Chat")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(Color(hex: "262626"))
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .frame(height: 87)
        .background(Color.white)
    }

    // MARK: - Chat Content

    private var chatContent: some View {
        ScrollView {
            VStack(spacing: 14) {
                aiBubble(text: "Now for adding employee, please tell me employee's first and last name, as well as job title, so I can automatically add employees.")
                userBubble(text: "Jame Smith, waiter.")
                employeeInfoCard
                aiBubble(text: "If there's any problem with the information, you can let me know.")
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
        }
    }

    // MARK: - AI Message Bubble

    private func aiBubble(text: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            aiAvatar
            Text(text)
                .font(.system(size: 28))
                .foregroundColor(.black)
                .lineSpacing(8)
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(hex: "F4F8FF"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 1)
        )
    }

    // MARK: - User Message Bubble

    private func userBubble(text: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            userAvatar
            Text(text)
                .font(.system(size: 28))
                .foregroundColor(Color(hex: "262626"))
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color(hex: "DAEEFF"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 1)
        )
    }

    // MARK: - AI Avatar with Sparkle

    private var aiAvatar: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "E8E8E8"))
                .frame(width: 48, height: 48)
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundColor(.black)
        }
    }

    // MARK: - User Avatar

    private var userAvatar: some View {
        Circle()
            .fill(Color(hex: "D9D9D9"))
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
            )
    }

    // MARK: - Employee Information Card

    private var employeeInfoCard: some View {
        VStack(spacing: 16) {
            Text("Employee Information")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.black)

            HStack(spacing: 40) {
                HStack(spacing: 12) {
                    Text("Name")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "BFBFBF"))
                    Text("Jame Smith")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "262626"))
                }
                Spacer()
                HStack(spacing: 12) {
                    Text("Job Title")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "BFBFBF"))
                    Text("Waiter")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "262626"))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(hex: "F4F8FF"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 1)
        )
    }

    // MARK: - Hint Text

    private var hintText: some View {
        Text(isVoiceMode ? "You can talk naturally with AI" : "Say \"Hey Aldelo\" to talk with AI..")
            .font(.system(size: 24))
            .foregroundColor(Color(hex: "595959"))
            .padding(.bottom, 12)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        Group {
            if isVoiceMode {
                voiceBottomBar
            } else {
                typeBottomBar
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    // MARK: - State 1: Type Input Bar

    private var typeBottomBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Type to Chat with Aldelo AI...", text: $inputText)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "595959"))
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .frame(maxHeight: .infinity, alignment: .top)

            Spacer(minLength: 0)

            Button(action: {
                isVoiceMode = true
            }) {
                voiceMicButton
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 134)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "89E8FF"),
                            Color(hex: "90FFB5"),
                            Color(hex: "68F0FF"),
                            Color(hex: "9CC4FF")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    // MARK: - Voice Mic Button (State 1)

    private var voiceMicButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "mic")
                .font(.system(size: 18))
                .foregroundColor(.black)
        }
        .frame(width: 115, height: 48)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "89E8FF").opacity(0.3),
                    Color(hex: "90FFB5").opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - State 2: Voice Bottom Bar

    private var voiceBottomBar: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // Mic indicator with green dot (bottom aligned)
            HStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "mic")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "808080"))
                    Circle()
                        .fill(Color(hex: "1AE13A"))
                        .frame(width: 6, height: 6)
                        .offset(x: 4, y: -2)
                }
                Text("Voice")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "808080"))
            }
            .padding(.leading, 24)
            .padding(.bottom, 16)

            Spacer(minLength: 0)

            // Waveform visualization (top aligned)
            WaveformView()
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white, location: 0.15),
                            .init(color: .white, location: 0.85),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 16)

            Spacer(minLength: 0)

            // Keyboard button (bottom aligned)
            Button(action: {
                isVoiceMode = false
            }) {
                keyboardIcon
                    .frame(width: 115, height: 48)
                    .background(Color(hex: "F8F8F8"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 134)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    // MARK: - Keyboard Icon

    private var keyboardIcon: some View {
        Image(systemName: "keyboard")
            .font(.system(size: 20))
            .foregroundColor(.black)
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.03)) { timeline in
            Canvas { context, size in
                let midY = size.height / 2
                let width = size.width

                // Main waveform (bold)
                drawWave(
                    context: context,
                    size: size,
                    amplitude: 12,
                    frequency: 3,
                    phase: phase,
                    lineWidth: 2.75,
                    gradient: Gradient(colors: [
                        Color(hex: "ADF0FF"),
                        Color(hex: "2179FF"),
                        Color(hex: "A2FF8D")
                    ])
                )

                // Secondary waveform (thin)
                drawWave(
                    context: context,
                    size: size,
                    amplitude: 6,
                    frequency: 4,
                    phase: phase + 1.5,
                    lineWidth: 1.375,
                    gradient: Gradient(colors: [
                        Color(hex: "1ED3FB"),
                        Color(hex: "2D80FF"),
                        Color(hex: "1ED3FB")
                    ])
                )

                // Tertiary waveform (thinnest)
                drawWave(
                    context: context,
                    size: size,
                    amplitude: 4,
                    frequency: 5,
                    phase: phase + 3.0,
                    lineWidth: 1.375,
                    gradient: Gradient(colors: [
                        Color(hex: "1ED3FB"),
                        Color(hex: "2D80FF"),
                        Color(hex: "1ED3FB")
                    ])
                )

                // Glow ellipse
                let glowRect = CGRect(
                    x: width * 0.2,
                    y: midY - 8,
                    width: width * 0.6,
                    height: 16
                )
                context.opacity = 0.3
                context.fill(
                    Ellipse().path(in: glowRect),
                    with: .color(Color(hex: "A1D3FF"))
                )
                context.opacity = 1.0
            }
            .onChange(of: timeline.date) { _, _ in
                phase += 0.05
            }
        }
    }

    private func drawWave(
        context: GraphicsContext,
        size: CGSize,
        amplitude: CGFloat,
        frequency: CGFloat,
        phase: CGFloat,
        lineWidth: CGFloat,
        gradient: Gradient
    ) {
        let midY = size.height / 2
        var path = Path()
        let steps = Int(size.width)

        for x in 0...steps {
            let xPos = CGFloat(x)
            let normalizedX = xPos / size.width
            let envelope = sin(normalizedX * .pi)
            let yPos = midY + sin((normalizedX * frequency * .pi * 2) + phase) * amplitude * envelope
            if x == 0 {
                path.move(to: CGPoint(x: xPos, y: yPos))
            } else {
                path.addLine(to: CGPoint(x: xPos, y: yPos))
            }
        }

        context.stroke(
            path,
            with: .linearGradient(
                gradient,
                startPoint: CGPoint(x: 0, y: midY - amplitude),
                endPoint: CGPoint(x: 0, y: midY + amplitude)
            ),
            lineWidth: lineWidth
        )
    }
}

// Color(hex:) is defined in DesignTokens.swift

// MARK: - Preview

#Preview {
    AiChatView()
}
