import SwiftUI

struct MainMenuView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onSelectMode: (String) -> Void
    let onSelectStyle: () -> Void
    let onSelectShop: () -> Void
    let onSelectSettings: () -> Void
    let onWatchCinematic: () -> Void
    
    init(
        engine: Engine,
        onSelectMode: @escaping (String) -> Void,
        onSelectStyle: @escaping () -> Void,
        onSelectShop: @escaping () -> Void,
        onSelectSettings: @escaping () -> Void,
        onWatchCinematic: @escaping () -> Void
    ) {
        self.engine = engine
        self.onSelectMode = onSelectMode
        self.onSelectStyle = onSelectStyle
        self.onSelectShop = onSelectShop
        self.onSelectSettings = onSelectSettings
        self.onWatchCinematic = onWatchCinematic
    }
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private var modesList: [(id: String, name: String, desc: String)] {
        [
            ("duel", "Trial by Combat", "Fight seven champions across six battlefields. The King waits at the end."),
            ("survival", "Survival", "Endless waves. Every kill restores a little health. How long can you stand?"),
            ("rush", "Boss Rush", "Every champion back to back. One health bar. No mercy."),
            ("daily", "Daily Challenge", "One seeded fight per day, same for everyone. Beat your own best score."),
            ("training", "Training Yard", "No damage taken or dealt. Practice every move at your own pace.")
        ]
    }
    
    private func badgeForMode(_ id: String) -> String? {
        if id == "survival", engine.save.bestSurvival > 0 {
            return "BEST \(engine.save.bestSurvival) WAVES"
        }
        if id == "daily", let bestDaily = engine.save.bestDaily[todayString], bestDaily > 0 {
            return "BEST \(bestDaily)"
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "A Medieval Duel", title: "The King's Justice")
                        .padding(.top, 16)
                    
                    VStack(spacing: 10) {
                        ForEach(modesList, id: \.id) { mode in
                            MenuCard(
                                title: mode.name,
                                description: mode.desc,
                                badgeText: badgeForMode(mode.id),
                                action: { onSelectMode(mode.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            PillButton(title: "Fighting Style", action: onSelectStyle)
                            PillButton(title: "Tonics", action: onSelectShop)
                        }
                        
                        HStack(spacing: 8) {
                            PillButton(title: "Settings", action: onSelectSettings)
                            PillButton(title: "Watch Cinematic", action: onWatchCinematic)
                        }
                    }
                    .padding(.top, 8)
                    
                    HStack(spacing: 20) {
                        Text("GOLD: \(engine.save.gold)")
                        Text("•")
                        Text("CHAMPIONS SLAIN: \(engine.save.kills)")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2.0)
                    .foregroundColor(UITheme.textCream)
                    .padding(.vertical, 12)
                }
                .padding(.bottom, 24)
            }
        }
    }
}
