import SwiftUI

struct FightHudView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    var tauntOverlayText: String?
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var activeTaunt: String? = nil
    
    init(engine: Engine, tauntOverlayText: String? = nil) {
        self.engine = engine
        self.tauntOverlayText = tauntOverlayText
    }
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top HUD Bar (single slim row)
                topHudBar
                    .padding(.horizontal, isLandscape ? 14 : 16)
                    .padding(.top, isLandscape ? 4 : 8)

                Spacer(minLength: 0)

                // Bottom controls: hugging the screen edges so the arena stays visible
                bottomDockControls
                    .padding(.horizontal, isLandscape ? 10 : 16)
                    .padding(.bottom, isLandscape ? 6 : 12)
            }

            FightIntroView(engine: engine)

            // Center Judge Popup
            if !engine.judgeText.isEmpty {
                judgePopupView
            }

            // Tip toast: top, under the HUD
            if let tip = engine.tipText, !tip.isEmpty {
                tipToastView(text: tip)
            }

            // Taunt bubble overlay: top, below HUD (stacked relative to tip toast)
            if let taunt = activeTaunt, !taunt.isEmpty {
                tauntToastView(text: taunt)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .task(id: tauntOverlayText) {
            guard let text = tauntOverlayText, !text.isEmpty else {
                activeTaunt = nil
                return
            }
            activeTaunt = text
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            if !Task.isCancelled {
                activeTaunt = nil
            }
        }
    }

    // MARK: - Top HUD
    private var topHudBar: some View {
        HStack(alignment: .center, spacing: 10) {
            // Player HP
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("YOU")
                    Spacer(minLength: 4)
                    Text("\(engine.score)")
                        .foregroundColor(UITheme.textGold)
                }
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(UITheme.textCream)

                hpBar(current: engine.hp, max: engine.maxhp, color: (engine.maxhp > 0 && engine.hp / engine.maxhp < 0.3) ? Color(hex: "#c0392b") : Color(hex: "#4a8a5a"))
            }
            .frame(maxWidth: .infinity)

            // Pause Button
            Button(action: {
                UIAudio.onFirstUserTap()
                UIAudio.triggerHaptic("tap")
                engine.pause()
            }) {
                Text("II")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(UITheme.textCreamBright)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(UITheme.bgPanel))
                    .overlay(Circle().stroke(UITheme.borderCream, lineWidth: 1))
            }
            .buttonStyle(DriftButtonStyle())

            // Enemy HP
            VStack(alignment: .trailing, spacing: 2) {
                HStack {
                    Spacer(minLength: 4)
                    Text(engine.enemyName.uppercased())
                        .lineLimit(1)
                }
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(UITheme.textCream)

                hpBar(current: engine.khp, max: engine.kmax, color: UITheme.bloodRed)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(alignment: .bottom) {
            if engine.combo > 1 {
                Text("\(engine.combo)x COMBO")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(UITheme.textGold)
                    .offset(y: 14)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#140e0c").opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(UITheme.borderCream.opacity(0.15), lineWidth: 1)
        )
    }

    private func hpBar(current: Double, max maxVal: Double, color: Color) -> some View {
        let fillFraction = maxVal > 0 ? min(max(current / maxVal, 0.0), 1.0) : 0.0
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.6))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(fillFraction))
            }
        }
        .frame(height: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(UITheme.borderCream.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Center Judge, Tip & Taunt Popups
    private var judgePopupView: some View {
        VStack {
            Text(engine.judgeText)
                .font(.system(size: 30, weight: .bold, design: .serif).italic())
                .tracking(3.0)
                .foregroundColor(Color(hex: engine.judgeColorHex))
                .shadow(color: Color.black.opacity(0.95), radius: 2, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.8), radius: 6)
                .shadow(color: Color(hex: engine.judgeColorHex).opacity(0.6), radius: 12)
                .id(engine.judgeStamp)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeOut(duration: 0.25), value: engine.judgeStamp)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 52)
        .allowsHitTesting(false)
    }
    
    private func tipToastView(text: String) -> some View {
        VStack {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(UITheme.textCreamBright)
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(
                    Capsule().fill(Color(hex: "#140e0c").opacity(0.7))
                )
                .overlay(
                    Capsule().stroke(UITheme.textGold.opacity(0.5), lineWidth: 1)
                )
                .padding(.top, isLandscape ? 46 : 100)

            Spacer()
        }
        .allowsHitTesting(false)
    }

    private func tauntToastView(text: String) -> some View {
        let hasTip = engine.tipText != nil && !(engine.tipText?.isEmpty ?? true)
        let baseTopPadding: CGFloat = isLandscape ? 44 : 52
        let tipOffset: CGFloat = isLandscape ? 38 : 46
        let topPadding = hasTip ? ((isLandscape ? 46 : 100) + tipOffset) : baseTopPadding

        return VStack {
            TauntBubbleView(speaker: engine.enemyName, text: text)
                .padding(.top, topPadding)
                .transition(.move(edge: .top).combined(with: .opacity))

            Spacer()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Bottom Dock Controls
    private var bottomDockControls: some View {
        let isLeftHand = engine.settings.leftHand
        let padH: CGFloat = isLandscape ? 54 : 90

        return HStack(alignment: .bottom, spacing: 0) {
            if engine.roundIsDefend {
                if isLeftHand {
                    parryCluster(h: padH * 1.6)
                    Spacer(minLength: 0)
                    actionButtons
                    evadeCluster(h: padH * 0.8)
                } else {
                    evadeCluster(h: padH * 0.8)
                    actionButtons
                    Spacer(minLength: 0)
                    parryCluster(h: padH * 1.6)
                }
            } else {
                attackControls(h: padH)
            }
        }
    }

    // Heal / Focus sit in the middle of the dock, tucked between the pad groups
    private var actionButtons: some View {
        HStack(spacing: 8) {
            CircularActionButton(
                title: "Heal",
                badgeText: "\(engine.potionCount)",
                colorHex: "#8fd0a0",
                size: isLandscape ? 46 : 58,
                action: { engine.drinkPotion() }
            )
            CircularActionButton(
                title: "Focus",
                fillFraction: engine.focus / 100.0,
                isReady: engine.focus >= 100.0,
                colorHex: "#9fd0ff",
                size: isLandscape ? 52 : 68,
                action: { engine.useFocus() }
            )
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 2)
    }

    // Attack Pads Layout (3 Lanes), compact and low
    private func attackControls(h: CGFloat) -> some View {
        HStack(spacing: 8) {
            TouchPadButton(title: "Slash", colorHex: "#d9b45a", minHeight: h) {
                engine.input(kind: "lane", lane: 0)
            }
            TouchPadButton(title: "Thrust", colorHex: "#c8d4e0", minHeight: h) {
                engine.input(kind: "lane", lane: 1)
            }
            TouchPadButton(title: "Overhead", colorHex: "#c23a2a", minHeight: h) {
                engine.input(kind: "lane", lane: 2)
            }
        }
    }

    private func evadeCluster(h: CGFloat) -> some View {
        VStack(spacing: 6) {
            TouchPadButton(title: "Jump", colorHex: "#8fc4a0", minHeight: h) {
                engine.input(kind: "jump", lane: 0)
            }
            HStack(spacing: 6) {
                TouchPadButton(title: "Dodge", colorHex: "#ff9a8a", minHeight: h) {
                    engine.input(kind: "dodge", lane: 0)
                }
                TouchPadButton(title: "Duck", colorHex: "#f1d98e", minHeight: h) {
                    engine.input(kind: "duck", lane: 0)
                }
            }
        }
        .frame(maxWidth: isLandscape ? 300 : .infinity)
    }

    private func parryCluster(h: CGFloat) -> some View {
        TouchPadButton(title: "Parry", colorHex: "#c8d4e0", minHeight: h) {
            engine.input(kind: "parry", lane: 0)
        }
        .frame(maxWidth: isLandscape ? 220 : .infinity)
    }
}
