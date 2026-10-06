import SwiftUI

public struct FightHudView<Engine: UIEngine>: View {
    @ObservedObject public var engine: Engine
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public init(engine: Engine) {
        self.engine = engine
    }
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top HUD Bar
                topHudBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                Spacer()
                
                // Bottom Dock Controls
                bottomDockControls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            
            // Center Judge Popup
            if !engine.judgeText.isEmpty {
                judgePopupView
            }
            
            // Center Tip Toast
            if let tip = engine.tipText, !tip.isEmpty {
                tipToastView(text: tip)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
    
    // MARK: - Top HUD
    private var topHudBar: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                // Player HP
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOU")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(UITheme.textCream)
                    
                    hpBar(current: engine.hp, max: engine.maxhp, color: Color(hex: "#4a8a5a"))
                }
                .frame(maxWidth: .infinity)
                
                // Pause Button
                Button(action: {
                    UIAudio.onFirstUserTap()
                    UIAudio.triggerHaptic("tap")
                    engine.pause()
                }) {
                    Text("II")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(UITheme.textCreamBright)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(UITheme.bgPanel))
                        .overlay(Circle().stroke(UITheme.borderCream, lineWidth: 1))
                }
                .buttonStyle(DriftButtonStyle())
                
                // Enemy HP
                VStack(alignment: .trailing, spacing: 4) {
                    Text(engine.enemyName.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(UITheme.textCream)
                        .lineLimit(1)
                    
                    hpBar(current: engine.khp, max: engine.kmax, color: UITheme.bloodRed)
                }
                .frame(maxWidth: .infinity)
            }
            
            // HUD Stats Row
            HStack(spacing: 16) {
                Text("SCORE \(engine.score)")
                Spacer()
                if engine.combo > 1 {
                    Text("\(engine.combo)x COMBO")
                        .foregroundColor(UITheme.textGold)
                }
                Spacer()
                Text("GOLD \(engine.gold)")
            }
            .font(.system(size: 10, weight: .bold))
            .tracking(1.5)
            .foregroundColor(UITheme.textCream)
            .padding(.horizontal, 8)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(UITheme.bgPanel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(UITheme.borderCream.opacity(0.2), lineWidth: 1)
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
        .frame(height: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(UITheme.borderCream.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Center Judge & Tip Popups
    private var judgePopupView: some View {
        VStack {
            Text(engine.judgeText)
                .font(.system(size: 38, weight: .bold, design: .serif).italic())
                .tracking(3.0)
                .foregroundColor(Color(hex: engine.judgeColorHex))
                .shadow(color: Color(hex: engine.judgeColorHex).opacity(0.8), radius: 12)
                .id(engine.judgeStamp)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeOut(duration: 0.25), value: engine.judgeStamp)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .allowsHitTesting(false)
    }
    
    private func tipToastView(text: String) -> some View {
        VStack {
            Spacer()
            
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(UITheme.textCreamBright)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(UITheme.bgPanel)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(UITheme.textGold.opacity(0.6), lineWidth: 1)
                )
                .padding(.bottom, 220)
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Bottom Dock Controls
    private var bottomDockControls: some View {
        VStack(spacing: 12) {
            // Action Buttons (Focus & Potion)
            HStack {
                Spacer()
                
                CircularActionButton(
                    title: "Heal",
                    badgeText: "\(engine.potionCount)",
                    colorHex: "#8fd0a0",
                    size: 58,
                    action: { engine.drinkPotion() }
                )
                
                CircularActionButton(
                    title: "Focus",
                    fillFraction: engine.focus / 100.0,
                    isReady: engine.focus >= 100.0,
                    colorHex: "#9fd0ff",
                    size: 68,
                    action: { engine.useFocus() }
                )
            }
            .padding(.horizontal, 8)
            
            // Main Pad Controls: Attack (3 lanes) vs Defend (4 buttons)
            if engine.roundIsDefend {
                defendControls
            } else {
                attackControls
            }
        }
    }
    
    // Attack Pads Layout (3 Lanes)
    private var attackControls: some View {
        HStack(spacing: 10) {
            TouchPadButton(title: "Slash", colorHex: "#d9b45a", minHeight: 90) {
                engine.input(kind: "lane", lane: 0)
            }
            
            TouchPadButton(title: "Thrust", colorHex: "#c8d4e0", minHeight: 90) {
                engine.input(kind: "lane", lane: 1)
            }
            
            TouchPadButton(title: "Overhead", colorHex: "#c23a2a", minHeight: 90) {
                engine.input(kind: "lane", lane: 2)
            }
        }
    }
    
    // Defend Controls Layout (Jump, Dodge, Duck + Parry) with Left-Hand Swap
    private var defendControls: some View {
        let isLeftHand = engine.settings.leftHand
        
        return HStack(spacing: 12) {
            if isLeftHand {
                parryCluster
                evadeCluster
            } else {
                evadeCluster
                parryCluster
            }
        }
    }
    
    private var evadeCluster: some View {
        VStack(spacing: 8) {
            TouchPadButton(title: "Jump", colorHex: "#8fc4a0", minHeight: 44) {
                engine.input(kind: "jump", lane: 0)
            }
            
            HStack(spacing: 8) {
                TouchPadButton(title: "Dodge", colorHex: "#ff9a8a", minHeight: 44) {
                    engine.input(kind: "dodge", lane: 0)
                }
                
                TouchPadButton(title: "Duck", colorHex: "#f1d98e", minHeight: 44) {
                    engine.input(kind: "duck", lane: 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var parryCluster: some View {
        TouchPadButton(title: "Parry", colorHex: "#c8d4e0", minHeight: 96) {
            engine.input(kind: "parry", lane: 0)
        }
        .frame(maxWidth: .infinity)
    }
}
