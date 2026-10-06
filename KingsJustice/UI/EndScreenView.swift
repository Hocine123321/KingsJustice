import SwiftUI

struct EndScreenView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onNext: () -> Void
    let onRetry: () -> Void
    let onShop: () -> Void
    let onMainMenu: () -> Void
    
    init(
        engine: Engine,
        onNext: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onShop: @escaping () -> Void,
        onMainMenu: @escaping () -> Void
    ) {
        self.engine = engine
        self.onNext = onNext
        self.onRetry = onRetry
        self.onShop = onShop
        self.onMainMenu = onMainMenu
    }
    
    private var titleText: String {
        if engine.won {
            if engine.enemyName == "The King" || engine.enemyName.contains("King") {
                return "The King Falls"
            }
            return "\(engine.enemyName) Falls"
        } else {
            return "Justice Is Served"
        }
    }
    
    private var subtitleText: String {
        if engine.won {
            return "Trial by Combat Won"
        } else {
            return "You Have Been Judged"
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            VStack(spacing: 20) {
                HeaderKickView(kick: subtitleText, title: titleText)
                
                // Stats Card
                VStack(spacing: 12) {
                    HStack(spacing: 24) {
                        statBox(label: "SCORE", value: "\(engine.score)")
                        statBox(label: "BEST COMBO", value: "\(engine.combo)")
                    }
                    
                    HStack(spacing: 24) {
                        statBox(label: "GOLD EARNED", value: "+\(engine.won ? 50 : 0)")
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(UITheme.bgCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(UITheme.borderCream, lineWidth: 1)
                )
                
                // Action Buttons
                VStack(spacing: 10) {
                    if engine.won {
                        PillButton(title: "Next Champion", isPrimary: true, action: onNext)
                    } else {
                        PillButton(title: "Fight Again", isPrimary: true, action: onRetry)
                    }
                    
                    HStack(spacing: 12) {
                        PillButton(title: "Tonics", action: onShop)
                        PillButton(title: "Main Menu", action: onMainMenu)
                    }
                }
            }
            .padding(24)
        }
    }
    
    private func statBox(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2.0)
                .foregroundColor(UITheme.textMuted)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(UITheme.textCreamBright)
        }
        .frame(maxWidth: .infinity)
    }
}
