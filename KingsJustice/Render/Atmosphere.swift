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

    /// How thick each battlefield's mist is, from the fog opacity authored in the arena data (0.17 castle up to 0.28 marsh).
    /// Normalised so the average across the six arenas stays about 1.0 and the overall fog level does not change.
    static func fogDensity(for arenaKey: String) -> Double {
        guard let op = GameData.arenas[arenaKey]?.light.fogOp else { return 1.0 }
        return min(1.4, max(0.6, op / 0.22))
    }

    /// Low drifting mist bands. Cheap: gradient fills only, no blur filters.
    static func drawFog(in context: GraphicsContext, arenaKey: String, time: Double, strength: Double) {
        let col = fogColor(for: arenaKey)
        let grad = Gradient(stops: [
            Gradient.Stop(color: col.opacity(0.16 * strength * fogDensity(for: arenaKey)), location: 0.0),
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

    /// A brief gold glow around the screen edge after a Perfect (screen space, so it hugs the real edge).
    static func drawPerfectEdge(in context: GraphicsContext, size: CGSize, amount: Double) {
        guard amount > 0.01 else { return }
        let w = Double(size.width)
        let h = Double(size.height)
        let gold = Color(red: 1.0, green: 0.82, blue: 0.35)
        let grad = Gradient(stops: [
            Gradient.Stop(color: gold.opacity(0.0), location: 0.62),
            Gradient.Stop(color: gold.opacity(0.34 * amount), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .radialGradient(grad, center: CGPoint(x: w / 2.0, y: h / 2.0), startRadius: 0, endRadius: max(w, h) * 0.62))
    }
}

// MARK: - Ambient life

extension Atmosphere {
    enum AmbientKind: Equatable {
        case crows, bats, fireflies, embers, motes, leaves, sparks, quiet
    }

    struct AmbientSpot: Equatable {
        var x: Double
        var y: Double
        var size: Double
        var flap: Double
        var alpha: Double
    }

    /// Which small background creature or particle belongs to each battlefield.
    static func ambientKind(for arenaKey: String) -> AmbientKind {
        switch arenaKey {
        case "castle", "throne", "cliff": return .crows
        case "cathedral": return .bats
        case "swamp": return .fireflies
        case "village": return .embers
        case "pass": return .motes
        default: return .quiet
        }
    }

    /// A second, lighter layer on some arenas: falling leaves in the village, torch sparks at the
    /// castle and cliff.
    static func ambientAccent(for arenaKey: String) -> AmbientKind {
        switch arenaKey {
        case "village": return .leaves
        case "castle", "cliff": return .sparks
        default: return .quiet
        }
    }

    private static func unit(_ i: Int, _ salt: Double) -> Double {
        let v = sin(Double(i) * 12.9898 + salt * 78.233) * 43758.5453
        return v - floor(v)
    }

    private static func wrap(_ v: Double, _ span: Double) -> Double {
        let r = v.truncatingRemainder(dividingBy: span)
        return r < 0.0 ? r + span : r
    }

    /// Positions for one frame, in the 1600x900 world. A pure function of time, so it needs no state
    /// and is cheap enough for every frame.
    static func ambientSpots(kind: AmbientKind, time: Double, emitters: [CGPoint] = []) -> [AmbientSpot] {
        var out: [AmbientSpot] = []
        switch kind {
        case .crows:
            for i in 0..<4 {
                let u = unit(i, 1.0)
                let dir: Double = (i % 2 == 0) ? 1.0 : -1.0
                let x = wrap(time * (38.0 + u * 30.0) * dir + u * 2000.0, 2000.0) - 200.0
                let y = 90.0 + unit(i, 2.0) * 170.0 + 14.0 * sin(time * 0.7 + Double(i))
                let flap = 7.0 * sin(time * (4.0 + u * 3.0) + Double(i) * 1.3)
                out.append(AmbientSpot(x: x, y: y, size: 16.0 + u * 8.0, flap: flap, alpha: 0.8))
            }
        case .bats:
            for i in 0..<5 {
                let u = unit(i, 1.0)
                let dir: Double = (i % 2 == 0) ? -1.0 : 1.0
                let x = wrap(time * (70.0 + u * 50.0) * dir + u * 2000.0, 2000.0) - 200.0
                let y = 130.0 + unit(i, 2.0) * 230.0 + 38.0 * sin(time * 1.9 + Double(i) * 2.0)
                let flap = 9.0 * sin(time * (9.0 + u * 4.0) + Double(i))
                out.append(AmbientSpot(x: x, y: y, size: 11.0 + u * 5.0, flap: flap, alpha: 0.85))
            }
        case .fireflies:
            for i in 0..<9 {
                let u = unit(i, 1.0)
                let x = 140.0 + u * 1320.0 + 55.0 * sin(time * 0.31 + Double(i) * 1.7)
                let y = 470.0 + unit(i, 2.0) * 260.0 + 28.0 * sin(time * 0.47 + Double(i) * 2.3)
                let pulse = 0.5 + 0.5 * sin(time * 1.6 + Double(i) * 2.1)
                out.append(AmbientSpot(x: x, y: y, size: 12.0 + u * 8.0, flap: 0.0, alpha: pulse))
            }
        case .embers:
            for i in 0..<14 {
                let u = unit(i, 1.0)
                let phase = wrap(time * (0.10 + u * 0.10) + unit(i, 3.0), 1.0)
                let y = 840.0 - phase * 700.0
                let x = u * 1600.0 + 24.0 * sin(time * 1.1 + Double(i))
                out.append(AmbientSpot(x: x, y: y, size: 2.5 + u * 2.0, flap: 0.0, alpha: 0.9 * sin(phase * Double.pi)))
            }
        case .motes:
            for i in 0..<18 {
                let u = unit(i, 1.0)
                let phase = wrap(time * (0.05 + u * 0.05) + unit(i, 3.0), 1.0)
                let x = wrap(u * 1600.0 + time * (14.0 + u * 10.0) + 18.0 * sin(time * 0.8 + Double(i)), 1600.0)
                out.append(AmbientSpot(x: x, y: phase * 900.0, size: 1.8 + u * 1.6, flap: 0.0, alpha: 0.55))
            }
        case .leaves:
            for i in 0..<7 {
                let u = unit(i, 1.0)
                let phase = wrap(time * (0.06 + u * 0.05) + unit(i, 3.0), 1.0)
                let x = wrap(u * 1600.0 + time * (20.0 + u * 12.0) + 60.0 * sin(time * 0.9 + Double(i) * 1.4), 1600.0)
                out.append(AmbientSpot(x: x, y: phase * 860.0, size: 5.0 + u * 3.0, flap: 0.9 * sin(time * 2.2 + Double(i)), alpha: 0.8))
            }
        case .sparks:
            for (n, e) in emitters.enumerated() {
                for j in 0..<5 {
                    let i = n * 5 + j
                    let u = unit(i, 1.0)
                    let phase = wrap(time * (0.35 + u * 0.30) + unit(i, 3.0), 1.0)
                    let x = Double(e.x) + (u - 0.5) * 50.0 + 26.0 * sin(time * 3.0 + Double(i)) * phase
                    let y = Double(e.y) - phase * 240.0
                    out.append(AmbientSpot(x: x, y: y, size: 1.6 + u * 1.2, flap: 0.0, alpha: 0.95 * (1.0 - phase)))
                }
            }
        case .quiet:
            break
        }
        return out
    }

    /// Torch positions for an arena, in world coordinates.
    static func torchPoints(for arenaKey: String) -> [CGPoint] {
        guard let l = GameData.arenas[arenaKey]?.light else { return [] }
        return [CGPoint(x: l.keyLX, y: l.keyLY), CGPoint(x: l.keyRX, y: l.keyRY)]
    }

    /// Crows over the castle and cliff, bats in the cathedral, fireflies in the marsh, rising embers
    /// in the village and snow motes in the pass, plus falling leaves and torch sparks as a second
    /// layer. Fills and strokes only.
    static func drawAmbientLife(in context: GraphicsContext, arenaKey: String, time: Double, strength: Double) {
        guard strength > 0.01 else { return }
        drawLayer(in: context, kind: ambientKind(for: arenaKey), arenaKey: arenaKey, time: time, strength: strength)
        drawLayer(in: context, kind: ambientAccent(for: arenaKey), arenaKey: arenaKey, time: time, strength: strength)
    }

    private static func drawLayer(in context: GraphicsContext, kind: AmbientKind, arenaKey: String, time: Double, strength: Double) {
        guard kind != .quiet else { return }
        let emitters = (kind == .sparks) ? torchPoints(for: arenaKey) : []
        for s in ambientSpots(kind: kind, time: time, emitters: emitters) {
            let a = max(0.0, min(1.0, s.alpha * strength))
            switch kind {
            case .crows, .bats:
                var p = Path()
                p.move(to: CGPoint(x: s.x - s.size, y: s.y - s.flap))
                p.addQuadCurve(to: CGPoint(x: s.x, y: s.y), control: CGPoint(x: s.x - s.size * 0.5, y: s.y - s.size * 0.5 - s.flap * 0.5))
                p.addQuadCurve(to: CGPoint(x: s.x + s.size, y: s.y - s.flap), control: CGPoint(x: s.x + s.size * 0.5, y: s.y - s.size * 0.5 - s.flap * 0.5))
                let col = (kind == .bats) ? Color(red: 0.10, green: 0.06, blue: 0.14) : Color(red: 0.04, green: 0.04, blue: 0.05)
                context.stroke(p, with: .color(col.opacity(a)), style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
            case .fireflies:
                softGlow(in: context, center: CGPoint(x: s.x, y: s.y), rx: s.size, ry: s.size, color: Color(red: 0.75, green: 0.95, blue: 0.40), opacity: 0.85 * a)
            case .embers, .sparks:
                let r = CGRect(x: s.x - s.size, y: s.y - s.size, width: s.size * 2.0, height: s.size * 2.0)
                let col = (kind == .sparks) ? Color(red: 1.0, green: 0.75, blue: 0.35) : Color(red: 1.0, green: 0.55, blue: 0.20)
                context.fill(Path(ellipseIn: r), with: .color(col.opacity(a)))
            case .motes:
                let r = CGRect(x: s.x - s.size, y: s.y - s.size, width: s.size * 2.0, height: s.size * 2.0)
                context.fill(Path(ellipseIn: r), with: .color(Color(red: 0.90, green: 0.95, blue: 1.0).opacity(a)))
            case .leaves:
                let leaf = Path(ellipseIn: CGRect(x: -s.size, y: -s.size * 0.45, width: s.size * 2.0, height: s.size * 0.9))
                    .applying(CGAffineTransform(rotationAngle: s.flap).concatenating(CGAffineTransform(translationX: s.x, y: s.y)))
                context.fill(leaf, with: .color(Color(red: 0.72, green: 0.42, blue: 0.16).opacity(a)))
            case .quiet:
                break
            }
        }
    }

    /// Each arena's overall colour cast and how strong it is. Subtle by design: it ties art, fog and lights together.
    static func grade(for arenaKey: String) -> (color: Color, opacity: Double) {
        switch arenaKey {
        case "castle": return (Color(red: 0.95, green: 0.62, blue: 0.25), 0.07)      // warm torchlight
        case "village": return (Color(red: 1.0, green: 0.35, blue: 0.12), 0.08)      // fire
        case "pass": return (Color(red: 0.45, green: 0.65, blue: 1.0), 0.08)         // frost
        case "swamp": return (Color(red: 0.25, green: 0.8, blue: 0.45), 0.09)        // sickly green
        case "cliff": return (Color(red: 0.9, green: 0.12, blue: 0.15), 0.07)        // blood moon
        case "cathedral": return (Color(red: 0.35, green: 0.45, blue: 0.95), 0.07)   // stained-glass blue
        default: return (Color.clear, 0.0)
        }
    }

    /// A full-screen colour wash plus a soft darkening toward the edges, in screen space.
    static func drawGrade(in context: GraphicsContext, size: CGSize, arenaKey: String) {
        let g = grade(for: arenaKey)
        guard g.opacity > 0.0 else { return }
        let w = Double(size.width)
        let h = Double(size.height)
        context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(g.color.opacity(g.opacity)))
        let vignette = Gradient(stops: [
            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.55),
            Gradient.Stop(color: Color.black.opacity(0.28), location: 1.0)
        ])
        context.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                     with: .radialGradient(vignette, center: CGPoint(x: w / 2.0, y: h / 2.0), startRadius: 0, endRadius: max(w, h) * 0.7))
    }
}
