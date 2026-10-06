import SwiftUI

struct GameSceneView<S: RenderSource & ObservableObject>: View {
    @ObservedObject var source: S
    @StateObject private var model = SceneModel()

    init(source: S) {
        self.source = source
    }

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let now: Double = timeline.date.timeIntervalSinceReferenceDate
                let time: Double = source.rsTime > 0 ? source.rsTime : now

                Canvas { context, size in
                    model.update(time: time, source: source)

                    let isPortrait = size.height > size.width
                    let scale: Double
                    let tx: Double
                    let ty: Double

                    if isPortrait {
                        scale = max(size.width / 900.0, size.height / 900.0)
                        tx = size.width / 2.0 - 660.0 * scale
                        ty = size.height * 0.35 - 480.0 * scale
                    } else {
                        scale = min(size.width / 1600.0, size.height / 900.0)
                        tx = (size.width - 1600.0 * scale) / 2.0
                        ty = (size.height - 900.0 * scale) / 2.0
                    }

                    // Camera Shake
                    let shake = source.rsShake
                    let sx = sin(time * 83.0) * shake * 14.0
                    let sy = cos(time * 71.0) * shake * 14.0
                    let sr = sin(time * 61.0) * shake * 0.01

                    context.drawLayer { sceneCtx in
                        sceneCtx.concatenate(CGAffineTransform(translationX: tx + sx, y: ty + sy))
                        sceneCtx.concatenate(CGAffineTransform(scaleX: scale, y: scale))
                        if sr != 0 {
                            sceneCtx.concatenate(CGAffineTransform(translationX: 800, y: 450))
                            sceneCtx.concatenate(CGAffineTransform(rotationAngle: sr))
                            sceneCtx.concatenate(CGAffineTransform(translationX: -800, y: -450))
                        }

                        let worldSize = CGSize(width: 1600, height: 900)

                        // 1. Baked Background (bg)
                        model.drawBgLayer(in: sceneCtx, size: worldSize)

                        // 2. Parallax Castle/Clouds (cl .62)
                        sceneCtx.drawLayer { clCtx in
                            let parallaxX = sin(time * 0.25) * 20.0
                            clCtx.concatenate(CGAffineTransform(translationX: parallaxX, y: 0))
                            model.drawClLayer(in: clCtx, size: worldSize)
                        }

                        // 3. Ground (gnd)
                        model.drawGndLayer(in: sceneCtx, size: worldSize)

                        // Ground Blood Stains
                        model.particleSystem.drawStains(in: sceneCtx)

                        // 4. Fighters
                        let playerLook = source.rsStyle.look
                        let playerConfig = FighterRigConfig.from(look: playerLook, facing: 1.0, id: "player")
                        let playerPose = source.rsPlayerPose.count >= 8 ? source.rsPlayerPose : [450.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]

                        FighterRig.draw(
                            in: sceneCtx,
                            config: playerConfig,
                            pose: playerPose,
                            time: time,
                            wound: source.rsWound
                        )

                        if let enemy = source.rsEnemy {
                            let enemyConfig = FighterRigConfig.from(look: enemy.look, facing: -1.0, id: enemy.id)
                            let enemyPose = source.rsEnemyPose.count >= 8 ? source.rsEnemyPose : [900.0, 0.0, -40.0, 45.0, 70.0, 0.0, 0.0, 0.0]

                            FighterRig.draw(
                                in: sceneCtx,
                                config: enemyConfig,
                                pose: enemyPose,
                                time: time,
                                wound: source.rsWound
                            )
                        }

                        // 5. Foreground (fg 1.5)
                        model.drawFgLayer(in: sceneCtx, size: worldSize)

                        // 6. Weather Particles
                        let arena = GameData.arenas[source.rsArenaKey]
                        let wType = arena?.weather.type ?? "embers"
                        let defCol = SVGColorParser.parseColor(arena?.weather.color ?? "#ffffff") ?? Color.white
                        model.particleSystem.drawWeather(in: sceneCtx, type: wType, defaultColor: defCol)

                        // Sparks and Blood
                        model.particleSystem.drawBlood(in: sceneCtx)
                        model.particleSystem.drawSparks(in: sceneCtx)

                        // 7. Torch light overlays
                        if let light = arena?.light {
                            let keyColor = SVGColorParser.parseColor(light.key) ?? Color.orange
                            let lightGrad = Gradient(stops: [
                                Gradient.Stop(color: keyColor.opacity(light.keyOp), location: 0.0),
                                Gradient.Stop(color: keyColor.opacity(0.0), location: 1.0)
                            ])

                            let rL = Path(ellipseIn: CGRect(x: light.keyLX - 450, y: light.keyLY - 450, width: 900, height: 900))
                            sceneCtx.fill(rL, with: .radialGradient(lightGrad, center: CGPoint(x: light.keyLX, y: light.keyLY), startRadius: 0, endRadius: 450))

                            let rR = Path(ellipseIn: CGRect(x: light.keyRX - 450, y: light.keyRY - 450, width: 900, height: 900))
                            sceneCtx.fill(rR, with: .radialGradient(lightGrad, center: CGPoint(x: light.keyRX, y: light.keyRY), startRadius: 0, endRadius: 450))
                        }

                        // Vignette
                        let vignetteGrad = Gradient(stops: [
                            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.6),
                            Gradient.Stop(color: Color.black.opacity(0.65), location: 1.0)
                        ])
                        sceneCtx.fill(Path(CGRect(x: 0, y: 0, width: 1600, height: 900)), with: .radialGradient(vignetteGrad, center: CGPoint(x: 800, y: 450), startRadius: 400, endRadius: 900))

                        // Hurt Flash Overlay
                        if source.rsHurt > 0 {
                            sceneCtx.fill(Path(CGRect(x: 0, y: 0, width: 1600, height: 900)), with: .color(Color.red.opacity(min(0.5, source.rsHurt))))
                        }

                        // Flash Screen Overlay
                        if source.rsFlash > 0 {
                            sceneCtx.fill(Path(CGRect(x: 0, y: 0, width: 1600, height: 900)), with: .color(Color.white.opacity(min(0.8, source.rsFlash))))
                        }

                        // 8. Rhythm Overlay
                        drawRhythmOverlay(in: sceneCtx, time: time)
                    }
                }
            }
        }
        .onAppear {
            model.updateArenaIfNeeded(arenaKey: source.rsArenaKey, arenaDef: GameData.arenas[source.rsArenaKey])
        }
    }

    private func drawRhythmOverlay(in context: GraphicsContext, time: Double) {
        let CW = 1600.0
        let CH = 900.0
        let perfectWin = source.rsStyle.windows.perfect

        if source.rsRoundIsDefend {
            // Defend Round Approach Rings
            let cx = CW * 0.44
            let cy = CH * 0.52
            let rEnd = CW * 0.045
            let rStart = CW * 0.17

            for event in source.rsEvents {
                guard event.state == "live" && event.kind != "note" else { continue }
                let tell = max(1.4, event.tellDone > 0 ? event.tellDone : 1.4) * (source.rsFocusActive ? 1.5 : 1.0)
                let d = event.time - time
                guard d <= tell && d >= -source.rsStyle.windows.miss else { continue }

                let u = max(0.0, min(1.0, 1.0 - d / tell))
                let r = rStart + (rEnd - rStart) * u

                let colHex = event.colorHex.isEmpty ? (INPUT_COL[event.input] ?? "#ffffff") : event.colorHex
                let col = SVGColorParser.parseColor(colHex) ?? Color.white
                let isPerfectNow = abs(d) < perfectWin

                context.drawLayer { ringCtx in
                    ringCtx.opacity = 0.25 + 0.75 * u

                    var style = StrokeStyle(lineWidth: 3.0 + u * 3.0)
                    if event.input == "dodge" {
                        style.dash = [10, 7]
                    }
                    if event.feint && !event.feintOk {
                        ringCtx.opacity *= (0.5 + 0.5 * sin(time * 30.0))
                        style.dash = [4, 6]
                    }

                    let ringPath = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2.0, height: r * 2.0))
                    let ringCol = isPerfectNow ? Color.white : col

                    ringCtx.drawLayer { glowCtx in
                        glowCtx.addFilter(.blur(radius: 8.0))
                        glowCtx.stroke(ringPath, with: .color(ringCol), style: style)
                    }
                    ringCtx.stroke(ringPath, with: .color(ringCol), style: style)

                    if event.input == "grab" {
                        let innerR = r * 0.82
                        let innerPath = Path(ellipseIn: CGRect(x: cx - innerR, y: cy - innerR, width: innerR * 2.0, height: innerR * 2.0))
                        ringCtx.stroke(innerPath, with: .color(ringCol), style: style)
                    }

                    // Target Hit Ring
                    let targetPath = Path(ellipseIn: CGRect(x: cx - rEnd, y: cy - rEnd, width: rEnd * 2.0, height: rEnd * 2.0))
                    ringCtx.stroke(targetPath, with: .color(Color(red: 0.76, green: 0.23, blue: 0.16)), style: StrokeStyle(lineWidth: 2.0))
                }
            }
        } else {
            // Attack Round Lanes & Sliding Notes
            let laneX = [CW * 0.30, CW * 0.50, CW * 0.70]
            let yH = CH * 0.82
            let yTop = CH * 0.16
            let trav = 2.0 * (source.rsFocusActive ? 1.5 : 1.0)

            let laneCols = [
                Color(red: 0.85, green: 0.71, blue: 0.35),
                Color(red: 0.78, green: 0.83, blue: 0.88),
                Color(red: 0.76, green: 0.23, blue: 0.16)
            ]

            for l in 0..<3 {
                let lx = laneX[l]
                let laneRect = CGRect(x: lx - CW * 0.045, y: yTop, width: CW * 0.09, height: yH - yTop)
                let laneGrad = Gradient(stops: [
                    Gradient.Stop(color: laneCols[l].opacity(0.0), location: 0.0),
                    Gradient.Stop(color: laneCols[l].opacity(0.33), location: 1.0)
                ])
                context.fill(Path(laneRect), with: .linearGradient(laneGrad, startPoint: CGPoint(x: lx, y: yTop), endPoint: CGPoint(x: lx, y: yH)))

                let targetCircle = Path(ellipseIn: CGRect(x: lx - CW * 0.032, y: yH - CW * 0.032, width: CW * 0.064, height: CW * 0.064))
                context.stroke(targetCircle, with: .color(laneCols[l].opacity(0.8)), style: StrokeStyle(lineWidth: 2.0))
            }

            for n in source.rsEvents {
                guard n.state == "live" && n.kind == "note" else { continue }
                let d = n.time - time
                guard d <= trav && d >= -source.rsStyle.windows.miss else { continue }

                let u = 1.0 - d / trav
                let y = yTop + (yH - yTop) * u
                let r = CW * (0.014 + 0.02 * u)

                var lx = laneX[min(2, max(0, n.lane))]
                if let flag = n.flag, (flag == "S+" || flag == "S-"), !n.shifted, let orig = n.origLane {
                    let to = max(0, min(2, orig + (flag == "S+" ? 1 : -1)))
                    let k = max(0.0, min(1.0, 1.0 - d / 0.35))
                    lx = laneX[orig] + (laneX[to] - laneX[orig]) * k
                }

                drawNoteShape(in: context, x: lx, y: y, r: r, note: n, col: laneCols[min(2, max(0, n.lane))])
            }
        }
    }

    private func drawNoteShape(in context: GraphicsContext, x: Double, y: Double, r: Double, note: RenderNote, col: Color) {
        context.drawLayer { ctx in
            ctx.concatenate(CGAffineTransform(translationX: x, y: y))

            let fillCol = note.flag == "P" ? Color(red: 0.5, green: 0.66, blue: 0.81) : col

            // Diamond note body
            var diamond = Path()
            diamond.move(to: CGPoint(x: 0, y: -r * 1.5))
            diamond.addLine(to: CGPoint(x: r, y: 0))
            diamond.addLine(to: CGPoint(x: 0, y: r * 1.5))
            diamond.addLine(to: CGPoint(x: -r, y: 0))
            diamond.closeSubpath()

            ctx.drawLayer { glowCtx in
                glowCtx.addFilter(.blur(radius: 6.0))
                glowCtx.fill(diamond, with: .color(fillCol))
            }
            ctx.fill(diamond, with: .color(fillCol))

            var innerDiamond = Path()
            innerDiamond.move(to: CGPoint(x: 0, y: -r * 0.7))
            innerDiamond.addLine(to: CGPoint(x: r * 0.45, y: 0))
            innerDiamond.addLine(to: CGPoint(x: 0, y: r * 0.7))
            innerDiamond.addLine(to: CGPoint(x: -r * 0.45, y: 0))
            innerDiamond.closeSubpath()
            ctx.fill(innerDiamond, with: .color(Color.black.opacity(0.35)))

            // Special flags
            if let flag = note.flag {
                if flag == "P" { // Shield ring
                    let pRing = Path(ellipseIn: CGRect(x: -r * 1.9, y: -r * 1.9, width: r * 3.8, height: r * 3.8))
                    ctx.stroke(pRing, with: .color(Color(red: 0.87, green: 0.94, blue: 1.0)), style: StrokeStyle(lineWidth: 2.5))
                } else if flag == "BH" || flag == "BL" { // Block bar
                    var bar = Path()
                    let py = flag == "BH" ? -r * 1.9 : r * 1.9
                    bar.move(to: CGPoint(x: -r * 1.5, y: py))
                    bar.addLine(to: CGPoint(x: r * 1.5, y: py))
                    ctx.stroke(bar, with: .color(Color(red: 0.62, green: 0.7, blue: 0.78)), style: StrokeStyle(lineWidth: 2.5))
                } else if flag == "A" || flag == "A2" || flag == "Ah" { // Armor box
                    let box = Path(CGRect(x: -r * 1.25, y: -r * 1.25, width: r * 2.5, height: r * 2.5))
                    ctx.stroke(box, with: .color(Color(red: 0.91, green: 0.91, blue: 0.91)), style: StrokeStyle(lineWidth: 2.5))
                } else if flag == "C" { // Counter cross
                    var cross = Path()
                    cross.move(to: CGPoint(x: -r * 1.6, y: 0))
                    cross.addLine(to: CGPoint(x: r * 1.6, y: 0))
                    cross.move(to: CGPoint(x: 0, y: -r * 1.6))
                    cross.addLine(to: CGPoint(x: 0, y: r * 1.6))
                    ctx.stroke(cross, with: .color(Color(red: 1.0, green: 0.41, blue: 0.29)), style: StrokeStyle(lineWidth: 2.5))
                }
            }
        }
    }

    private var INPUT_COL: [String: String] {
        [
            "parry": "#e8f2ff",
            "duck": "#f1d98e",
            "jump": "#bfe8cc",
            "dodge": "#ff5a3a",
            "grab": "#ff9a3a"
        ]
    }
}
