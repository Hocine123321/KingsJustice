import SwiftUI

struct PauseView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onSelectSettings: () -> Void
    
    init(engine: Engine, onSelectSettings: @escaping () -> Void) {
        self.engine = engine
        self.onSelectSettings = onSelectSettings
    }
    
    var body: some View {
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
