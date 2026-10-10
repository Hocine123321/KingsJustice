import SwiftUI

struct MenuModeEntry {
    let id: String
    let name: String
    let desc: String
}

/// Two main modes get big cards; the rest are compact extras.
enum MenuModeCatalog {
    static let main: [MenuModeEntry] = [
        MenuModeEntry(id: "duel", name: "Trial by Combat", desc: "Fight seven champions across six battlefields. The King waits at the end."),
        MenuModeEntry(id: "survival", name: "Survival", desc: "Endless waves. Every kill restores a little health. How long can you stand?")
    ]

    static let extras: [MenuModeEntry] = [
        MenuModeEntry(id: "rush", name: "Boss Rush", desc: "Every champion back to back. One health bar."),
        MenuModeEntry(id: "daily", name: "Daily Challenge", desc: "One seeded fight per day. Beat your best."),
        MenuModeEntry(id: "training", name: "Training Yard", desc: "No damage dealt or taken. Practice every move.")
    ]
}

struct ExtraModeRow: View {
    let title: String
    let detail: String
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: {
            UIAudio.onFirstUserTap()
            UIAudio.triggerHaptic("tap")
            action()
        }) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(UITheme.textCreamBright)
                    Text(detail)
                        .font(.system(size: 10))
                        .foregroundColor(UITheme.textCream.opacity(0.75))
                        .lineLimit(1)
                }
                Spacer()
                if let b = badge {
                    Text(b.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(UITheme.textGold)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 8).fill(UITheme.bgCard))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(UITheme.borderCream, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(DriftButtonStyle())
    }
}

struct MainMenuView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onSelectMode: (String) -> Void
    let onSelectStyle: () -> Void
    let onSelectShop: () -> Void
    let onSelectSettings: () -> Void
    let onWatchCinematic: () -> Void
    @State private var appeared: Bool = false
    @Environment(\.verticalSizeClass) private var vSize
    
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
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: Date())
    }
    
    private func badgeForMode(_ id: String) -> String? {
        if id == "survival", engine.save.bestSurvival > 0 {
            return "BEST \(engine.save.bestSurvival) WAVES"
        }
        if id == "daily" {
            var parts: [String] = []
            if let bestDaily = engine.save.bestDaily[todayString], bestDaily > 0 {
                parts.append("BEST \(bestDaily)")
            }
            // Only show a streak that is still alive (won today or yesterday).
            let live = engine.save.lastDailyWin == todayString || engine.save.lastDailyWin == DailyModifiers.previousDay(of: todayString)
            if live && engine.save.dailyStreak > 0 {
                parts.append("STREAK \(engine.save.dailyStreak)")
            }
            return parts.isEmpty ? nil : parts.joined(separator: " · ")
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            TitleBackdropView(fadeStart: 0.30, fadeEnd: 0.62)
                .opacity(vSize == .compact ? 0.28 : 1.0)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: "A Medieval Duel", title: "The King's Justice")
                        .padding(.top, 16)
                        .opacity(appeared ? 1.0 : 0.0)
                        .scaleEffect(appeared ? 1.0 : 1.05)
                        .animation(.easeOut(duration: 0.7), value: appeared)
                    
                    VStack(spacing: 10) {
                        ForEach(MenuModeCatalog.main, id: \.id) { mode in
                            MenuCard(
                                title: mode.name,
                                description: mode.desc,
                                badgeText: badgeForMode(mode.id),
                                action: { onSelectMode(mode.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .opacity(appeared ? 1.0 : 0.0)
                    .offset(y: appeared ? 0.0 : 22.0)
                    .animation(.easeOut(duration: 0.55).delay(0.2), value: appeared)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("EXTRAS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(3.0)
                            .foregroundColor(UITheme.textCream.opacity(0.6))
                            .padding(.leading, 4)
                        ForEach(MenuModeCatalog.extras, id: \.id) { mode in
                            ExtraModeRow(
                                title: mode.name,
                                detail: mode.id == "daily" ? "Today: \(DailyModifiers.forDate(todayString).name). \(DailyModifiers.forDate(todayString).desc)" : mode.desc,
                                badge: badgeForMode(mode.id),
                                action: { onSelectMode(mode.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .opacity(appeared ? 1.0 : 0.0)
                    .offset(y: appeared ? 0.0 : 22.0)
                    .animation(.easeOut(duration: 0.55).delay(0.35), value: appeared)

                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            PillButton(title: "Fighting Style", action: onSelectStyle)
                            PillButton(title: "Tonics", action: onSelectShop)
                        }
                        
                        HStack(spacing: 8) {
                            PillButton(title: "How to Play", action: onWatchCinematic)
                            PillButton(title: "Settings", action: onSelectSettings)
                        }
                    }
                    .padding(.top, 8)
                    .opacity(appeared ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.55).delay(0.5), value: appeared)
                    
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
        .onAppear { appeared = true }
    }
}
