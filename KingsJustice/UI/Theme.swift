import SwiftUI

enum UITheme {
    static let bgNearBlack: Color = Color(hex: "#0e0a08")
    static let bgPanel: Color = Color(hex: "#140e0c").opacity(0.85)
    static let bgCard: Color = Color(hex: "#140e0c").opacity(0.7)
    static let bgCardSelected: Color = Color(hex: "#461010").opacity(0.7)
    
    static let textCream: Color = Color(hex: "#cdbfa6")
    static let textCreamBright: Color = Color(hex: "#e6dcc9")
    static let textMuted: Color = Color(hex: "#7d725f")
    static let textGold: Color = Color(hex: "#d9b45a")
    
    static let bloodRed: Color = Color(hex: "#8a0f0f")
    static let brightRed: Color = Color(hex: "#c23a2a")
    static let borderCream: Color = Color(hex: "#cdbfa6").opacity(0.28)
    static let borderSelected: Color = Color(hex: "#dc786e").opacity(0.7)
    
    static var titleFont: Font {
        .system(size: 32, weight: .regular, design: .serif).italic()
    }
    
    static var sectionFont: Font {
        .system(size: 22, weight: .regular, design: .serif).italic()
    }
    
    static var kickFont: Font {
        .system(size: 11, weight: .semibold, design: .default)
    }
    
    static var bodyFont: Font {
        .system(size: 12, weight: .regular, design: .default)
    }
}

struct BackgroundGradientView: View {
    init() {}
    
    var body: some View {
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
