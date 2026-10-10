import SwiftUI

/// Short, visual explanation of the core loop. Shown once before the first fight and any time from the menu.
struct HowToPlayView: View {
    let onDone: () -> Void
    @State private var page: Int = 0

    private struct Page {
        let kick: String
        let title: String
        let body: String
        let accent: Color
        let defend: Bool
    }

    private let pages: [Page] = [
        Page(
            kick: "Your turn",
            title: "Strike",
            body: "Notes slide down three lanes: Slash, Thrust and Overhead. Tap the lane the moment a note reaches the circle. The closer to the centre, the harder you hit.",
            accent: Color(red: 1.0, green: 0.82, blue: 0.4),
            defend: false
        ),
        Page(
            kick: "His turn",
            title: "Defend",
            body: "A ring closes on you when the champion attacks. Parry slashes, Duck low sweeps, Jump overheads. Red dashed rings cannot be parried: Dodge them.",
            accent: Color(red: 0.95, green: 0.35, blue: 0.3),
            defend: true
        ),
        Page(
            kick: "Your edge",
            title: "Focus and Heal",
            body: "Spend Focus to widen your timing for a few seconds. It never slows or weakens the enemy. Heal drinks a tonic to restore health. Chain hits to build your combo and score.",
            accent: Color(red: 0.55, green: 0.75, blue: 1.0),
            defend: false
        )
    ]

    private var current: Page { pages[min(page, pages.count - 1)] }
    private var isLast: Bool { page >= pages.count - 1 }

    var body: some View {
        ZStack {
            BackgroundGradientView()

            GeometryReader { geo in
                let wide = geo.size.width > geo.size.height
                Group {
                    if wide {
                        HStack(spacing: 28) {
                            diagram.frame(maxWidth: .infinity)
                            textColumn.frame(maxWidth: .infinity)
                        }
                    } else {
                        VStack(spacing: 18) {
                            diagram.frame(height: 200)
                            textColumn
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private var textColumn: some View {
        VStack(spacing: 12) {
            HeaderKickView(kick: current.kick, title: current.title)
            Text(current.body)
                .font(.system(size: 14, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundColor(UITheme.textCream)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Circle()
                        .fill(i == page ? current.accent : UITheme.textCream.opacity(0.25))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.top, 2)

            HStack(spacing: 12) {
                if page > 0 {
                    PillButton(title: "Back", action: { page -= 1 })
                } else {
                    PillButton(title: "Skip", action: onDone)
                }
                PillButton(title: isLast ? "To Battle" : "Next", isPrimary: true, action: {
                    if isLast { onDone() } else { page += 1 }
                })
            }
        }
        .id(page)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    /// A looping demonstration of the ring-closing timing mechanic.
    private var diagram: some View {
        let accent = current.accent
        let defend = current.defend
        let showLanes = (page == 0)
        let showFocus = (page == 2)
        return TimelineView(.animation) { timeline in
            let t: Double = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let w = Double(size.width)
                let h = Double(size.height)
                let c = CGPoint(x: w / 2.0, y: h / 2.0)
                let phase = (t / 1.5).truncatingRemainder(dividingBy: 1.0)

                if showLanes {
                    // Three lanes with a note sliding to the hit circle.
                    let laneW = min(60.0, w / 4.0)
                    for k in -1...1 {
                        let x = c.x + Double(k) * (laneW + 10.0)
                        ctx.fill(Path(roundedRect: CGRect(x: x - laneW / 2.0, y: 8, width: laneW, height: h - 16), cornerRadius: 8),
                                 with: .color(Color.white.opacity(0.05)))
                        ctx.stroke(Path(roundedRect: CGRect(x: x - laneW / 2.0, y: 8, width: laneW, height: h - 16), cornerRadius: 8),
                                   with: .color(accent.opacity(0.35)), lineWidth: 1.2)
                        let hitY = h - 34.0
                        ctx.stroke(Path(ellipseIn: CGRect(x: x - 15, y: hitY - 15, width: 30, height: 30)),
                                   with: .color(accent.opacity(0.7)), lineWidth: 2.0)
                    }
                    let noteX = c.x
                    let noteY = 24.0 + phase * (h - 34.0 - 24.0)
                    var diamond = Path()
                    diamond.move(to: CGPoint(x: noteX, y: noteY - 14))
                    diamond.addLine(to: CGPoint(x: noteX + 11, y: noteY))
                    diamond.addLine(to: CGPoint(x: noteX, y: noteY + 14))
                    diamond.addLine(to: CGPoint(x: noteX - 11, y: noteY))
                    diamond.closeSubpath()
                    ctx.fill(diamond, with: .color(accent))
                } else {
                    // A ring closing on the target.
                    let target = 22.0
                    let ringR = target + (1.0 - phase) * min(w, h) * 0.38
                    let hitWindow = phase > 0.88
                    ctx.stroke(Path(ellipseIn: CGRect(x: c.x - target, y: c.y - target, width: target * 2.0, height: target * 2.0)),
                               with: .color(accent.opacity(0.85)), lineWidth: 3.0)
                    if showFocus {
                        // Focus: the window around the target is wider.
                        let wr = target + 16.0 + 3.0 * sin(t * 4.0)
                        ctx.stroke(Path(ellipseIn: CGRect(x: c.x - wr, y: c.y - wr, width: wr * 2.0, height: wr * 2.0)),
                                   with: .color(accent.opacity(0.4)), style: StrokeStyle(lineWidth: 2.0, dash: [5, 5]))
                    }
                    var style = StrokeStyle(lineWidth: 4.0, lineCap: .round)
                    if defend && page == 1 && (Int(t / 3.0) % 2 == 1) {
                        style.dash = [8, 6]
                    }
                    ctx.stroke(Path(ellipseIn: CGRect(x: c.x - ringR, y: c.y - ringR, width: ringR * 2.0, height: ringR * 2.0)),
                               with: .color((hitWindow ? Color.white : accent).opacity(0.95)), style: style)

                    if defend {
                        let labels = ["PARRY", "DODGE", "DUCK", "JUMP"]
                        let r = min(w, h) * 0.46
                        for (i, label) in labels.enumerated() {
                            let a = Double(i) * .pi / 2.0 - .pi / 2.0
                            let p = CGPoint(x: c.x + cos(a) * r * 1.35, y: c.y + sin(a) * r * 0.95)
                            ctx.draw(Text(label).font(.system(size: 11, weight: .bold)).foregroundColor(UITheme.textCream.opacity(0.75)), at: p)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 220)
        .background(RoundedRectangle(cornerRadius: 14).fill(UITheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(UITheme.borderCream, lineWidth: 1))
    }
}
