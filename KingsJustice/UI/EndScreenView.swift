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

            GeometryReader { geo in
                if geo.size.width > geo.size.height {
                    landscapeLayout(r)
                } else {
                    ScrollView {
                        portraitLayout(r)
                    }
                }
            }
        }
        .onAppear { shown = true }
    }

    // MARK: - Pieces

    private func rankStamp(_ r: FightResult, size: CGFloat) -> some View {
        Text(r.rankLetter)
            .font(.system(size: size, weight: .heavy, design: .serif))
            .foregroundColor(rankColor)
            .shadow(color: rankColor.opacity(0.7), radius: 18)
            .scaleEffect(shown ? 1.0 : 2.4)
            .rotationEffect(.degrees(shown ? -6.0 : 0.0))
            .opacity(shown ? 1.0 : 0.0)
            .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.35), value: shown)
    }

    private func bestBadge(_ r: FightResult) -> some View {
        Group {
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
        }
    }

    private func tipLine(_ r: FightResult) -> some View {
        Group {
            if !engine.won && !r.tip.isEmpty {
                Text(r.tip)
                    .font(.system(size: 12, weight: .regular, design: .serif).italic())
                    .multilineTextAlignment(.center)
                    .foregroundColor(UITheme.textCream)
                    .padding(.horizontal, 8)
            }
        }
    }

    private func statsCard(_ r: FightResult, compact: Bool) -> some View {
        VStack(spacing: compact ? 8 : 12) {
            HStack(spacing: 12) {
                statBox(label: "SCORE", compact: compact) {
                    CountUpText(value: shown ? Double(r.score) : 0.0)
                        .animation(.easeOut(duration: 1.1).delay(0.5), value: shown)
                }
                statBox(label: "GOLD", compact: compact) {
                    CountUpText(value: shown ? Double(r.gold) : 0.0, prefix: "+")
                        .animation(.easeOut(duration: 1.1).delay(0.7), value: shown)
                }
                if compact {
                    statBox(label: "BEST COMBO", compact: compact) { Text("\(r.maxCombo)") }
                }
            }
            if !compact {
                HStack(spacing: 12) {
                    statBox(label: "BEST COMBO", compact: compact) { Text("\(r.maxCombo)") }
                    statBox(label: "TIME", compact: compact) { Text(timeString(r.duration)) }
                }
            }
            HStack(spacing: 12) {
                statBox(label: "PERFECT", compact: compact) { Text("\(r.perfects)") }
                statBox(label: "GOOD", compact: compact) { Text("\(r.goods)") }
                statBox(label: "MISSED", compact: compact) { Text("\(r.misses)") }
                if compact {
                    statBox(label: "TIME", compact: compact) { Text(timeString(r.duration)) }
                }
            }
        }
        .padding(compact ? 10 : 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(UITheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(UITheme.borderCream, lineWidth: 1))
        .opacity(shown ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: shown)
    }

    private var actionButtons: some View {
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

    // MARK: - Layouts

    private func portraitLayout(_ r: FightResult) -> some View {
        VStack(spacing: 14) {
            HeaderKickView(kick: subtitleText, title: titleText)
            rankStamp(r, size: 76)
            bestBadge(r)
            statsCard(r, compact: false)
            tipLine(r)
            actionButtons
        }
        .padding(20)
    }

    /// Phone landscape is short, so the result splits into two columns instead of stacking.
    private func landscapeLayout(_ r: FightResult) -> some View {
        HStack(spacing: 24) {
            VStack(spacing: 8) {
                Spacer(minLength: 0)
                HeaderKickView(kick: subtitleText, title: titleText)
                rankStamp(r, size: 64)
                bestBadge(r)
                tipLine(r)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 12) {
                Spacer(minLength: 0)
                statsCard(r, compact: true)
                actionButtons
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
    }

    private func statBox<V: View>(label: String, compact: Bool = false, @ViewBuilder value: () -> V) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2.0)
                .foregroundColor(UITheme.textMuted)

            value()
                .font(.system(size: compact ? 16 : 20, weight: .bold))
                .foregroundColor(UITheme.textCreamBright)
        }
        .frame(maxWidth: .infinity)
    }
}
