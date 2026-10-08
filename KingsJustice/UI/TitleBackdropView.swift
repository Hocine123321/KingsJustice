import SwiftUI

/// Animated medieval skyline: blood moon, parallax ridges, a flickering castle and rising embers.
struct TitleBackdropView: View {
    /// Fraction of the screen height where the artwork starts fading into the menu background.
    var fadeStart: Double = 0.34
    var fadeEnd: Double = 0.66

    var body: some View {
        TimelineView(.animation) { timeline in
            let t: Double = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                TitleBackdropView.draw(in: ctx, size: size, time: t)
            }
        }
        .overlay(
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: UITheme.bgNearBlack.opacity(0.0), location: fadeStart),
                    Gradient.Stop(color: UITheme.bgNearBlack, location: fadeEnd)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private static func ridge(size: CGSize, base: Double, amp: Double, seed: Double, drift: Double) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: size.height))
        let steps = 56
        for i in 0...steps {
            let x = size.width * Double(i) / Double(steps)
            let u = x / size.width * 6.0 + drift + seed
            let wave = 0.6 * sin(u) + 0.3 * sin(u * 2.3 + seed) + 0.1 * sin(u * 5.1)
            p.addLine(to: CGPoint(x: x, y: base - amp * wave))
        }
        p.addLine(to: CGPoint(x: size.width, y: size.height))
        p.closeSubpath()
        return p
    }

    private static func castle(in ctx: GraphicsContext, cx: Double, base: Double, unit: Double, time: Double) {
        let dark = Color(red: 0.05, green: 0.03, blue: 0.03)
        let rim = Color(red: 0.55, green: 0.18, blue: 0.12).opacity(0.55)

        func tower(_ x: Double, _ w: Double, _ h: Double, roof: Bool) {
            let body = CGRect(x: x - w / 2.0, y: base - h, width: w, height: h)
            ctx.fill(Path(body), with: .color(dark))
            // crenellations
            let n = max(2, Int(w / (unit * 0.28)))
            let mw = w / Double(n * 2 - 1)
            for k in 0..<n {
                let mx = x - w / 2.0 + Double(k) * mw * 2.0
                ctx.fill(Path(CGRect(x: mx, y: base - h - unit * 0.18, width: mw, height: unit * 0.18)), with: .color(dark))
            }
            if roof {
                var r = Path()
                r.move(to: CGPoint(x: x - w * 0.6, y: base - h))
                r.addLine(to: CGPoint(x: x, y: base - h - unit * 1.1))
                r.addLine(to: CGPoint(x: x + w * 0.6, y: base - h))
                r.closeSubpath()
                ctx.fill(r, with: .color(dark))
            }
            ctx.fill(Path(CGRect(x: x - w / 2.0, y: base - h, width: unit * 0.05, height: h)), with: .color(rim))
        }

        // curtain wall + keep + towers
        ctx.fill(Path(CGRect(x: cx - unit * 2.2, y: base - unit * 1.2, width: unit * 4.4, height: unit * 1.2)), with: .color(dark))
        tower(cx - unit * 2.0, unit * 0.9, unit * 2.4, roof: true)
        tower(cx + unit * 2.0, unit * 0.9, unit * 2.1, roof: true)
        tower(cx, unit * 1.3, unit * 3.2, roof: false)
        tower(cx - unit * 0.9, unit * 0.6, unit * 2.2, roof: true)

        // flickering windows
        let windows: [(Double, Double)] = [(0.0, 2.2), (-2.0, 1.6), (2.0, 1.4), (-0.9, 1.5), (0.35, 1.0), (-0.35, 1.0)]
        for (i, wdw) in windows.enumerated() {
            let f = 0.55 + 0.45 * sin(time * (2.0 + Double(i) * 0.7) + Double(i) * 1.9)
            let rect = CGRect(x: cx + wdw.0 * unit - unit * 0.06, y: base - wdw.1 * unit, width: unit * 0.12, height: unit * 0.22)
            ctx.fill(Path(rect), with: .color(Color(red: 1.0, green: 0.62, blue: 0.2).opacity(0.35 + 0.55 * f)))
        }
    }

    static func draw(in ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = Double(size.width)
        let h = Double(size.height)
        guard w > 0 && h > 0 else { return }

        // Sky
        let sky = Gradient(stops: [
            Gradient.Stop(color: Color(red: 0.05, green: 0.02, blue: 0.03), location: 0.0),
            Gradient.Stop(color: Color(red: 0.22, green: 0.07, blue: 0.06), location: 0.55),
            Gradient.Stop(color: Color(red: 0.55, green: 0.20, blue: 0.10), location: 1.0)
        ])
        ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h * 0.45)),
                 with: .linearGradient(sky, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: h * 0.45)))

        // Blood moon with breathing glow
        let moonC = CGPoint(x: w * 0.28, y: h * 0.14)
        let breathe = 1.0 + 0.04 * sin(time * 0.8)
        let glow = Gradient(stops: [
            Gradient.Stop(color: Color(red: 0.95, green: 0.25, blue: 0.15).opacity(0.38), location: 0.0),
            Gradient.Stop(color: Color(red: 0.95, green: 0.25, blue: 0.15).opacity(0.0), location: 1.0)
        ])
        let gr = 170.0 * breathe
        ctx.fill(Path(ellipseIn: CGRect(x: moonC.x - gr, y: moonC.y - gr, width: gr * 2.0, height: gr * 2.0)),
                 with: .radialGradient(glow, center: moonC, startRadius: 0, endRadius: gr))
        ctx.fill(Path(ellipseIn: CGRect(x: moonC.x - 40, y: moonC.y - 40, width: 80, height: 80)),
                 with: .color(Color(red: 0.92, green: 0.28, blue: 0.20)))

        // Far ridge
        ctx.fill(ridge(size: size, base: h * 0.36, amp: 34.0, seed: 1.3, drift: time * 0.015),
                 with: .color(Color(red: 0.16, green: 0.06, blue: 0.06)))

        // Castle on the mid ridge
        let castleBase = h * 0.385
        castle(in: ctx, cx: w * 0.70, base: castleBase, unit: min(34.0, w / 12.0), time: time)

        // Mid and near ridges
        ctx.fill(ridge(size: size, base: h * 0.40, amp: 26.0, seed: 4.1, drift: time * 0.03),
                 with: .color(Color(red: 0.09, green: 0.04, blue: 0.04)))
        ctx.fill(ridge(size: size, base: h * 0.45, amp: 20.0, seed: 7.7, drift: time * 0.05),
                 with: .color(Color(red: 0.05, green: 0.025, blue: 0.025)))

        // Drifting low mist
        for k in 0..<2 {
            let cx = (time * (6.0 + Double(k) * 5.0) + Double(k) * 260.0).truncatingRemainder(dividingBy: w + 600.0) - 300.0
            let mist = Gradient(stops: [
                Gradient.Stop(color: Color(red: 0.8, green: 0.45, blue: 0.3).opacity(0.14), location: 0.0),
                Gradient.Stop(color: Color(red: 0.8, green: 0.45, blue: 0.3).opacity(0.0), location: 1.0)
            ])
            ctx.drawLayer { c in
                c.translateBy(x: cx, y: h * (0.39 + Double(k) * 0.03))
                c.scaleBy(x: 1.0, y: 0.18)
                c.fill(Path(ellipseIn: CGRect(x: -320, y: -320, width: 640, height: 640)),
                       with: .radialGradient(mist, center: .zero, startRadius: 0, endRadius: 320))
            }
        }

        // Rising embers
        let travel = h * 0.55
        for i in 0..<44 {
            let fi = Double(i)
            let speed = 16.0 + Double((i * 37) % 22)
            let rise = (time * speed + fi * 53.0).truncatingRemainder(dividingBy: travel)
            let x0 = Double((i * 73) % 100) / 100.0 * w
            let x = x0 + sin(time * 0.8 + fi) * 16.0
            let y = h * 0.56 - rise
            let life = rise / travel
            let alpha = (1.0 - life) * (0.35 + 0.65 * abs(sin(time * 3.0 + fi)))
            let r = 1.0 + Double(i % 3) * 0.7
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2.0, height: r * 2.0)),
                     with: .color(Color(red: 1.0, green: 0.55 + 0.3 * life, blue: 0.2).opacity(alpha)))
        }
    }
}
