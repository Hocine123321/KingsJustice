import SwiftUI

/// Custom button style that preserves presses even if finger drifts slightly.
struct DriftButtonStyle: ButtonStyle {
    init() {}
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? 0.2 : 0.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Standard medieval pill button with tracked uppercase text.
struct PillButton: View {
    let title: String
    let action: () -> Void
    var isPrimary: Bool = false
    var isDisabled: Bool = false
    
    init(title: String, isPrimary: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isPrimary = isPrimary
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            UIAudio.onFirstUserTap()
            UIAudio.triggerHaptic("tap")
            action()
        }) {
            Text(L10n.t(title).uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(2.5)
                .foregroundColor(isDisabled ? UITheme.textMuted : (isPrimary ? .white : UITheme.textCream))
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    Capsule()
                        .fill(isDisabled ? UITheme.bgNearBlack.opacity(0.5) : (isPrimary ? UITheme.bloodRed : UITheme.bgPanel))
                )
                .overlay(
                    Capsule()
                        .stroke(isDisabled ? UITheme.borderCream.opacity(0.1) : (isPrimary ? UITheme.brightRed : UITheme.borderCream), lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(DriftButtonStyle())
        .disabled(isDisabled)
    }
}

/// Reusable card component for game modes, fighting styles, and roster champions.
struct MenuCard: View {
    let title: String
    let description: String
    var specialText: String? = nil
    var badgeText: String? = nil
    var isSelected: Bool = false
    var isLocked: Bool = false
    var art: ModeArtKind? = nil
    var accent: Color? = nil
    let action: () -> Void
    
    @State private var glow: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    init(
        title: String,
        description: String,
        specialText: String? = nil,
        badgeText: String? = nil,
        isSelected: Bool = false,
        isLocked: Bool = false,
        art: ModeArtKind? = nil,
        accent: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.specialText = specialText
        self.badgeText = badgeText
        self.isSelected = isSelected
        self.isLocked = isLocked
        self.art = art
        self.accent = accent
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isLocked else { return }
            UIAudio.onFirstUserTap()
            UIAudio.triggerHaptic("tap")
            action()
        }) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(L10n.t(title).uppercased())
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(1.5)
                            .foregroundColor(isSelected ? .white : UITheme.textCreamBright)
                    
                        Spacer()
                    
                        if let badge = badgeText {
                            Text(L10n.t(badge).uppercased())
                                .font(.system(size: 9, weight: .bold))
                                .tracking(2.0)
                                .foregroundColor(UITheme.textGold)
                        }
                    }
                
                    Text(L10n.t(description))
                        .font(.system(size: 11))
                        .foregroundColor(UITheme.textCream.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                
                    if let special = specialText {
                        Text(special)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(UITheme.textGold)
                            .padding(.top, 2)
                    }
                }
                if let kind = art {
                    ModeArtView(kind: kind, tint: accent ?? UITheme.textGold)
                        .frame(width: 46, height: 46)
                        .opacity(glow ? 1.0 : 0.72)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? UITheme.bgCardSelected : UITheme.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? UITheme.borderSelected : (accent?.opacity(glow ? 0.65 : 0.35) ?? UITheme.borderCream), lineWidth: 1)
            )
            .shadow(color: (accent ?? .clear).opacity(glow ? 0.28 : 0.10), radius: glow ? 10 : 5)
            .opacity(isLocked ? 0.4 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(CardPressStyle(accent: accent))
        .disabled(isLocked)
        .onAppear {
            guard accent != nil, !reduceMotion else { glow = true; return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { glow = true }
        }
    }
}

/// Press feedback for big cards: a quick spring squeeze and a brighter, tighter glow.
struct CardPressStyle: ButtonStyle {
    var accent: Color? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1.0)
            .brightness(configuration.isPressed ? 0.10 : 0.0)
            .shadow(color: (accent ?? .clear).opacity(configuration.isPressed ? 0.55 : 0.0), radius: 14)
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: configuration.isPressed)
    }
}

/// Which emblem a mode card shows.
enum ModeArtKind: Equatable {
    case duel
    case survival
}

/// Crossed blades with small crossguards (Trial by Combat).
struct CrossedBladesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let a0 = CGPoint(x: rect.minX + w * 0.14, y: rect.maxY - h * 0.14)
        let a1 = CGPoint(x: rect.maxX - w * 0.14, y: rect.minY + h * 0.14)
        let b0 = CGPoint(x: rect.maxX - w * 0.14, y: rect.maxY - h * 0.14)
        let b1 = CGPoint(x: rect.minX + w * 0.14, y: rect.minY + h * 0.14)
        p.move(to: a0); p.addLine(to: a1)
        p.move(to: b0); p.addLine(to: b1)
        // Crossguards sit a quarter of the way up each blade, perpendicular to it.
        let g: CGFloat = min(w, h) * 0.17
        let ga = CGPoint(x: a0.x + (a1.x - a0.x) * 0.26, y: a0.y + (a1.y - a0.y) * 0.26)
        p.move(to: CGPoint(x: ga.x - g, y: ga.y - g)); p.addLine(to: CGPoint(x: ga.x + g, y: ga.y + g))
        let gb = CGPoint(x: b0.x + (b1.x - b0.x) * 0.26, y: b0.y + (b1.y - b0.y) * 0.26)
        p.move(to: CGPoint(x: gb.x - g, y: gb.y + g)); p.addLine(to: CGPoint(x: gb.x + g, y: gb.y - g))
        return p
    }
}

/// Three stacked chevrons, a rising wave (Survival).
struct RisingWavesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        for i in 0..<3 {
            let y = rect.minY + h * (0.40 + 0.22 * CGFloat(i))
            p.move(to: CGPoint(x: rect.minX + w * 0.14, y: y))
            p.addLine(to: CGPoint(x: rect.midX, y: y - h * 0.26))
            p.addLine(to: CGPoint(x: rect.maxX - w * 0.14, y: y))
        }
        return p
    }
}

/// Small vector emblem for a mode card.
struct ModeArtView: View {
    let kind: ModeArtKind
    var tint: Color = UITheme.textGold
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [tint.opacity(0.22), tint.opacity(0.0)], center: .center, startRadius: 2, endRadius: 28))
            switch kind {
            case .duel:
                CrossedBladesShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
            case .survival:
                RisingWavesShape()
                    .stroke(tint, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
            }
        }
        .accessibilityHidden(true)
    }
}

/// Instant touch-down action pad for fight controls (multi-touch reliable, min 85pt hit target).
struct TouchPadButton: View {
    let title: String
    let colorHex: String
    let action: () -> Void
    var minHeight: CGFloat = 85.0
    /// New players get clearer outlines; they fade back once the player has a few wins.
    var hint: Bool = false
    
    @State private var isPressed: Bool = false
    
    init(title: String, colorHex: String, minHeight: CGFloat = 85.0, hint: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.colorHex = colorHex
        self.minHeight = minHeight
        self.hint = hint
        self.action = action
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isPressed ? Color(hex: colorHex).opacity(0.6) : Color(hex: "#0e0a08").opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: colorHex).opacity(isPressed ? 0.9 : (hint ? 0.7 : 0.30)), lineWidth: 1.5)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeOut(duration: 0.06), value: isPressed)
            
            Text(L10n.t(title).uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(Color(hex: colorHex).opacity(isPressed ? 1.0 : (hint ? 0.95 : 0.5)))
        }
        .frame(minHeight: minHeight)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        UIAudio.onFirstUserTap()
                        action()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

/// Instant touch-down circular action button for Focus / Potion.
struct CircularActionButton: View {
    let title: String
    var badgeText: String? = nil
    var fillFraction: Double = 0.0
    var isReady: Bool = false
    let colorHex: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(
        title: String,
        badgeText: String? = nil,
        fillFraction: Double = 0.0,
        isReady: Bool = false,
        colorHex: String,
        size: CGFloat = 68.0,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.badgeText = badgeText
        self.fillFraction = fillFraction
        self.isReady = isReady
        self.colorHex = colorHex
        self.size = size
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#0e0a08").opacity(0.4))
            
            if fillFraction > 0 {
                GeometryReader { geo in
                    VStack {
                        Spacer(minLength: 0)
                        Rectangle()
                            .fill(Color(hex: colorHex).opacity(0.4))
                            .frame(height: geo.size.height * CGFloat(min(max(fillFraction, 0.0), 1.0)))
                    }
                }
                .clipShape(Circle())
            }
            
            Circle()
                .stroke(Color(hex: colorHex), lineWidth: isReady ? 3 : 2)
                .shadow(color: isReady ? Color(hex: colorHex).opacity(0.8) : .clear, radius: isReady ? 10 : 0)
            
            VStack(spacing: 2) {
                Text(L10n.t(title).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Color(hex: colorHex))
                
                if let badge = badgeText {
                    Text(L10n.t(badge))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.easeOut(duration: 0.06), value: isPressed)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        UIAudio.onFirstUserTap()
                        action()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

/// Standard header title kick element.
struct HeaderKickView: View {
    let kick: String
    let title: String
    
    init(kick: String, title: String) {
        self.kick = kick
        self.title = title
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(L10n.t(kick).uppercased())
                .font(UITheme.kickFont)
                .tracking(4.0)
                .foregroundColor(UITheme.textMuted)
            
            Text(L10n.t(title))
                .font(UITheme.titleFont)
                .foregroundColor(UITheme.textCreamBright)
                .shadow(color: UITheme.bloodRed.opacity(0.55), radius: 14)
        }
    }
}
