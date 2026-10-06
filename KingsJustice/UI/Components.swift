import SwiftUI

/// Custom button style that preserves presses even if finger drifts slightly.
public struct DriftButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? 0.2 : 0.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Standard medieval pill button with tracked uppercase text.
public struct PillButton: View {
    public let title: String
    public let action: () -> Void
    public var isPrimary: Bool = false
    public var isDisabled: Bool = false
    
    public init(title: String, isPrimary: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isPrimary = isPrimary
        self.isDisabled = isDisabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            UIAudio.onFirstUserTap()
            UIAudio.triggerHaptic("tap")
            action()
        }) {
            Text(title.uppercased())
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
public struct MenuCard: View {
    public let title: String
    public let description: String
    public var specialText: String? = nil
    public var badgeText: String? = nil
    public var isSelected: Bool = false
    public var isLocked: Bool = false
    public let action: () -> Void
    
    public init(
        title: String,
        description: String,
        specialText: String? = nil,
        badgeText: String? = nil,
        isSelected: Bool = false,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.specialText = specialText
        self.badgeText = badgeText
        self.isSelected = isSelected
        self.isLocked = isLocked
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard !isLocked else { return }
            UIAudio.onFirstUserTap()
            UIAudio.triggerHaptic("tap")
            action()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(title.uppercased())
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(1.5)
                        .foregroundColor(isSelected ? .white : UITheme.textCreamBright)
                    
                    Spacer()
                    
                    if let badge = badgeText {
                        Text(badge.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(2.0)
                            .foregroundColor(UITheme.textGold)
                    }
                }
                
                Text(description)
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
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? UITheme.bgCardSelected : UITheme.bgCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? UITheme.borderSelected : UITheme.borderCream, lineWidth: 1)
            )
            .opacity(isLocked ? 0.4 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(DriftButtonStyle())
        .disabled(isLocked)
    }
}

/// Instant touch-down action pad for fight controls (multi-touch reliable, min 85pt hit target).
public struct TouchPadButton: View {
    public let title: String
    public let colorHex: String
    public let action: () -> Void
    public var minHeight: CGFloat = 85.0
    
    @State private var isPressed: Bool = false
    
    public init(title: String, colorHex: String, minHeight: CGFloat = 85.0, action: @escaping () -> Void) {
        self.title = title
        self.colorHex = colorHex
        self.minHeight = minHeight
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isPressed ? Color(hex: colorHex).opacity(0.6) : Color(hex: "#0e0a08").opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: colorHex), lineWidth: 2)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeOut(duration: 0.06), value: isPressed)
            
            Text(title.uppercased())
                .font(.system(size: 13, weight: .bold))
                .tracking(2.0)
                .foregroundColor(Color(hex: colorHex))
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
public struct CircularActionButton: View {
    public let title: String
    public var badgeText: String? = nil
    public var fillFraction: Double = 0.0
    public var isReady: Bool = false
    public let colorHex: String
    public let size: CGFloat
    public let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    public init(
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
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#0e0a08").opacity(0.6))
            
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
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(Color(hex: colorHex))
                
                if let badge = badgeText {
                    Text(badge)
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
public struct HeaderKickView: View {
    public let kick: String
    public let title: String
    
    public init(kick: String, title: String) {
        self.kick = kick
        self.title = title
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Text(kick.uppercased())
                .font(UITheme.kickFont)
                .tracking(4.0)
                .foregroundColor(UITheme.textMuted)
            
            Text(title)
                .font(UITheme.titleFont)
                .foregroundColor(UITheme.textCreamBright)
                .shadow(color: UITheme.bloodRed.opacity(0.55), radius: 14)
        }
    }
}
