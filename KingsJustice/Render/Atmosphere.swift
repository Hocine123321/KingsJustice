import SwiftUI

/// Screen-space polish drawn on top of the arena: drifting fog, torch flicker,
/// the Focus aura and the finishing-blow kill-cam grading.
enum Atmosphere {
    private static func fogColor(for arenaKey: String) -> Color {
        switch arenaKey {
        case "castle", "throne": return Color(red: 0.70, green: 0.58, blue: 0.45)
        case "village": return Color(red: 0.85, green: 0.45, blue: 0.20)
        case "pass": return Color(red: 0.75, green: 0.85, blue: 0.95)
        case "swamp": return Color(red: 0.45, green: 0.70, blue: 0.50)
        case "cliff": return Color(red: 0.80, green: 0.25, blue: 0.22)
        case "cathedral": return Color(red: 0.45, green: 0.55, blue: 0.80)
        default: return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }

    /// Low drifting mist bands. Cheap: gradient fills only, no blur filters.
    static func drawFog(in context: GraphicsContext, arenaKey: String, time: Double, strength: Double) {
        let col = fogColor(for: arenaKey)
        let grad = Gradient(stops: [
            Gradient.Stop(color: col.opacity(0.16 * strength), location: 0.0),
            Gradient.Stop(color: col.opacity(0.0), location: 1.0)
        ])
        for k in 0..<3 {
            let speed = 7.0 + Double(k) * 4.0
            let span = 2400.0
            var cx = (time * speed + Double(k) * 820.0).truncatingRemainder(dividingBy: span) - 400.0
            if k == 1 { cx = 1600.0 - cx }
            let cy = 700.0 + Double(k) * 52.0
            context.drawLayer { ctx in
                ctx.translateBy(x: cx, y: cy)
                ctx.scaleBy(x: 1.0, y: 0.2)
                let r = 520.0 + Double(k) * 60.0
                ctx.fill(Path(ellipseIn: CGRect(x: -r, y: -r, width: r * 2.0, height: r * 2.0)),
                         with: .radialGradient(grad, center: .zero, startRadius: 0, endRadius: r))
            }
        }
    }

    /// Multiplier for torch light so flames breathe instead of glowing evenly.
    static func flicker(time: Double, phase: Double) -> Double {
        return 1.0 + 0.10 * sin(time * 7.3 + phase) + 0.05 * sin(time * 13.1 + phase * 2.0) + 0.03 * sin(time * 29.0 + phase * 3.0)
    }

    /// Cool pulsing aura around the screen edge while Focus is active.
    static func drawFocus(in context: GraphicsContext, time: Double) {
        let pulse = 0.5 + 0.5 * sin(time * 4.0)
        let edge = Color(red: 0.45, green: 0.72, blue: 1.0)
        let grad = Gradient(stops: [
            Gradient.Stop(color: edge.opacity(0.0), location: 0.55),
            Gradient.Stop(color: edge.opacity(0.22 + 0.10 * pulse), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: 1600, height: 900)),
                     with: .radialGradient(grad, center: CGPoint(x: 800, y: 450), startRadius: 300, endRadius: 950))
    }

    /// Darkens and tightens the frame during the finishing blow.
    static func drawKillCam(in context: GraphicsContext, amount: Double) {
        guard amount > 0.0 else { return }
        let grad = Gradient(stops: [
            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.25),
            Gradient.Stop(color: Color.black.opacity(0.75 * amount), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: 1600, height: 900)),
                     with: .radialGradient(grad, center: CGPoint(x: 860, y: 470), startRadius: 120, endRadius: 800))
    }
}
