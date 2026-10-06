import SwiftUI

public struct PauseView<Engine: UIEngine>: View {
    @ObservedObject public var engine: Engine
    public let onSelectSettings: () -> Void
    
    public init(engine: Engine, onSelectSettings: @escaping () -> Void) {
        self.engine = engine
        self.onSelectSettings = onSelectSettings
    }
    
    public var body: some View {
        ZStack {
            UITheme.bgNearBlack.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HeaderKickView(kick: "Paused", title: "The Blades Wait")
                
                VStack(spacing: 12) {
                    PillButton(title: "Resume", isPrimary: true, action: {
                        engine.resume()
                    })
                    
                    PillButton(title: "Settings", action: {
                        onSelectSettings()
                    })
                    
                    PillButton(title: "Quit to Menu", action: {
                        engine.quitToMenu()
                    })
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(UITheme.bgPanel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(UITheme.borderCream, lineWidth: 1)
            )
            .padding(24)
        }
    }
}
