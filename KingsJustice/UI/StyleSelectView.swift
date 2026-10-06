import SwiftUI

struct StyleSelectView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onBack: () -> Void
    
    init(engine: Engine, onBack: @escaping () -> Void) {
        self.engine = engine
        self.onBack = onBack
    }
    
    private func unlockCostForStyle(_ id: String) -> Int? {
        if id == "duelist" { return 250 }
        if id == "berserker" { return 500 }
        return nil
    }
    
    private func isStyleUnlocked(_ id: String) -> Bool {
        if id == "knight" { return true }
        if id == "duelist" { return engine.save.unlockedDuelist }
        if id == "berserker" { return engine.save.unlockedBerserker }
        return false
    }
    
    private func selectStyle(_ id: String) {
        if isStyleUnlocked(id) {
            engine.settings.style = id
            engine.saveAll()
        } else if let cost = unlockCostForStyle(id), engine.save.gold >= cost {
            if id == "duelist" { engine.save.unlockedDuelist = true }
            if id == "berserker" { engine.save.unlockedBerserker = true }
            engine.save.gold -= cost
            engine.settings.style = id
            engine.saveAll()
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "Choose Your Way of Killing", title: "Fighting Style")
                        .padding(.top, 16)
                    
                    VStack(spacing: 12) {
                        ForEach(GameData.styles, id: \.id) { style in
                            let unlocked = isStyleUnlocked(style.id)
                            let isSelected = engine.settings.style == style.id
                            let cost = unlockCostForStyle(style.id)
                            
                            let badge: String? = isSelected ? "EQUIPPED" : (!unlocked && cost != nil ? "\(cost!) GOLD" : nil)
                            
                            MenuCard(
                                title: style.name,
                                description: style.desc,
                                specialText: "Special: \(style.special.name) — \(style.special.desc)",
                                badgeText: badge,
                                isSelected: isSelected,
                                isLocked: !unlocked && (engine.save.gold < (cost ?? 0)),
                                action: { selectStyle(style.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Text("CURRENT GOLD: \(engine.save.gold)")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(UITheme.textGold)
                        .padding(.top, 8)
                    
                    PillButton(title: "Back", action: onBack)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}
