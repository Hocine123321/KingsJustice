import SwiftUI
import CoreGraphics

struct WeatherParticle: Sendable {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var size: Double
    var opacity: Double
    var life: Double
    var maxLife: Double
    var phase: Double
}

struct SparkParticle: Sendable {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var size: Double
    var opacity: Double
    var life: Double
    var maxLife: Double
}

struct BloodParticle: Sendable {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var size: Double
    var opacity: Double
    var life: Double
    var maxLife: Double
}

struct GroundStain: Sendable {
    var x: Double
    var y: Double
    var radius: Double
    var opacity: Double
}

final class ParticleSystem: @unchecked Sendable {
    var weatherParticles: [WeatherParticle] = []
    var sparkParticles: [SparkParticle] = []
    var bloodParticles: [BloodParticle] = []
    var groundStains: [GroundStain] = []

    private var currentArenaKey: String = ""
    private var lastTime: Double = 0.0

    init() {}

    func setupWeather(type: String, count: Int, color: String, wind: Double) {
        let n = max(0, min(150, count))
        weatherParticles.removeAll()
        weatherParticles.reserveCapacity(n)

        for i in 0..<n {
            let x = Double.random(in: -100...1700)
            let y = Double.random(in: -100...1000)
            let phase = Double(i) * 0.37

            var vx = wind * 20.0
            var vy = 0.0
            var sz = 2.0
            var maxL = 5.0

            switch type {
            case "embers":
                vx += Double.random(in: 10...30)
                vy = Double.random(in: -40...(-10))
                sz = Double.random(in: 2...4.5)
                maxL = Double.random(in: 2...5)
            case "snow":
                vx += Double.random(in: -10...10)
                vy = Double.random(in: 20...60)
                sz = Double.random(in: 2...5)
                maxL = Double.random(in: 4...8)
            case "rain":
                vx += 40.0
                vy = Double.random(in: 400...700)
                sz = Double.random(in: 12...22) // line length
                maxL = Double.random(in: 1.5...3)
            case "ash":
                vx += Double.random(in: -15...5)
                vy = Double.random(in: 10...30)
                sz = Double.random(in: 1.5...3.5)
                maxL = Double.random(in: 3...6)
            case "fireflies":
                vx = Double.random(in: -15...15)
                vy = Double.random(in: -15...15)
                sz = Double.random(in: 3...6)
                maxL = Double.random(in: 3...7)
            default: // dust
                vx += Double.random(in: -5...5)
                vy = Double.random(in: -5...5)
                sz = Double.random(in: 1.5...3)
                maxL = Double.random(in: 3...6)
            }

            let p = WeatherParticle(
                x: x, y: y,
                vx: vx, vy: vy,
                size: sz,
                opacity: Double.random(in: 0.3...0.85),
                life: Double.random(in: 0...maxL),
                maxLife: maxL,
                phase: phase
            )
            weatherParticles.append(p)
        }
    }

    func update(dt: Double, time: Double, weatherType: String, wind: Double) {
        // Update weather
        for i in 0..<weatherParticles.count {
            var p = weatherParticles[i]
            p.life += dt
            if p.life >= p.maxLife {
                p.life = 0
                p.x = Double.random(in: -100...1700)
                p.y = weatherType == "embers" ? 950.0 : (weatherType == "snow" || weatherType == "rain" ? -50.0 : Double.random(in: -50...950))
            } else {
                let sway = sin(time * 2.0 + p.phase) * 12.0
                p.x += (p.vx + (weatherType == "fireflies" ? sway : 0)) * dt
                p.y += p.vy * dt
            }
            weatherParticles[i] = p
        }

        // Update sparks
        var newSparks: [SparkParticle] = []
        for var s in sparkParticles {
            s.x += s.vx * dt
            s.y += s.vy * dt
            s.vy += 300.0 * dt // gravity
            s.life += dt
            if s.life < s.maxLife {
                s.opacity = 1.0 - (s.life / s.maxLife)
                newSparks.append(s)
            }
        }
        sparkParticles = newSparks

        // Update blood
        var newBlood: [BloodParticle] = []
        for var b in bloodParticles {
            b.x += b.vx * dt
            b.y += b.vy * dt
            b.vy += 600.0 * dt // gravity
            b.life += dt

            if b.y >= 720.0 { // hit ground
                addStain(x: b.x, y: 720.0 + Double.random(in: 0...10), r: b.size * 2.5)
            } else if b.life < b.maxLife {
                b.opacity = 1.0 - (b.life / b.maxLife) * 0.5
                newBlood.append(b)
            }
        }
        bloodParticles = newBlood
    }

    func spawnSpark(x: Double, y: Double, count: Int) {
        let n = max(1, min(30, count))
        for _ in 0..<n {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 80...350)
            let p = SparkParticle(
                x: x, y: y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 50.0,
                size: Double.random(in: 2.5...5.0),
                opacity: 1.0,
                life: 0,
                maxLife: Double.random(in: 0.2...0.5)
            )
            sparkParticles.append(p)
        }
    }

    func spawnBlood(x: Double, y: Double, count: Int, dir: Double, power: Double) {
        let n = max(1, min(40, count))
        for _ in 0..<n {
            let baseAngle = dir < 0 ? .pi : 0.0
            let angle = baseAngle + Double.random(in: -0.8...0.8)
            let speed = Double.random(in: 100...400) * power
            let p = BloodParticle(
                x: x, y: y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 120.0,
                size: Double.random(in: 3.0...8.0),
                opacity: 0.9,
                life: 0,
                maxLife: Double.random(in: 0.4...0.9)
            )
            bloodParticles.append(p)
        }
    }

    func addStain(x: Double, y: Double, r: Double) {
        if groundStains.count > 50 {
            groundStains.removeFirst()
        }
        let stain = GroundStain(x: x, y: y, radius: max(10, r), opacity: Double.random(in: 0.6...0.85))
        groundStains.append(stain)
    }

    func drawWeather(in context: GraphicsContext, type: String, defaultColor: Color) {
        for p in weatherParticles {
            let rect = CGRect(x: p.x - p.size / 2.0, y: p.y - p.size / 2.0, width: p.size, height: p.size)

            switch type {
            case "embers":
                let col = Color(red: 1.0, green: 0.55, blue: 0.12, opacity: p.opacity)
                context.fill(Path(ellipseIn: rect), with: .color(col))

            case "rain":
                var rPath = Path()
                rPath.move(to: CGPoint(x: p.x, y: p.y))
                rPath.addLine(to: CGPoint(x: p.x - 8.0, y: p.y + p.size))
                let style = StrokeStyle(lineWidth: 1.2)
                context.stroke(rPath, with: .color(Color(red: 0.7, green: 0.8, blue: 0.9, opacity: p.opacity * 0.5)), style: style)

            case "fireflies":
                let col = Color(red: 0.95, green: 0.9, blue: 0.3, opacity: p.opacity)
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: 2.0))
                    ctx.fill(Path(ellipseIn: rect), with: .color(col))
                }
                context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(p.opacity)))

            default: // snow, ash, dust
                context.fill(Path(ellipseIn: rect), with: .color(defaultColor.opacity(p.opacity)))
            }
        }
    }

    func drawSparks(in context: GraphicsContext) {
        for p in sparkParticles {
            let rect = CGRect(x: p.x - p.size / 2.0, y: p.y - p.size / 2.0, width: p.size, height: p.size)
            let col = Color(red: 1.0, green: 0.8, blue: 0.3, opacity: p.opacity)
            context.drawLayer { ctx in
                ctx.addFilter(.blur(radius: 1.5))
                ctx.fill(Path(ellipseIn: rect), with: .color(col))
            }
            context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(p.opacity)))
        }
    }

    func drawBlood(in context: GraphicsContext) {
        let bloodCol = Color(red: 0.54, green: 0.03, blue: 0.03)
        for p in bloodParticles {
            let rect = CGRect(x: p.x - p.size / 2.0, y: p.y - p.size / 2.0, width: p.size, height: p.size)
            context.fill(Path(ellipseIn: rect), with: .color(bloodCol.opacity(p.opacity)))
        }
    }

    func drawStains(in context: GraphicsContext) {
        for s in groundStains {
            let rect = CGRect(x: s.x - s.radius, y: s.y - s.radius * 0.25, width: s.radius * 2.0, height: s.radius * 0.5)
            let bloodCol = Color(red: 0.42, green: 0.02, blue: 0.02, opacity: s.opacity)
            context.fill(Path(ellipseIn: rect), with: .color(bloodCol))
        }
    }
}
