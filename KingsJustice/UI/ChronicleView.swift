import SwiftUI

/// The player's record: stats, defeated champions and achievements.
struct ChronicleView: View {
    let save: SaveData
    let onWear: (String) -> Void
    let onBack: () -> Void
    @State private var worn: String

    init(save: SaveData, onWear: @escaping (String) -> Void = { _ in }, onBack: @escaping () -> Void) {
        self.save = save
        self.onWear = onWear
        self.onBack = onBack
        _worn = State(initialValue: save.title)
    }

    private var wornName: String? {
        guard !worn.isEmpty, unlocked.contains(worn) else { return nil }
        return Achievements.titles[worn]
    }

    private var rosterIds: [String] { return GameData.roster.map { $0.id } }
    private var unlocked: Set<String> { return Achievements.unlocked(save: save, rosterIds: rosterIds) }

    var body: some View {
        ZStack {
            BackgroundGradientView()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    HeaderKickView(kick: wornName.map { "Your Legend · " + $0 } ?? "Your Legend", title: "The Chronicle")
                        .padding(.top, 12)

                    statsCard
                    championsCard
                    achievementsCard

                    PillButton(title: "Back", isPrimary: true, action: onBack)
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func card<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.t(title).uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(3.0)
                .foregroundColor(UITheme.textGold)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(UITheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(UITheme.borderCream, lineWidth: 1))
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(L10n.t(label))
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundColor(UITheme.textCream)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(UITheme.textCreamBright)
        }
    }

    private var statsCard: some View {
        card("Deeds") {
            statRow("Champions slain", "\(save.kills)")
            statRow("Fights without a scratch", "\(save.flawless)")
            statRow("Best Survival", save.bestSurvival > 0 ? "Wave \(save.bestSurvival)" : "-")
            statRow("Best Boss Rush", save.bestRush > 0 ? "\(save.bestRush)" : "-")
            statRow("Longest Daily streak", save.bestDailyStreak > 0 ? "\(save.bestDailyStreak) days" : "-")
            statRow("Gold", "\(save.gold)")
        }
    }

    private var championsCard: some View {
        card("Champions") {
            ForEach(Array(GameData.roster.enumerated()), id: \.element.id) { _, e in
                let beaten = save.beat.contains(e.id)
                HStack {
                    Text(beaten ? e.name : "???")
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .foregroundColor(beaten ? UITheme.textCreamBright : UITheme.textCream.opacity(0.4))
                    Spacer()
                    Text(beaten ? e.title : "Undefeated")
                        .font(.system(size: 11, weight: .regular, design: .serif).italic())
                        .foregroundColor(beaten ? UITheme.textGold : UITheme.textCream.opacity(0.35))
                }
            }
        }
    }

    private func wearButton(_ id: String) -> some View {
        let isWorn = (worn == id)
        return Button(action: {
            worn = isWorn ? "" : id
            onWear(worn)
        }) {
            Group {
                if isWorn {
                    Text("Worn")
                } else {
                    Text("Wear")
                }
            }
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundColor(isWorn ? UITheme.bgNearBlack : UITheme.textCreamBright)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(isWorn ? UITheme.textGold : UITheme.bgCard))
            .overlay(Capsule().stroke(UITheme.borderCream.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(DriftButtonStyle())
    }

    private var achievementsCard: some View {
        let got = unlocked
        return card("Achievements  \(got.count)/\(Achievements.all.count)") {
            ForEach(Achievements.all) { a in
                let has = got.contains(a.id)
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(has ? UITheme.textGold : UITheme.textCream.opacity(0.18))
                        .frame(width: 9, height: 9)
                        .padding(.top, 4)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(a.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(has ? UITheme.textCreamBright : UITheme.textCream.opacity(0.5))
                        Text(a.desc)
                            .font(.system(size: 11, weight: .regular, design: .serif))
                            .foregroundColor(UITheme.textCream.opacity(has ? 0.85 : 0.4))
                        if has, let t = Achievements.titles[a.id] {
                            Text(t)
                                .font(.system(size: 11, weight: .regular, design: .serif).italic())
                                .foregroundColor(UITheme.textGold)
                        }
                    }
                    Spacer()
                    if has {
                        wearButton(a.id)
                    }
                }
            }
        }
    }
}
