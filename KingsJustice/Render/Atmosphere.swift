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

    /// Soft elliptical glow without a blur filter (blur layers are expensive every frame).
    static func softGlow(in context: GraphicsContext, center: CGPoint, rx: Double, ry: Double, color: Color, opacity: Double) {
        guard rx > 0.5 && ry > 0.5 && opacity > 0.0 else { return }
        let grad = Gradient(stops: [
            Gradient.Stop(color: color.opacity(opacity), location: 0.0),
            Gradient.Stop(color: color.opacity(opacity * 0.45), location: 0.55),
            Gradient.Stop(color: color.opacity(0.0), location: 1.0)
        ])
        context.drawLayer { ctx in
            ctx.translateBy(x: center.x, y: center.y)
            ctx.scaleBy(x: 1.0, y: ry / rx)
            ctx.fill(Path(ellipseIn: CGRect(x: -rx, y: -rx, width: rx * 2.0, height: rx * 2.0)),
                     with: .radialGradient(grad, center: .zero, startRadius: 0, endRadius: rx))
        }
    }

    /// Cool pulsing aura around the screen edge while Focus is active. Drawn in SCREEN space so it
    /// always reaches the real screen edges (no visible 16:9 frame on wide phones).
    static func drawFocus(in context: GraphicsContext, size: CGSize, time: Double) {
        let w = Double(size.width)
        let h = Double(size.height)
        let pulse = 0.5 + 0.5 * sin(time * 4.0)
        let edge = Color(red: 0.45, green: 0.72, blue: 1.0)
        let grad = Gradient(stops: [
            Gradient.Stop(color: edge.opacity(0.0), location: 0.55),
            Gradient.Stop(color: edge.opacity(0.20 + 0.10 * pulse), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .radialGradient(grad, center: CGPoint(x: w / 2.0, y: h / 2.0), startRadius: 0, endRadius: max(w, h) * 0.62))
    }

    /// Darkens and tightens the frame during the finishing blow (screen space).
    static func drawKillCam(in context: GraphicsContext, size: CGSize, amount: Double) {
        guard amount > 0.0 else { return }
        let w = Double(size.width)
        let h = Double(size.height)
        let grad = Gradient(stops: [
            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.25),
            Gradient.Stop(color: Color.black.opacity(0.75 * amount), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .radialGradient(grad, center: CGPoint(x: w * 0.54, y: h * 0.52), startRadius: 0, endRadius: max(w, h) * 0.6))
    }
}
