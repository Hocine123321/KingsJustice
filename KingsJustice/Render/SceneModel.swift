import SwiftUI
import Combine

struct TrailPoint {
    let point: CGPoint
    let time: Double
    let speed: Double
}

@MainActor
final class SceneModel: ObservableObject {
    @Published var currentArenaKey: String = ""
    @Published var effectiveTime: Double = 0.0

    var bgImage: Image?
    var clImage: Image?
    var gndImage: Image?
    var fgImage: Image?

    var bgDoc: SVGDocument?
    var clDoc: SVGDocument?
    var gndDoc: SVGDocument?
    var fgDoc: SVGDocument?

    let particleSystem = ParticleSystem()
    var weaponTrails: [String: [TrailPoint]] = [:]

    private var lastRealTime: Double = 0.0
    private var lastTipPositions: [String: (CGPoint, Double)] = [:]
    private var rigConfigCache: [String: FighterRigConfig] = [:]

    /// Builds a fighter rig config once per distinct look and reuses it every frame.
    func rigConfig(look: LookDef, facing: Double, id: String) -> FighterRigConfig {
        let key = "\(id)|\(facing)|\(look.colors.joined(separator: ","))|\(look.helm)|\(look.cape)|\(look.weapon)"
        if let cached = rigConfigCache[key] { return cached }
        let cfg = FighterRigConfig.from(look: look, facing: facing, id: id)
        if rigConfigCache.count > 24 { rigConfigCache.removeAll() }
        rigConfigCache[key] = cfg
        return cfg
    }
    private var lastFighterPoses: [String: (cr: Double, x: Double)] = [:]

    init() {}

    func updateArenaIfNeeded(arenaKey: String, arenaDef: ArenaDef?) {
        guard arenaKey != currentArenaKey, let arena = arenaDef else { return }
        currentArenaKey = arenaKey

        // Parse Documents
        bgDoc = SVGDocument(markup: arena.bg)
        clDoc = SVGDocument(markup: arena.cl)
        gndDoc = SVGDocument(markup: arena.gnd)
        fgDoc = SVGDocument(markup: arena.fg)

        // Pre-render/Bake static layer bitmaps
        if let doc = bgDoc { bgImage = bakeLayer(doc) }
        if let doc = clDoc { clImage = bakeLayer(doc) }
        if let doc = gndDoc { gndImage = bakeLayer(doc) }
        if let doc = fgDoc { fgImage = bakeLayer(doc) }

        // Setup Weather
        particleSystem.setupWeather(
            type: arena.weather.type,
            count: arena.weather.count,
            color: arena.weather.color,
            wind: arena.weather.wind
        )
    }

    func update(time: Double, source: (any RenderSource)?) {
        let dtReal = lastRealTime > 0 ? max(0.001, min(0.1, time - lastRealTime)) : 0.016
        lastRealTime = time

        let isHitStop = source?.rsHitStop ?? false
        let dt = isHitStop ? dtReal * 0.05 : dtReal
        effectiveTime += dt
        let timeToUse = effectiveTime

        if let src = source {
            let fxList = src.rsDrainFX()
            for fx in fxList {
                switch fx {
                case .spark(let x, let y, let n):
                    particleSystem.spawnSpark(x: x, y: y, count: n)
                case .blood(let x, let y, let n, let dir, let power):
                    particleSystem.spawnBlood(x: x, y: y, count: n, dir: dir, power: power)
                case .stain(let x, let y, let r):
                    particleSystem.addStain(x: x, y: y, r: r)
                case .flashHurt:
                    break
                }
            }

            if let arenaKey = Optional(src.rsArenaKey), arenaKey != currentArenaKey {
                updateArenaIfNeeded(arenaKey: arenaKey, arenaDef: GameData.arenas[arenaKey])
            }

            let arena = GameData.arenas[currentArenaKey]
            let wType = arena?.weather.type ?? "embers"
            let wind = arena?.weather.wind ?? 1.0
            particleSystem.update(dt: dt, time: timeToUse, weatherType: wType, wind: wind)

            // Ground Dust Puffs on landing / heavy steps
            let pPose = src.rsPlayerPose
            if pPose.count >= 8 {
                let pCr = pPose[7]
                let pX = pPose[0]
                if let (oldCr, oldX) = lastFighterPoses["player"] {
                    if oldCr < -10.0 && pCr >= -2.0 { // Landed from jump
                        particleSystem.spawnDust(x: pX, y: 715.0, count: 14, scale: 1.3)
                    } else if abs(pX - oldX) > 30.0 { // Heavy step / lunge
                        particleSystem.spawnDust(x: pX, y: 715.0, count: 5, scale: 0.8)
                    }
                }
                lastFighterPoses["player"] = (cr: pCr, x: pX)
            }

            if let enemy = src.rsEnemy {
                let ePose = src.rsEnemyPose
                if ePose.count >= 8 {
                    let eCr = ePose[7]
                    let eX = ePose[0]
                    if let (oldCr, oldX) = lastFighterPoses["enemy"] {
                        if oldCr < -10.0 && eCr >= -2.0 {
                            particleSystem.spawnDust(x: eX, y: 715.0, count: 14, scale: 1.3)
                        } else if abs(eX - oldX) > 30.0 {
                            particleSystem.spawnDust(x: eX, y: 715.0, count: 5, scale: 0.8)
                        }
                    }
                    lastFighterPoses["enemy"] = (cr: eCr, x: eX)
                }
            }

            // Update Weapon Trails
            let pLook = src.rsStyle.look
            let pConfig = rigConfig(look: pLook, facing: 1.0, id: "player")
            let pTip = FighterRig.weaponTip(config: pConfig, pose: pPose, time: timeToUse)
            updateTrail(id: "player", tip: pTip, time: timeToUse)

            if let enemy = src.rsEnemy {
                let eConfig = rigConfig(look: enemy.look, facing: -1.0, id: enemy.id)
                let ePose = src.rsEnemyPose
                let eTip = FighterRig.weaponTip(config: eConfig, pose: ePose, time: timeToUse)
                updateTrail(id: "enemy", tip: eTip, time: timeToUse)
            }
        }
    }

    private func updateTrail(id: String, tip: CGPoint, time: Double) {
        if let (prevTip, prevT) = lastTipPositions[id] {
            let dt = max(0.001, time - prevT)
            let speed = hypot(tip.x - prevTip.x, tip.y - prevTip.y) / dt
            if speed > 280.0 {
                var list = weaponTrails[id] ?? []
                list.append(TrailPoint(point: tip, time: time, speed: speed))
                list = list.filter { time - $0.time < 0.14 }
                if list.count > 10 { list.removeFirst(list.count - 10) }
                weaponTrails[id] = list
            } else {
                if var list = weaponTrails[id], !list.isEmpty {
                    list = list.filter { time - $0.time < 0.14 }
                    weaponTrails[id] = list
                }
            }
        }
        lastTipPositions[id] = (tip, time)
    }

    func drawWeaponTrails(in context: GraphicsContext, primaryColor: Color = Color(red: 0.96, green: 0.85, blue: 0.52)) {
        for (_, points) in weaponTrails {
            guard points.count >= 2 else { continue }

            var path = Path()
            path.move(to: points[0].point)
            for i in 1..<points.count {
                let midX = (points[i-1].point.x + points[i].point.x) / 2.0
                let midY = (points[i-1].point.y + points[i].point.y) / 2.0
                path.addQuadCurve(to: points[i].point, control: CGPoint(x: midX, y: midY))
            }

            context.drawLayer { glowCtx in
                glowCtx.addFilter(.blur(radius: 5.0))
                glowCtx.stroke(path, with: .color(primaryColor.opacity(0.35)), style: StrokeStyle(lineWidth: 13.0, lineCap: .round, lineJoin: .round))
            }
            context.stroke(path, with: .color(primaryColor.opacity(0.65)), style: StrokeStyle(lineWidth: 6.5, lineCap: .round, lineJoin: .round))
            context.stroke(path, with: .color(Color.white.opacity(0.9)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
        }
    }

    private func bakeLayer(_ doc: SVGDocument) -> Image? {
        let layerView = Canvas { ctx, size in
            doc.draw(in: ctx, size: size)
        }
        .frame(width: 1600, height: 900)

        let renderer = ImageRenderer(content: layerView)
        renderer.scale = 1.0
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    func drawBgLayer(in context: GraphicsContext, size: CGSize) {
        if let img = bgImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = bgDoc {
            doc.draw(in: context, size: size)
        }
    }

    func drawClLayer(in context: GraphicsContext, size: CGSize) {
        if let img = clImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = clDoc {
            doc.draw(in: context, size: size)
        }
    }

    func drawGndLayer(in context: GraphicsContext, size: CGSize) {
        if let img = gndImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = gndDoc {
            doc.draw(in: context, size: size)
        }
    }

    func drawFgLayer(in context: GraphicsContext, size: CGSize) {
        if let img = fgImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = fgDoc {
            doc.draw(in: context, size: size)
        }
    }
}
