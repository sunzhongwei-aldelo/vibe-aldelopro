import SwiftUI

// MARK: - Environment Keys

private struct AldeloButtonLoadingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct AldeloButtonDisabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var aldeloButtonLoading: Bool {
        get { self[AldeloButtonLoadingKey.self] }
        set { self[AldeloButtonLoadingKey.self] = newValue }
    }

    var aldeloButtonDisabled: Bool {
        get { self[AldeloButtonDisabledKey.self] }
        set { self[AldeloButtonDisabledKey.self] = newValue }
    }
}

// MARK: - Button Style

enum AldeloButtonStyle {
    case primary
    case secondary
    case grayStroke
    case blueStroke
    case warning
}

// MARK: - Button Size

enum AldeloButtonSize {
    case large
    case medium
    case small

    var height: CGFloat {
        switch self {
        case .large: return 54
        case .medium: return 48
        case .small: return 40
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .large: return 12
        case .medium: return 12
        case .small: return 8
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .large: return 24
        case .medium: return 20
        case .small: return 20
        }
    }
}

// MARK: - AldeloButton

struct AldeloButton: View {
    let title: String
    let style: AldeloButtonStyle
    let size: AldeloButtonSize
    let icon: Image?
    let action: () -> Void

    @Environment(\.aldeloButtonLoading) private var isLoading
    @Environment(\.aldeloButtonDisabled) private var isDisabled

    init(
        title: String,
        style: AldeloButtonStyle = .primary,
        size: AldeloButtonSize = .large,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    loadingIndicator
                } else if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity, minHeight: size.height, maxHeight: size.height)
            .background(backgroundColor)
            .overlay(strokeOverlay)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(AldeloButtonPressStyle(isPressed: $isPressed))
    }

    // MARK: - Loading Indicator

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: iconColor))
            .scaleEffect(0.8)
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if isDisabled {
            return Color.buttonDisableBackground
        }
        switch style {
        case .primary:
            return isPressed ? Color(hex: "006AD9") : Color.buttonPrimaryBackground
        case .secondary:
            return isPressed ? Color.black.opacity(0.1) : Color.secondaryButtonBackground
        case .grayStroke:
            return isPressed ? Color.black.opacity(0.02) : Color.strokeButtonBackground
        case .blueStroke:
            return isPressed ? Color.black.opacity(0.02) : Color.white
        case .warning:
            return isPressed ? Color(hex: "BF302F") : Color(hex: "FF403F")
        }
    }

    @ViewBuilder
    private var strokeOverlay: some View {
        switch style {
        case .primary, .secondary, .warning:
            EmptyView()
        case .grayStroke:
            if !isDisabled {
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(Color(.strokeButtonStroke), lineWidth: 1)
            }
        case .blueStroke:
            if !isDisabled {
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(Color(hex: "007CFF"), lineWidth: 1)
            }
        }
    }

    private var textColor: Color {
        if isDisabled {
            return .buttonDisableText
        }
        switch style {
        case .primary:
            return .buttonPrimaryText
        case .secondary:
            return .secondaryButtonText
        case .grayStroke:
            return .strokeButtonText
        case .blueStroke:
            return .textButtonText
        case .warning:
            return .white
        }
    }

    private var iconColor: Color {
        textColor
    }
}

// MARK: - Press Style

private struct AldeloButtonPressStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// Color(hex:) is defined in DesignTokens.swift

// MARK: - View Modifiers

extension View {
    func aldeloLoading(_ isLoading: Bool) -> some View {
        environment(\.aldeloButtonLoading, isLoading)
    }

    func aldeloDisabled(_ isDisabled: Bool) -> some View {
        environment(\.aldeloButtonDisabled, isDisabled)
    }
}

// MARK: - Preview

#Preview("All Styles - Large") {
    VStack(spacing: 16) {
        AldeloButton(title: "Button", style: .primary, size: .large) {}
        AldeloButton(title: "Button", style: .secondary, size: .large) {}
        AldeloButton(title: "Button", style: .grayStroke, size: .large) {}
        AldeloButton(title: "Button", style: .blueStroke, size: .large) {}
        AldeloButton(title: "Button", style: .warning, size: .large) {}
        AldeloButton(title: "Pay", style: .primary, icon: Image(systemName: "arrow.right")) {
            
        }
        .frame(width: 200)
    }
    .padding(24)
}

#Preview("Sizes") {
    VStack(spacing: 16) {
        AldeloButton(title: "Button", style: .primary, size: .large) {}
            .frame(width: 200)
        AldeloButton(title: "Button", style: .primary, size: .medium) {}
            .frame(width: 200)
        AldeloButton(title: "Button", style: .primary, size: .small) {}
            .frame(width: 200)
    }
    .padding(24)
}

#Preview("States") {
    VStack(spacing: 16) {
        AldeloButton(title: "Default", style: .primary) {}
        AldeloButton(title: "Loading", style: .primary) {}
            .aldeloDisabled(true)
        AldeloButton(title: "Disabled", style: .warning) {}
            .aldeloLoading(true)
        AldeloButton(title: "Loading", style: .grayStroke) {}
            .aldeloDisabled(true)
        AldeloButton(title: "Disabled", style: .warning) {}
            .aldeloDisabled(true)
    }
    .padding(24)
}
