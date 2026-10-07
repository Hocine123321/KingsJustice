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

struct DustParticle: Sendable {
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
    var dustParticles: [DustParticle] = []
    var groundStains: [GroundStain] = []

    private var currentArenaKey: String = ""
    private var lastTime: Double = 0.0

    init() {}

    func setupWeather(type: String, count: Int, color: String, wind: Double) {
        let n = max(0, min(120, count))
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
                sz = Double.random(in: 12...22)
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
        newSparks.reserveCapacity(sparkParticles.count)
        for var s in sparkParticles {
            s.x += s.vx * dt
            s.y += s.vy * dt
            s.vy += 350.0 * dt // gravity
            s.vx *= (1.0 - 0.3 * dt) // air drag
            s.life += dt
            if s.life < s.maxLife {
                s.opacity = 1.0 - (s.life / s.maxLife)
                newSparks.append(s)
            }
        }
        sparkParticles = newSparks

        // Update blood
        var newBlood: [BloodParticle] = []
        newBlood.reserveCapacity(bloodParticles.count)
        for var b in bloodParticles {
            b.x += b.vx * dt
            b.y += b.vy * dt
            b.vy += 800.0 * dt // gravity arc
            b.vx *= (1.0 - 0.4 * dt)
            b.life += dt

            if b.y >= 715.0 { // hit ground
                addStain(x: b.x, y: 715.0 + Double.random(in: -4...6), r: b.size * 2.2)
            } else if b.life < b.maxLife {
                b.opacity = 1.0 - (b.life / b.maxLife) * 0.5
                newBlood.append(b)
            }
        }
        bloodParticles = newBlood

        // Update dust
        var newDust: [DustParticle] = []
        newDust.reserveCapacity(dustParticles.count)
        for var d in dustParticles {
            d.x += d.vx * dt
            d.y += d.vy * dt
            d.vx *= (1.0 - 1.8 * dt)
            d.vy *= (1.0 - 1.8 * dt)
            d.size += 12.0 * dt
            d.life += dt
            if d.life < d.maxLife {
                d.opacity = (1.0 - d.life / d.maxLife) * 0.5
                newDust.append(d)
            }
        }
        dustParticles = newDust

        // Enforce particle count cap <= 300 total
        let maxTotal = 300
        let currentTotal = weatherParticles.count + sparkParticles.count + bloodParticles.count + dustParticles.count
        if currentTotal > maxTotal {
            let excess = currentTotal - maxTotal
            if sparkParticles.count > 30 {
                let rem = min(excess, sparkParticles.count - 30)
                sparkParticles.removeFirst(rem)
            }
            let totalNow1 = weatherParticles.count + sparkParticles.count + bloodParticles.count + dustParticles.count
            if totalNow1 > maxTotal && bloodParticles.count > 30 {
                let rem = min(totalNow1 - maxTotal, bloodParticles.count - 30)
                bloodParticles.removeFirst(rem)
            }
            let totalNow2 = weatherParticles.count + sparkParticles.count + bloodParticles.count + dustParticles.count
            if totalNow2 > maxTotal && dustParticles.count > 20 {
                let rem = min(totalNow2 - maxTotal, dustParticles.count - 20)
                dustParticles.removeFirst(rem)
            }
        }
    }

    func spawnSpark(x: Double, y: Double, count: Int) {
        let n = max(1, min(30, count))
        for _ in 0..<n {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 100...480)
            let p = SparkParticle(
                x: x, y: y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 60.0,
                size: Double.random(in: 2.0...6.5),
                opacity: 1.0,
                life: 0,
                maxLife: Double.random(in: 0.18...0.45)
            )
            sparkParticles.append(p)
        }
    }

    func spawnBlood(x: Double, y: Double, count: Int, dir: Double, power: Double) {
        let n = max(1, min(35, count))
        for _ in 0..<n {
            let baseAngle = dir < 0 ? .pi : 0.0
            let angle = baseAngle + Double.random(in: -0.85...0.85)
            let speed = Double.random(in: 120...420) * power
            let p = BloodParticle(
                x: x, y: y,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 140.0,
                size: Double.random(in: 3.0...8.5),
                opacity: 0.95,
                life: 0,
                maxLife: Double.random(in: 0.4...0.9)
            )
            bloodParticles.append(p)
        }
    }

    func spawnDust(x: Double, y: Double, count: Int, scale: Double = 1.0) {
        let n = max(1, min(20, count))
        for _ in 0..<n {
            let p = DustParticle(
                x: x + Double.random(in: -15...15),
                y: y + Double.random(in: -4...4),
                vx: Double.random(in: -70...70) * scale,
                vy: Double.random(in: -35...(-10)) * scale,
                size: Double.random(in: 7.0...16.0) * scale,
                opacity: Double.random(in: 0.35...0.65),
                life: 0,
                maxLife: Double.random(in: 0.35...0.7)
            )
            dustParticles.append(p)
        }
    }

    func addStain(x: Double, y: Double, r: Double) {
        if groundStains.count > 40 {
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
            let speed = hypot(p.vx, p.vy)
            let streakLen = max(3.0, min(22.0, speed * 0.04))
            let dirX = speed > 0.001 ? p.vx / speed : 1.0
            let dirY = speed > 0.001 ? p.vy / speed : 0.0

            var path = Path()
            path.move(to: CGPoint(x: p.x, y: p.y))
            path.addLine(to: CGPoint(x: p.x - dirX * streakLen, y: p.y - dirY * streakLen))

            let colGlow = Color(red: 1.0, green: 0.75, blue: 0.25, opacity: p.opacity)
            let colCore = Color.white.opacity(p.opacity)

            context.drawLayer { ctx in
                ctx.addFilter(.blur(radius: 2.0))
                ctx.stroke(path, with: .color(colGlow), style: StrokeStyle(lineWidth: p.size + 1.5, lineCap: .round))
            }
            context.stroke(path, with: .color(colCore), style: StrokeStyle(lineWidth: p.size * 0.6, lineCap: .round))
        }
    }

    func drawBlood(in context: GraphicsContext) {
        let bloodCol = Color(red: 0.54, green: 0.03, blue: 0.03)
        for p in bloodParticles {
            let speed = hypot(p.vx, p.vy)
            if speed > 80.0 {
                var path = Path()
                let dirX = p.vx / speed
                let dirY = p.vy / speed
                let len = min(14.0, p.size + speed * 0.02)
                path.move(to: CGPoint(x: p.x, y: p.y))
                path.addLine(to: CGPoint(x: p.x - dirX * len, y: p.y - dirY * len))
                context.stroke(path, with: .color(bloodCol.opacity(p.opacity)), style: StrokeStyle(lineWidth: p.size * 0.85, lineCap: .round))
            } else {
                let rect = CGRect(x: p.x - p.size / 2.0, y: p.y - p.size / 2.0, width: p.size, height: p.size)
                context.fill(Path(ellipseIn: rect), with: .color(bloodCol.opacity(p.opacity)))
            }
        }
    }

    func drawDust(in context: GraphicsContext) {
        let dustCol = Color(red: 0.55, green: 0.48, blue: 0.42)
        for p in dustParticles {
            let rect = CGRect(x: p.x - p.size / 2.0, y: p.y - p.size * 0.4, width: p.size, height: p.size * 0.8)
            context.drawLayer { ctx in
                ctx.addFilter(.blur(radius: 3.0))
                ctx.fill(Path(ellipseIn: rect), with: .color(dustCol.opacity(p.opacity)))
            }
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
