import SwiftUI

public enum UITheme {
    public static let bgNearBlack: Color = Color(hex: "#0e0a08")
    public static let bgPanel: Color = Color(hex: "#140e0c").opacity(0.85)
    public static let bgCard: Color = Color(hex: "#140e0c").opacity(0.7)
    public static let bgCardSelected: Color = Color(hex: "#461010").opacity(0.7)
    
    public static let textCream: Color = Color(hex: "#cdbfa6")
    public static let textCreamBright: Color = Color(hex: "#e6dcc9")
    public static let textMuted: Color = Color(hex: "#7d725f")
    public static let textGold: Color = Color(hex: "#d9b45a")
    
    public static let bloodRed: Color = Color(hex: "#8a0f0f")
    public static let brightRed: Color = Color(hex: "#c23a2a")
    public static let borderCream: Color = Color(hex: "#cdbfa6").opacity(0.28)
    public static let borderSelected: Color = Color(hex: "#dc786e").opacity(0.7)
    
    public static var titleFont: Font {
        .system(size: 32, weight: .regular, design: .serif).italic()
    }
    
    public static var sectionFont: Font {
        .system(size: 22, weight: .regular, design: .serif).italic()
    }
    
    public static var kickFont: Font {
        .system(size: 11, weight: .semibold, design: .default)
    }
    
    public static var bodyFont: Font {
        .system(size: 12, weight: .regular, design: .default)
    }
}

public struct BackgroundGradientView: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            UITheme.bgNearBlack
                .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#24100c").opacity(0.8),
                    Color(hex: "#060302")
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}
