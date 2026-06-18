import SwiftUI

// MARK: - Design Tokens for Aldelo POS Pro
// Source: Figma "Aldelo Pro Design System"
// Font: PingFang SC (苹方)

// MARK: - Colors

struct AppColors {
    // MARK: Primary
    static let primaryLight = Color(hex: "#e6f2ff")
    static let primaryLightActive = Color(hex: "#b0d6ff")
    static let primaryNormal = Color(hex: "#007cff")
    static let primaryNormalActive = Color(hex: "#0063cc")
    static let primaryDark = Color(hex: "#005dbf")
    static let primaryDarkActive = Color(hex: "#003873")
    static let primaryDarker = Color(hex: "#002b59")

    // MARK: Error
    static let errorLight = Color(hex: "#ffecec")
    static let errorLightActive = Color(hex: "#ffc4c3")
    static let errorNormal = Color(hex: "#ff403f")
    static let errorNormalActive = Color(hex: "#cc3332")
    static let errorDark = Color(hex: "#bf302f")
    static let errorDarkActive = Color(hex: "#731d1c")
    static let errorDarker = Color(hex: "#591616")

    // MARK: Success
    static let successLight = Color(hex: "#ecf4e8")
    static let successLightActive = Color(hex: "#c3deb6")
    static let successNormal = Color(hex: "#3e9314")
    static let successNormalActive = Color(hex: "#327610")
    static let successDark = Color(hex: "#2f6e0f")
    static let successDarkActive = Color(hex: "#1c4209")
    static let successDarker = Color(hex: "#163307")

    // MARK: Warning
    static let warningLight = Color(hex: "#fff7ec")
    static let warningLightActive = Color(hex: "#ffe7c3")
    static let warningNormal = Color(hex: "#ffb33f")
    static let warningNormalActive = Color(hex: "#cc8f32")
    static let warningDark = Color(hex: "#bf862f")
    static let warningDarkActive = Color(hex: "#73511c")
    static let warningDarker = Color(hex: "#593f16")

    // MARK: Information (same as Primary)
    static let infoLight = Color(hex: "#e6f2ff")
    static let infoNormal = Color(hex: "#007cff")
    static let infoDark = Color(hex: "#005dbf")
    static let infoSelectedBg = Color(hex: "#007CFF")

    // MARK: Role Badge (employee job-title indicators)
    static let roleWaiter = Color(hex: "#007cff")
    static let roleCashier = Color(hex: "#ffb33f")
    static let roleManager = Color(hex: "#42cece")

    // MARK: Global (Dark Mode via Asset Catalog)
    static let pageBg = Color("PageBg")
    static let pageBgDeep = Color("PageBgDeep")
    static let card = Color("Card")
    static let line = Color("Line")
    static let glass = Color("Glass")
    static let theme = Color(hex: "#007cff")
    static let mask = Color("Mask")

    // MARK: Text (Dark Mode via Asset Catalog)
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    static let textEmphasis = Color("TextEmphasis")
    static let textMuted = Color("TextMuted")

    // MARK: Neutral
    static let white100 = Color.white
    static let white80 = Color.white.opacity(0.8)
    static let white60 = Color.white.opacity(0.6)
    static let white40 = Color.white.opacity(0.4)
    static let white20 = Color.white.opacity(0.2)
    static let white8 = Color.white.opacity(0.08)
    static let black8 = Color.black.opacity(0.08)
    static let black20 = Color.black.opacity(0.2)
    static let black40 = Color.black.opacity(0.4)
    static let black60 = Color.black.opacity(0.6)
    static let black80 = Color.black.opacity(0.8)
    static let black100 = Color.black
    static let black12 = Color.black.opacity(0.12)
    
    static let black_100 = Color("Black100")

    // MARK: Industry
    static let industryRestaurant = Color(hex: "#ff6a01")
    static let industryRetail = Color(hex: "#13c2c2")
    static let industryServices = Color(hex: "#a0d911")

    // MARK: Input (Dark Mode via Asset Catalog)
    static let inputBg = Color("InputBg")
    static let inputDisabledBg = Color("InputDisabledBg")
    static let inputFocusBorder = Color("InputFocusBorder")
    static let inputErrorBorder = Color("InputErrorBorder")
    static let inputTitle = Color("InputTitle")
    static let inputPlaceholder = Color("InputPlaceholder")
    static let inputText = Color("InputText")
    static let inputError = Color("InputError")
    static let inputSuccess = Color("InputSuccess")

    // MARK: Status (Dark Mode via Asset Catalog)
    static let statusPending = Color("StatusPending")
    static let statusReserved = Color("StatusReserved")
    static let statusDining = Color("StatusDining")
    static let statusAlert = Color("StatusAlert")

    // MARK: Option (Dark Mode via Asset Catalog)
    static let optionSelectedStroke = Color(hex: "#007cff")
    static let optionSelectedFill = Color("OptionSelectedFill")
    static let optionUnselectedStroke = Color("OptionUnselectedStroke")
    static let optionUnselectedFill = Color("OptionUnselectedFill")

    // MARK: Toggle
    static let toggleOffBg = Color(hex: "#cfcfcf")
    static let toggleOnBg = Color(hex: "#007cff")
    static let toggleNob = Color.white

    // MARK: Dialog (Dark Mode via Asset Catalog)
    static let dialogAiBg = Color("DialogAiBg")
    static let dialogUserBg = Color("DialogUserBg")
    static let dialogStroke = Color("DialogStroke")
    static let dialogText = Color("DialogText")

    // MARK: Button (Dark Mode via Asset Catalog)
    static let buttonPrimaryBg = Color(hex: "#007cff")
    static let buttonPrimaryText = Color.white
    static let buttonDisabledBg = Color("ButtonDisabledBg")
    static let buttonDisabledText = Color.white
    static let buttonTextBg = Color("ButtonTextBg")
    static let buttonTextColor = Color(hex: "#007cff")
    static let buttonStrokeLine = Color("ButtonStrokeLine")
    static let buttonStrokeBg = Color("ButtonStrokeBg")
    static let buttonStrokeText = Color("ButtonStrokeText")
    static let buttonSecondaryBg = Color("ButtonSecondaryBg")
    static let buttonSecondaryText = Color("ButtonSecondaryText")

    // MARK: Numpad
    static let numpadPanelBg = Color(hex: "#4f535b")

    // MARK: Cover Badge (dark scrim over image thumbnails)
    static let coverBadgeBg = Color(hex: "#4f535b").opacity(0.5)

    // MARK: Image Placeholder (menu item thumbnail empty state)
    static let imagePlaceholderBg = Color(hex: "#f6f9fe")
    static let imagePlaceholderStroke = Color(hex: "#f1f6fd")

    // MARK: Order Type Icons
    static let orderTypeDineIn = Color(hex: "#ff6a01")
    static let orderTypeTakeOut = Color(hex: "#135cc2")
    static let orderTypeBar = Color(hex: "#a0d911")
    static let orderTypeDelivery = Color(hex: "#ffc919")
    static let orderTypeRetail = Color(hex: "#13c2c2")
    static let orderTypeDriveThru = Color(hex: "#ff4343")

    // MARK: Progress
    static let progressTrack = Color(hex: "#ebebeb")

    // MARK: Segment
    static let segmentBg = Color(hex: "#E5EAF4")

    // MARK: AI Assistant (Voice Search Gradient — 固定品牌渐变, 无 Dark Mode 差异)
    static let aiGradientStart = Color(hex: "#b1e5f2")
    static let aiGradientMid = Color(hex: "#e9fbef")
    static let aiGradientEnd = Color(hex: "#f5f8d4")
    static let aiSearchGradient = LinearGradient(
        colors: [aiGradientStart, aiGradientMid, aiGradientEnd],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )

    // MARK: Charts (Dark Mode via Asset Catalog)
    static let chartThemePrimary = Color("ChartThemePrimary")
    static let chartThemeSecondary = Color("ChartThemeSecondary")
    static let chartCat1 = Color("ChartCat1")
    static let chartCat2 = Color("ChartCat2")
    static let chartCat3 = Color("ChartCat3")
    static let chartCat4 = Color("ChartCat4")
    static let chartCat5 = Color("ChartCat5")
    static let chartCat6 = Color("ChartCat6")
    static let chartCat7 = Color(hex: "#ec407a")
    static let chartCat8 = Color(hex: "#a3d900")
}

// MARK: - Typography
// Rule: Design px × 0.75 = iOS pt (all sizes below are pt values)

struct AppFont {
  /// 全局字号缩放因子：渲染 pt = 设计稿 px × scale
    static let scale: CGFloat = 0.9

  // MARK: Tablet
    static let tabletDisplay1Medium: Font = .custom("PingFang SC", size: 64*scale).weight(.medium)
    static let tabletDisplay1Regular: Font = .custom("PingFang SC", size: 64*scale).weight(.regular)
    static let tabletDisplay2Semibold: Font = .custom("PingFang SC", size: 58*scale).weight(.semibold)
    static let tabletDisplay3Semibold: Font = .custom("PingFang SC", size: 48*scale).weight(.semibold)
    static let tabletDisplay3Medium: Font = .custom("PingFang SC", size: 48*scale).weight(.medium)
    static let tabletDisplay3Regular: Font = .custom("PingFang SC", size: 48*scale).weight(.regular)
    static let tabletDisplay4Semibold: Font = .custom("PingFang SC", size: 44*scale).weight(.semibold)
    static let tabletDisplay5Semibold: Font = .custom("PingFang SC", size: 40*scale).weight(.semibold)
    static let tabletDisplay6Medium: Font = .custom("PingFang SC", size: 36*scale).weight(.medium)
    static let tabletDisplay6Regular: Font = .custom("PingFang SC", size: 36*scale).weight(.regular)
    static let tabletDisplay7Medium: Font = .custom("PingFang SC", size: 32*scale).weight(.medium)
    static let tabletH1Medium: Font = .custom("PingFang SC", size: 32*scale).weight(.medium)
    static let tabletH2Medium: Font = .custom("PingFang SC", size: 28*scale).weight(.medium)
    static let tabletH3Medium: Font = .custom("PingFang SC", size: 24*scale).weight(.medium)
    static let tabletH4Medium: Font = .custom("PingFang SC", size: 20*scale).weight(.medium)
    static let tabletH5Medium: Font = .custom("PingFang SC", size: 18*scale).weight(.medium)
    static let tabletH5Regular: Font = .custom("PingFang SC", size: 18*scale).weight(.regular)
    static let tabletH6Medium: Font = .custom("PingFang SC", size: 16*scale).weight(.medium)
    static let tabletButton1Semibold: Font = .custom("PingFang SC", size: 36*scale).weight(.semibold)
    static let tabletButton2Medium: Font = .custom("PingFang SC", size: 28*scale).weight(.medium)
    static let tabletButton3Medium: Font = .custom("PingFang SC", size: 24*scale).weight(.medium)
    static let tabletButton3Regular: Font = .custom("PingFang SC", size: 24*scale).weight(.regular)
    static let tabletButton4Medium: Font = .custom("PingFang SC", size: 20*scale).weight(.medium)
    static let tabletBody1Regular: Font = .custom("PingFang SC", size: 28*scale).weight(.regular)
    static let tabletBody2Regular: Font = .custom("PingFang SC", size: 24*scale).weight(.regular)
    static let tabletBody2_5Regular: Font = .custom("PingFang SC", size: 26*scale).weight(.regular)
    static let tabletBody3Regular: Font = .custom("PingFang SC", size: 20*scale).weight(.regular)
    static let tabletBody4Regular: Font = .custom("PingFang SC", size: 18*scale).weight(.regular)
    static let tabletBody5Regular: Font = .custom("PingFang SC", size: 16*scale).weight(.regular)
    static let tabletCaption1Regular: Font = .custom("PingFang SC", size: 14*scale).weight(.regular)
    static let tabletCaption2Regular: Font = .custom("PingFang SC", size: 12*scale).weight(.regular)
    
    // MARK: Mobile
    static let mobileDisplay1Medium: Font = .custom("PingFang SC", size: 20*scale).weight(.medium)
    static let mobileDisplay2Medium: Font = .custom("PingFang SC", size: 18*scale).weight(.medium)
    static let mobileDisplay3Medium: Font = .custom("PingFang SC", size: 16*scale).weight(.medium)
    static let mobileDisplay3Regular: Font = .custom("PingFang SC", size: 16*scale).weight(.regular)
    static let mobileH1Medium: Font = .custom("PingFang SC", size: 20*scale).weight(.medium)
    static let mobileH2Medium: Font = .custom("PingFang SC", size: 18*scale).weight(.medium)
    static let mobileH3Medium: Font = .custom("PingFang SC", size: 16*scale).weight(.medium)
    static let mobileButton1Medium: Font = .custom("PingFang SC", size: 18*scale).weight(.medium)
    static let mobileButton2Medium: Font = .custom("PingFang SC", size: 16*scale).weight(.medium)
    static let mobileButton3Medium: Font = .custom("PingFang SC", size: 14*scale).weight(.medium)
    static let mobileBody1Medium: Font = .custom("PingFang SC", size: 14*scale).weight(.medium)
    static let mobileBody1Regular: Font = .custom("PingFang SC", size: 14*scale).weight(.regular)
    static let mobileBody2Medium: Font = .custom("PingFang SC", size: 12*scale).weight(.medium)
    static let mobileBody2Regular: Font = .custom("PingFang SC", size: 12*scale).weight(.regular)
    static let mobileCaption1Regular: Font = .custom("PingFang SC", size: 12*scale).weight(.regular)
    static let mobileCaption2Regular: Font = .custom("PingFang SC", size: 10*scale).weight(.regular)

}

// MARK: - Line Height (pt values, for use with .lineSpacing())
// Rule: Design px × 0.75 = iOS pt

struct AppLineHeight {
    // MARK: Tablet
    static let tabletDisplay1Medium: CGFloat = 54
    static let tabletDisplay1Regular: CGFloat = 54
    static let tabletDisplay2Semibold: CGFloat = 48
    static let tabletDisplay3Semibold: CGFloat = 42
    static let tabletDisplay3Medium: CGFloat = 42
    static let tabletDisplay3Regular: CGFloat = 42
    static let tabletDisplay4Semibold: CGFloat = 39
    static let tabletDisplay5Semibold: CGFloat = 36
    static let tabletDisplay6Medium: CGFloat = 33
    static let tabletDisplay6Regular: CGFloat = 33
    static let tabletDisplay7Medium: CGFloat = 30
    static let tabletH1Medium: CGFloat = 30
    static let tabletH2Medium: CGFloat = 27
    static let tabletH3Medium: CGFloat = 24
    static let tabletH4Medium: CGFloat = 21
    static let tabletH5Medium: CGFloat = 19.5
    static let tabletH6Medium: CGFloat = 18
    static let tabletButton1Semibold: CGFloat = 33
    static let tabletButton2Medium: CGFloat = 27
    static let tabletButton3Medium: CGFloat = 24
    static let tabletButton4Medium: CGFloat = 21
    static let tabletBody1Regular: CGFloat = 27
    static let tabletBody2Regular: CGFloat = 24
    static let tabletBody2_5Regular: CGFloat = 26
    static let tabletBody3Regular: CGFloat = 21
    static let tabletBody4Regular: CGFloat = 19.5
    static let tabletBody5Regular: CGFloat = 18
    static let tabletCaption1Regular: CGFloat = 16.5
    static let tabletCaption2Regular: CGFloat = 10.5

    // MARK: Mobile
    static let mobileDisplay1Medium: CGFloat = 21
    static let mobileDisplay2Medium: CGFloat = 19.5
    static let mobileDisplay3Medium: CGFloat = 18
    static let mobileDisplay3Regular: CGFloat = 18
    static let mobileH1Medium: CGFloat = 21
    static let mobileH2Medium: CGFloat = 19.5
    static let mobileH3Medium: CGFloat = 18
    static let mobileButton1Medium: CGFloat = 19.5
    static let mobileButton2Medium: CGFloat = 18
    static let mobileButton3Medium: CGFloat = 16.5
    static let mobileBody1Medium: CGFloat = 16.5
    static let mobileBody1Regular: CGFloat = 16.5
    static let mobileBody2Medium: CGFloat = 15
    static let mobileBody2Regular: CGFloat = 15
    static let mobileCaption1Regular: CGFloat = 10.5
    static let mobileCaption2Regular: CGFloat = 9

}

// MARK: - Spacing

struct Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
    static let xxxxl: CGFloat = 56
    static let xxxxxl: CGFloat = 64
    static let xxxxxxl: CGFloat = 72
    static let xxxxxxxl: CGFloat = 80
    static let xx100: CGFloat = 100
    static let xx166: CGFloat = 166
}

// MARK: - Border Radius

struct AppRadius {
    // Tablet
    struct Tablet {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 32
        static let full: CGFloat = 9999
    }

    // Mobile
    struct Mobile {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let full: CGFloat = 9999
    }

    /// Nested corner radius rule: inner = outer - 4
    static func nested(outer: CGFloat) -> CGFloat {
        max(0, outer - 4)
    }
}

// MARK: - Grid System

struct AppGrid {
    static let margin: CGFloat = 16
    static let gutter: CGFloat = 12

    struct Tablet {
        static let columns = 12
        static let columnsPortrait = 8
    }

    struct Mobile {
        static let columns = 5
    }

    static let orderDetailWidth: CGFloat = 501
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
// MARK: - Control Height

/// 控件高度统一缩放。高度值不可枚举（各 UI 高度不同），故不建命名 token，
/// 改用「设计稿 px → 全局 scale 缩放」的函数式收口。
///
/// 缩放因子由环境 `\.controlHeightScale` 提供（根部 `.provideControlHeightScale()` 注入）：
/// - 大屏 iPad（12.9"/13"，窗口短边 ≥ 1024pt）→ 1.0（不缩放）
/// - 其它设备 → `AppControl.defaultScale`（0.85）
enum AppControl {
    /// 默认控件高度缩放因子（非大屏 iPad）
    static let defaultScale: CGFloat = 0.85
    /// 大屏 iPad 不缩放
    static let largeIPadScale: CGFloat = 1.0
    /// 判定大屏 iPad 的窗口短边阈值（pt）。12.9"/13" iPad 短边 1024、11" 仅 834，
    /// 中间空当大；取 950 居中分隔（距 834 有 116pt、距 1024 有 74pt，两端都留足余量）。
    static let largeIPadMinSide: CGFloat = 950
    /// 判定大屏 iPad 的长边阈值（pt）：12.9" 长边 1366、11" 仅 1194，取 1300 双保险。
    static let largeIPadMinLong: CGFloat = 1300
    /// 最小可点尺寸（Apple HIG）
    static let minTouch: CGFloat = 44
    
    /// 按窗口尺寸判定是否大屏 iPad（短边 ≥ 900 或 长边 ≥ 1300）。
    static func isLargeIPad(size: CGSize) -> Bool {
        let shortSide = min(size.width, size.height)
        //       let longSide = max(size.width, size.height)
        return shortSide >= largeIPadMinSide // || longSide >= largeIPadMinLong
    }
    
    /// 设计稿高度 px → 实际渲染高度（× scale，可选 44pt 兜底）。
    /// 供需要 CGFloat 的场景使用（如组件的 `height:` 参数）。
    /// ⚠️ `scale` 无默认值，必须显式传入：调用方从 `@Environment(\.controlHeightScale)` 读出后传入，
    ///    例如 `AppControl.height(64, scale: controlHeightScale)`。
    ///    禁止裸调用 `AppControl.height(64)`-—否则拿不到环境 scale（含大屏 iPad=1.0），会静默退化为 0.85。
    static func height(_ designPx: CGFloat, scale: CGFloat, enforceMinTouch: Bool = true) -> CGFloat {
        let h = designPx * scale
        return enforceMinTouch ? max(h, minTouch) : h
    }
}

// MARK: - Control Height Scale Environment

private struct ControlHeightScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = AppControl.defaultScale
}

extension EnvironmentValues {
    /// 当前控件高度缩放因子（由 `.provideControlHeightScale()` 注入）
    var controlHeightScale: CGFloat {
        get { self[ControlHeightScaleKey.self] }
        set { self[ControlHeightScaleKey.self] = newValue }
    }
}

private struct ControlHeightScaleProvider: ViewModifier {
    /// Debug 诊断：屏幕左下角显示实测窗口尺寸与判定结果（仅 DEBUG 构建生效，Release 自动剔除）
    var showDiagnostic: Bool = false
    @State private var scale: CGFloat = AppControl.defaultScale
    @State private var measured: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .environment(\.controlHeightScale, scale)
        // 背景层量「全窗口」尺寸：不包裹 content、不改其布局（顶栏不会被顶进状态栏）。
        // ignoresSafeArea 让背景铺满窗口，geo.size 即真实窗口尺寸。
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onAppear { apply(geo.size) }
                        .onChange(of: geo.size) { _, newSize in apply(newSize) }
                }
                .ignoresSafeArea()
            }
            .overlay(alignment: .bottomLeading) { diagnosticOverlay }
    }
    
    /// Debug 诊断条：仅 DEBUG 构建编译进二进制，Release 构建整段剔除（返回 EmptyView）。
    @ViewBuilder
    private var diagnosticOverlay: some View {
#if DEBUG
        if showDiagnostic {
            Text(String(format: "win %.0f×%.0f  large=%@  scale=%.2f",
                        measured.width, measured.height,
                        AppControl.isLargeIPad(size: measured) ? "Y" : "N", scale))
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(6)
            .background(Color.black.opacity(0.7))
            .allowsHitTesting(false)
        }
#endif
    }
    
    /// 旋转 / 分屏导致窗口尺寸变化时重算缩放（onAppear/onChange 在布局之外触发，改 state 安全）。
    private func apply(_ size: CGSize) {
        measured = size
        let newScale = AppControl.isLargeIPad(size: size) ? AppControl.largeIPadScale : AppControl.defaultScale
        if newScale != scale { scale = newScale }
    }
}

extension View {
    /// 在 App 根部挂一次：按窗口尺寸判定大屏 iPad（短边≥900 或 长边≥1300 → 不缩放），
    /// 注入 `\.controlHeightScale`。旋转 / 分屏改变窗口尺寸时自动重算，下游全部刷新。
    /// - Parameter diagnostic: 为 true 时在屏幕左下角显示实测窗口尺寸与判定（调试用）。
    func provideControlHeightScale(diagnostic: Bool = false) -> some View {
        modifier(ControlHeightScaleProvider(showDiagnostic: diagnostic))
    }
    
    /// 按设计稿高度设置控件高度，自动读取环境 `\.controlHeightScale`（含 44pt 兜底）。
    /// - Parameters:
    ///   - designPx: 设计稿量到的原始高度 px（直接填，无需手算缩放）
    ///   - enforceMinTouch: 是否兜底 44pt 最小可点尺寸，默认 true
    /// 用法：`.controlHeight(64)` → frame(height: max(64*scale, 44))
    func controlHeight(_ designPx: CGFloat, enforceMinTouch: Bool = true) -> some View {
        modifier(ControlHeightModifier(designPx: designPx, enforceMinTouch: enforceMinTouch))
    }
}

/// `.controlHeight()` 的实现：读环境 scale 后设高度
private struct ControlHeightModifier: ViewModifier {
    let designPx: CGFloat
    let enforceMinTouch: Bool
    @Environment(\.controlHeightScale) private var scale
    
    func body(content: Content) -> some View {
        content.frame(height: AppControl.height(designPx, scale: scale, enforceMinTouch: enforceMinTouch))
    }
}
