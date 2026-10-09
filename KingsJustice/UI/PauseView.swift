import SwiftUI

struct PauseView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onSelectSettings: () -> Void
    
    init(engine: Engine, onSelectSettings: @escaping () -> Void) {
        self.engine = engine
        self.onSelectSettings = onSelectSettings
    }
    
    private var pauseButtons: some View {
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

    var body: some View {
        ZStack {
            UITheme.bgNearBlack.opacity(0.85)
                .ignoresSafeArea()
            
            // Short phone landscape can't fit the stacked version, so it falls back to side by side.
            ViewThatFits(in: .vertical) {
                VStack(spacing: 24) {
                    HeaderKickView(kick: "Paused", title: "The Blades Wait")
                    pauseButtons
                }
                HStack(spacing: 28) {
                    HeaderKickView(kick: "Paused", title: "The Blades Wait")
                    pauseButtons
                }
            }
            .padding(24)
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
