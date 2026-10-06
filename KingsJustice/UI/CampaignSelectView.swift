import SwiftUI

public struct CampaignSelectView<Engine: UIEngine>: View {
    @ObservedObject public var engine: Engine
    public let onSelectOpponent: (Int) -> Void
    public let onBack: () -> Void
    
    public init(engine: Engine, onSelectOpponent: @escaping (Int) -> Void, onBack: @escaping () -> Void) {
        self.engine = engine
        self.onSelectOpponent = onSelectOpponent
        self.onBack = onBack
    }
    
    private var maxUnlockedIndex: Int {
        min(GameData.roster.count - 1, engine.save.beat.count)
    }
    
    public var body: some View {
        ZStack {
            BackgroundGradientView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "Trial by Combat", title: "Choose Your Opponent")
                        .padding(.top, 16)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<GameData.roster.count, id: \.self) { index in
                            let enemy = GameData.roster[index]
                            let isLocked = index > maxUnlockedIndex
                            let isBeaten = engine.save.beat.contains(enemy.id)
                            
                            MenuCard(
                                title: enemy.name,
                                description: "\(enemy.title) • Arena: \(enemy.arena.capitalized)",
                                badgeText: isBeaten ? "SLAIN" : (isLocked ? "LOCKED" : nil),
                                isLocked: isLocked,
                                action: { onSelectOpponent(index) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    PillButton(title: "Back", action: onBack)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}
