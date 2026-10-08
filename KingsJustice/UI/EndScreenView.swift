import SwiftUI

/// Number that counts up smoothly when its value changes inside an animation.
struct CountUpText: View, Animatable {
    var value: Double
    var prefix: String = ""

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(prefix)\(Int(value.rounded()))")
    }
}

struct EndScreenView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    let onNext: () -> Void
    let onRetry: () -> Void
    let onShop: () -> Void
    let onMainMenu: () -> Void
    @State private var shown: Bool = false

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
            return "\(engine.enemyName) Falls"
        } else {
            return "Justice Is Served"
        }
    }

    private var subtitleText: String {
        return engine.won ? "Trial by Combat Won" : "You Have Been Judged"
    }

    private var rankColor: Color {
        switch engine.fightResult.rankLetter {
        case "S": return Color(red: 1.0, green: 0.84, blue: 0.35)
        case "A": return Color(red: 0.55, green: 0.85, blue: 0.55)
        case "B": return Color(red: 0.55, green: 0.75, blue: 1.0)
        case "C": return UITheme.textCream
        default: return UITheme.bloodRed
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        return "\(s / 60):" + (s % 60 < 10 ? "0" : "") + "\(s % 60)"
    }

    var body: some View {
        let r = engine.fightResult
        ZStack {
            BackgroundGradientView()

            VStack(spacing: 14) {
                HeaderKickView(kick: subtitleText, title: titleText)

                // Rank stamp
                Text(r.rankLetter)
                    .font(.system(size: 76, weight: .heavy, design: .serif))
                    .foregroundColor(rankColor)
                    .shadow(color: rankColor.opacity(0.7), radius: 18)
                    .scaleEffect(shown ? 1.0 : 2.4)
                    .rotationEffect(.degrees(shown ? -6.0 : 0.0))
                    .opacity(shown ? 1.0 : 0.0)
                    .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.35), value: shown)

                if r.newBest {
                    Text(r.bestLabel.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2.5)
                        .foregroundColor(UITheme.textGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(UITheme.textGold, lineWidth: 1))
                        .opacity(shown ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.4).delay(1.0), value: shown)
                }

                // Stats card
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        statBox(label: "SCORE") {
                            CountUpText(value: shown ? Double(r.score) : 0.0)
                                .animation(.easeOut(duration: 1.1).delay(0.5), value: shown)
                        }
                        statBox(label: "GOLD") {
                            CountUpText(value: shown ? Double(r.gold) : 0.0, prefix: "+")
                                .animation(.easeOut(duration: 1.1).delay(0.7), value: shown)
                        }
                    }
                    HStack(spacing: 12) {
                        statBox(label: "BEST COMBO") { Text("\(r.maxCombo)") }
                        statBox(label: "TIME") { Text(timeString(r.duration)) }
                    }
                    HStack(spacing: 12) {
                        statBox(label: "PERFECT") { Text("\(r.perfects)") }
                        statBox(label: "GOOD") { Text("\(r.goods)") }
                        statBox(label: "MISSED") { Text("\(r.misses)") }
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(UITheme.bgCard))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(UITheme.borderCream, lineWidth: 1))
                .opacity(shown ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.15), value: shown)

                if !engine.won && !r.tip.isEmpty {
                    Text(r.tip)
                        .font(.system(size: 12, weight: .regular, design: .serif).italic())
                        .multilineTextAlignment(.center)
                        .foregroundColor(UITheme.textCream)
                        .padding(.horizontal, 8)
                }

                // Action buttons
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
                .opacity(shown ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(1.2), value: shown)
            }
            .padding(20)
        }
        .onAppear { shown = true }
    }

    private func statBox<V: View>(label: String, @ViewBuilder value: () -> V) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2.0)
                .foregroundColor(UITheme.textMuted)

            value()
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(UITheme.textCreamBright)
        }
        .frame(maxWidth: .infinity)
    }
}
