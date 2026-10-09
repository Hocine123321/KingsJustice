import SwiftUI

import CoreGraphics

/// Weapons were drawn oversized next to the fighters; this trims them while keeping the grip anchored.
fileprivate let weaponScale: Double = 0.86

struct FighterRigConfig: Sendable {
    let id: String
    let colors: [Color]       // [dark, mid, light]
    let colorHexes: [String]  // 3 hex colors
    let trim: Color
    let eye: Color
    let helm: String          // greathelm | horned | crown | hood | cowl | skull | bare
    let cape: String          // cloak | cloakK | rags | none
    let weapon: String        // longsword | greatsword | axe | mace | spear | scythe | twinblades
    let size: Double
    let shield: Bool
    let glow: Color?
    let facing: Double        // 1 = player right, -1 = enemy left
    let ph: Double            // phase offset
    let bigShoulders: Bool
    let spiked: Bool
    let shieldShape: String   // heater | round
    let emblem: String?       // cross | crown | skull | chains
    let emblemCol: Color?
    let plumeCol: Color?

    init(
        id: String = "fighter",
        colors: [Color] = [Color.black, Color.gray, Color.white],
        colorHexes: [String] = ["#0a0807", "#5d6877", "#a7b4c2"],
        trim: Color = Color(red: 0.85, green: 0.71, blue: 0.35),
        eye: Color = Color(red: 1, green: 0.23, blue: 0.23),
        helm: String = "greathelm",
        cape: String = "cloak",
        weapon: String = "longsword",
        size: Double = 1.0,
        shield: Bool = true,
        glow: Color? = nil,
        facing: Double = 1.0,
        ph: Double = 0.0,
        bigShoulders: Bool = false,
        spiked: Bool = false,
        shieldShape: String = "heater",
        emblem: String? = nil,
        emblemCol: Color? = nil,
        plumeCol: Color? = nil
    ) {
        self.id = id
        self.colors = colors
        self.colorHexes = colorHexes
        self.trim = trim
        self.eye = eye
        self.helm = helm
        self.cape = cape
        self.weapon = weapon
        self.size = size
        self.shield = shield
        self.glow = glow
        self.facing = facing
        self.ph = ph
        self.bigShoulders = bigShoulders
        self.spiked = spiked
        self.shieldShape = shieldShape
        self.emblem = emblem
        self.emblemCol = emblemCol
        self.plumeCol = plumeCol
    }

    static func from(look: LookDef, facing: Double = 1.0, id: String = "fighter") -> FighterRigConfig {
        let hexes = look.colors.count >= 3 ? look.colors : ["#0a0807", "#5d6877", "#a7b4c2"]
        let c0 = SVGColorParser.parseColor(hexes[0]) ?? Color.black
        let c1 = SVGColorParser.parseColor(hexes[1]) ?? Color.gray
        let c2 = SVGColorParser.parseColor(hexes[2]) ?? Color.white
        let trimColor = SVGColorParser.parseColor(look.trim) ?? Color(red: 0.85, green: 0.71, blue: 0.35)
        let eyeColor = SVGColorParser.parseColor(look.eye) ?? Color.red
        let glowColor = look.glow != nil ? SVGColorParser.parseColor(look.glow!) : nil

        return FighterRigConfig(
            id: id,
            colors: [c0, c1, c2],
            colorHexes: hexes,
            trim: trimColor,
            eye: eyeColor,
            helm: look.helm,
            cape: look.cape,
            weapon: look.weapon,
            size: look.size,
            shield: look.shield,
            glow: glowColor,
            facing: facing,
            ph: facing < 0 ? 2.0 : 0.0
        )
    }
}

struct FighterRig {
    static func draw(
        in context: GraphicsContext,
        config: FighterRigConfig,
        pose: [Double],
        time: Double,
        wound: Double = 0.0
    ) {
        let p = pose.count >= 8 ? pose : [500.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]
        let rawX = p[0]
        let rawLean = p[1]
        let a1 = p[2]
        let a2 = p[3]
        let a3 = p[4]
        let s = p[5]
        let f = p[6]
        let cr = p[7]

        let sz = config.size
        let ph = config.ph

        // Richer idle sway (weight shift on x/lean, chest breathing, head bob)
        let swayX = sin(time * 1.8 + ph) * 3.5 * config.facing
        let idleLean = sin(time * 1.8 + ph + 0.4) * 1.2
        let x = rawX + swayX
        let lean = rawLean + idleLean

        let br = sin(time * 2.3 + ph) * 3.2
        let w = sin(time * 1.7 + ph) * 2.2
        let dy = 715.0 + f * 20.0 + cr * sz

        // Base Body Gradients with SOLID FALLBACK color
        let C = config.colors
        let hexes = config.colorHexes
        let gradHex0 = SVGColorParser.shadeHex(hexes.indices.contains(2) ? hexes[2] : "#a7b4c2", 0.1)
        let gradHex1 = hexes.indices.contains(1) ? hexes[1] : "#5d6877"
        let gradHex2 = hexes.indices.contains(0) ? hexes[0] : "#232930"
        let gradHex3 = SVGColorParser.shadeHex(hexes.indices.contains(1) ? hexes[1] : "#5d6877", -0.2)

        let bodyGradColors: [Color] = [
            SVGColorParser.parseColor(gradHex0) ?? C[2],
            SVGColorParser.parseColor(gradHex1) ?? C[1],
            SVGColorParser.parseColor(gradHex2) ?? C[0],
            SVGColorParser.parseColor(gradHex3) ?? C[1]
        ]
        let fallbackBodyColor = C[1]

        // 1. Ground Contact Shadow (scales with jump height / crouch)
        let shadowCx = x - (config.facing > 0 ? f * 160.0 : 0.0)
        let jumpHeight = max(0.0, -cr * sz)
        let crouchDepth = max(0.0, cr * sz)
        let shadowScale = max(0.22, min(1.3, 1.0 - jumpHeight / 140.0 + crouchDepth / 220.0))
        let shadowOpacity = max(0.12, min(0.75, 0.6 * (1.0 - jumpHeight / 160.0) + crouchDepth / 180.0))

        let shadowRx = (78.0 + f * 120.0) * sz * shadowScale
        let shadowRy = 13.0 * shadowScale
        let shadowRect = CGRect(x: shadowCx - shadowRx, y: 714.0 - shadowRy, width: shadowRx * 2.0, height: shadowRy * 2.0)
        let shadowPath = Path(ellipseIn: shadowRect)

        _ = shadowPath
        Atmosphere.softGlow(in: context, center: CGPoint(x: shadowCx, y: 714.0), rx: shadowRx * 1.15, ry: shadowRy * 1.25, color: Color.black, opacity: shadowOpacity)

        // Main Fighter Layer
        context.drawLayer { ctx in
            // Root Transform
            ctx.concatenate(CGAffineTransform(translationX: x, y: dy))
            ctx.concatenate(CGAffineTransform(scaleX: config.facing, y: 1.0))
            if f != 0 {
                ctx.concatenate(CGAffineTransform(rotationAngle: -f * 88.0 * .pi / 180.0))
            }

            // Glow Aura
            if let glowCol = config.glow {
                Atmosphere.softGlow(in: ctx, center: CGPoint(x: 0, y: -230), rx: 150.0, ry: 235.0, color: glowCol, opacity: 0.16)
            }

            // Cape (secondary motion with lag)
            if config.cape != "none" {
                var lPath = Path()
                let cl = 230.0
                let cw = config.cape == "rags" ? 7.0 : 6.0
                let wv = config.cape == "rags" ? 5.5 : 3.8

                var leftPts: [CGPoint] = []
                var rightPts: [CGPoint] = []

                for i in 0...6 {
                    let fi = Double(i)
                    let py = -316.0 + fi * cl / 6.0
                    let lagTime = time - fi * 0.08
                    let k = sin(lagTime * 2.3 + ph) * fi * wv + cos(lagTime * 3.2 + ph) * (fi * 1.2) - lean * (fi * 0.5)
                    leftPts.append(CGPoint(x: -30.0 - fi * cw + k, y: py))
                    rightPts.append(CGPoint(x: 26.0 - fi * cw * 0.4 + k, y: py))
                }

                lPath.move(to: leftPts[0])
                for pt in leftPts.dropFirst() { lPath.addLine(to: pt) }
                for pt in rightPts.reversed() { lPath.addLine(to: pt) }
                lPath.closeSubpath()

                let capeFillCol = config.cape == "rags" ? Color(red: 0.1, green: 0.08, blue: 0.07) : (config.cape == "cloakK" ? Color(red: 0.1, green: 0.12, blue: 0.15) : Color(red: 0.22, green: 0.04, blue: 0.05))
                ctx.fill(lPath, with: .color(capeFillCol))
                ctx.stroke(lPath, with: .color(Color.black), style: StrokeStyle(lineWidth: 1.5))
            }

            // Scale by size
            ctx.drawLayer { bodyCtx in
                if sz != 1.0 {
                    bodyCtx.concatenate(CGAffineTransform(scaleX: sz, y: sz))
                }

                // Legs
                let st = sin(x * 0.07) * 10.0
                let kn = cr * 0.5

                var leg0 = Path()
                leg0.move(to: CGPoint(x: 0, y: -165.0 + br))
                leg0.addLine(to: CGPoint(x: 18.0 + st + kn, y: -84.0 + cr * 0.4))
                leg0.addLine(to: CGPoint(x: 30.0 + st * 1.6, y: 0))

                var leg1 = Path()
                leg1.move(to: CGPoint(x: 0, y: -165.0 + br))
                leg1.addLine(to: CGPoint(x: -15.0 - st - kn, y: -82.0 + cr * 0.4))
                leg1.addLine(to: CGPoint(x: -34.0 - st * 1.6, y: 0))

                drawLimb(in: bodyCtx, path: leg0, colors: C, width: 30.0)
                drawLimb(in: bodyCtx, path: leg1, colors: C, width: 30.0)

                // Upper Body Group
                bodyCtx.drawLayer { upCtx in
                    upCtx.concatenate(CGAffineTransform(translationX: 0, y: -165.0))
                    upCtx.concatenate(CGAffineTransform(rotationAngle: lean * .pi / 180.0))
                    upCtx.concatenate(CGAffineTransform(translationX: 0, y: 165.0))

                    // Torso
                    var torsoPath = Path()
                    torsoPath.move(to: CGPoint(x: -38, y: -316.0 + br))
                    torsoPath.addQuadCurve(to: CGPoint(x: 38, y: -316.0 + br), control: CGPoint(x: 0, y: -332.0 + br))
                    torsoPath.addLine(to: CGPoint(x: 31, y: -254.0))
                    torsoPath.addLine(to: CGPoint(x: 24, y: -168.0))
                    torsoPath.addLine(to: CGPoint(x: -24, y: -168.0))
                    torsoPath.addLine(to: CGPoint(x: -31, y: -254.0))
                    torsoPath.closeSubpath()

                    // Solid Fallback + Linear Gradient
                    upCtx.fill(torsoPath, with: .color(fallbackBodyColor))
                    let torsoBbox = torsoPath.boundingRect
                    let torsoShading = GraphicsContext.Shading.linearGradient(
                        Gradient(stops: bodyGradColors.enumerated().map { Gradient.Stop(color: $0.element, location: Double($0.offset) / 3.0) }),
                        startPoint: CGPoint(x: torsoBbox.minX, y: torsoBbox.minY),
                        endPoint: CGPoint(x: torsoBbox.maxX, y: torsoBbox.maxY)
                    )
                    upCtx.fill(torsoPath, with: torsoShading)
                    upCtx.stroke(torsoPath, with: .color(config.trim), style: StrokeStyle(lineWidth: 2.5))

                    // Trim bar
                    var trimBar = Path()
                    trimBar.move(to: CGPoint(x: -24, y: -186))
                    trimBar.addLine(to: CGPoint(x: 24, y: -186))
                    upCtx.stroke(trimBar, with: .color(config.trim), style: StrokeStyle(lineWidth: 6.0))

                    // Chest emblem
                    if let emblem = config.emblem {
                        let eCol = config.emblemCol ?? Color(red: 0.48, green: 0.07, blue: 0.07)
                        if emblem == "cross" {
                            var ePath = Path()
                            ePath.move(to: CGPoint(x: 0, y: -300))
                            ePath.addLine(to: CGPoint(x: 0, y: -170))
                            ePath.move(to: CGPoint(x: -22, y: -262))
                            ePath.addLine(to: CGPoint(x: 22, y: -262))
                            upCtx.stroke(ePath, with: .color(eCol.opacity(0.6)), style: StrokeStyle(lineWidth: 5.0))
                        } else if emblem == "crown" {
                            var ePath = Path()
                            ePath.move(to: CGPoint(x: -14, y: -300))
                            ePath.addLine(to: CGPoint(x: 0, y: -240))
                            ePath.addLine(to: CGPoint(x: 14, y: -300))
                            upCtx.stroke(ePath, with: .color(Color(red: 0.48, green: 0.05, blue: 0.05).opacity(0.8)), style: StrokeStyle(lineWidth: 3.0))
                        } else if emblem == "skull" {
                            let skullRect = CGRect(x: -11, y: -273, width: 22, height: 22)
                            upCtx.fill(Path(ellipseIn: skullRect), with: .color(Color(red: 0.84, green: 0.8, blue: 0.72).opacity(0.75)))
                            upCtx.fill(Path(CGRect(x: -6, y: -256, width: 12, height: 9)), with: .color(Color(red: 0.84, green: 0.8, blue: 0.72).opacity(0.75)))
                            upCtx.fill(Path(ellipseIn: CGRect(x: -6.6, y: -266.6, width: 5.2, height: 5.2)), with: .color(Color.black))
                            upCtx.fill(Path(ellipseIn: CGRect(x: 1.4, y: -266.6, width: 5.2, height: 5.2)), with: .color(Color.black))
                        }
                    }

                    // Pauldrons
                    let pw = config.bigShoulders ? 46.0 : 38.0
                    for side in [-1.0, 1.0] {
                        let paRect = CGRect(x: side * pw - 22.0 * (config.bigShoulders ? 1.25 : 1.0), y: -314.0 + br - 16.0, width: 44.0 * (config.bigShoulders ? 1.25 : 1.0), height: 32.0)
                        let paPath = Path(ellipseIn: paRect)
                        upCtx.fill(paPath, with: .color(fallbackBodyColor))
                        upCtx.fill(paPath, with: torsoShading)
                        upCtx.stroke(paPath, with: .color(config.trim), style: StrokeStyle(lineWidth: 2.5))
                    }

                    // Head
                    upCtx.drawLayer { hdCtx in
                        let headBobY = sin(time * 2.3 + ph + 0.5) * 1.8
                        let headBobAngle = sin(time * 1.6 + ph) * 1.2 * .pi / 180.0
                        hdCtx.concatenate(CGAffineTransform(translationX: 0, y: br * 0.6 + headBobY))
                        hdCtx.concatenate(CGAffineTransform(translationX: 0, y: -320.0))
                        hdCtx.concatenate(CGAffineTransform(rotationAngle: (-lean * 0.25 * .pi / 180.0) + headBobAngle))
                        hdCtx.concatenate(CGAffineTransform(translationX: 0, y: 320.0))

                        let H = config.helm
                        if H == "greathelm" || H == "horned" || H == "crown" {
                            var hBase = Path()
                            hBase.move(to: CGPoint(x: -23, y: -322))
                            hBase.addLine(to: CGPoint(x: -24, y: -362))
                            hBase.addQuadCurve(to: CGPoint(x: 0, y: -386), control: CGPoint(x: -24, y: -386))
                            hBase.addQuadCurve(to: CGPoint(x: 24, y: -362), control: CGPoint(x: 24, y: -386))
                            hBase.addLine(to: CGPoint(x: 23, y: -322))
                            hBase.addQuadCurve(to: CGPoint(x: -23, y: -322), control: CGPoint(x: 0, y: -312))
                            hBase.closeSubpath()

                            hdCtx.fill(hBase, with: .color(fallbackBodyColor))
                            hdCtx.fill(hBase, with: torsoShading)
                            hdCtx.stroke(hBase, with: .color(config.trim), style: StrokeStyle(lineWidth: 2.5))

                            // Visor cross
                            var vCross = Path()
                            vCross.move(to: CGPoint(x: 0, y: -386))
                            vCross.addLine(to: CGPoint(x: 0, y: -322))
                            vCross.move(to: CGPoint(x: -23, y: -345))
                            vCross.addLine(to: CGPoint(x: 23, y: -345))
                            hdCtx.stroke(vCross, with: .color(config.trim.opacity(0.7)), style: StrokeStyle(lineWidth: 1.6))

                            // Visor slit
                            hdCtx.fill(Path(CGRect(x: -18, y: -360, width: 36, height: 7)), with: .color(Color(red: 0.01, green: 0.01, blue: 0.01)))

                            // Eyes
                            for ex in [-8.0, 8.0] {
                                let eyeRect = CGRect(x: ex - 2.1, y: -357.0 - 2.1, width: 4.2, height: 4.2)
                                hdCtx.fill(Path(ellipseIn: eyeRect), with: .color(config.eye))
                            }

                            if H == "horned" {
                                for side in [-1.0, 1.0] {
                                    var horn = Path()
                                    horn.move(to: CGPoint(x: side * 18, y: -370))
                                    horn.addQuadCurve(to: CGPoint(x: side * 44, y: -410), control: CGPoint(x: side * 36, y: -385))
                                    horn.addQuadCurve(to: CGPoint(x: side * 22, y: -364), control: CGPoint(x: side * 28, y: -390))
                                    horn.closeSubpath()

                                    hdCtx.fill(horn, with: .color(Color(red: 0.12, green: 0.11, blue: 0.11)))
                                    hdCtx.stroke(horn, with: .color(config.trim), style: StrokeStyle(lineWidth: 1.5))
                                }
                            } else if H == "crown" {
                                var crownPath = Path()
                                crownPath.move(to: CGPoint(x: -22, y: -380))
                                crownPath.addLine(to: CGPoint(x: -30, y: -418))
                                crownPath.addLine(to: CGPoint(x: -12, y: -398))
                                crownPath.addLine(to: CGPoint(x: 0, y: -425))
                                crownPath.addLine(to: CGPoint(x: 12, y: -398))
                                crownPath.addLine(to: CGPoint(x: 30, y: -418))
                                crownPath.addLine(to: CGPoint(x: 22, y: -380))
                                crownPath.closeSubpath()
                                hdCtx.fill(crownPath, with: .color(Color(red: 0.96, green: 0.85, blue: 0.52)))
                                hdCtx.stroke(crownPath, with: .color(Color(red: 0.16, green: 0.11, blue: 0.04)), style: StrokeStyle(lineWidth: 1.6))

                                let jewelRect = CGRect(x: -3.2, y: -403.2, width: 6.4, height: 6.4)
                                hdCtx.fill(Path(ellipseIn: jewelRect), with: .color(Color(red: 0.69, green: 0.08, blue: 0.08)))
                            }

                            if let plumeC = config.plumeCol {
                                var plumePath = Path()
                                plumePath.move(to: CGPoint(x: 0, y: -386))
                                plumePath.addQuadCurve(to: CGPoint(x: -52, y: -396), control: CGPoint(x: -24, y: -410))
                                plumePath.addQuadCurve(to: CGPoint(x: 0, y: -386), control: CGPoint(x: -26, y: -396))
                                plumePath.closeSubpath()

                                hdCtx.drawLayer { plumeCtx in
                                    let plumeAngle = (sin(time * 3.0) * 4.0 + lean * 0.5) * .pi / 180.0
                                    plumeCtx.concatenate(CGAffineTransform(translationX: 0, y: -386))
                                    plumeCtx.concatenate(CGAffineTransform(rotationAngle: plumeAngle))
                                    plumeCtx.concatenate(CGAffineTransform(translationX: 0, y: 386))

                                    plumeCtx.fill(plumePath, with: .color(plumeC))
                                    plumeCtx.stroke(plumePath, with: .color(Color(red: 0.16, green: 0.02, blue: 0.03)), style: StrokeStyle(lineWidth: 1.2))
                                }
                            }
                        } else if H == "hood" || H == "cowl" {
                            var hoodPath = Path()
                            hoodPath.move(to: CGPoint(x: -27, y: -318))
                            hoodPath.addLine(to: CGPoint(x: -30, y: -366))
                            hoodPath.addQuadCurve(to: CGPoint(x: 0, y: -398), control: CGPoint(x: -30, y: -396))
                            hoodPath.addQuadCurve(to: CGPoint(x: 30, y: -366), control: CGPoint(x: 30, y: -396))
                            hoodPath.addLine(to: CGPoint(x: 27, y: -318))
                            hoodPath.addQuadCurve(to: CGPoint(x: -27, y: -318), control: CGPoint(x: 0, y: -306))
                            hoodPath.closeSubpath()

                            let hoodFill = H == "cowl" ? Color(red: 0.1, green: 0.07, blue: 0.08) : fallbackBodyColor
                            hdCtx.fill(hoodPath, with: .color(hoodFill))
                            hdCtx.stroke(hoodPath, with: .color(Color.black), style: StrokeStyle(lineWidth: 2.0))

                            let faceRect = CGRect(x: -15, y: -370, width: 30, height: 40)
                            hdCtx.fill(Path(ellipseIn: faceRect), with: .color(Color(red: 0.02, green: 0.01, blue: 0.02)))

                            for ex in [-6.0, 6.0] {
                                let eyeRect = CGRect(x: ex - 2.4, y: -352.0 - 2.4, width: 4.8, height: 4.8)
                                hdCtx.fill(Path(ellipseIn: eyeRect), with: .color(config.eye))
                            }
                        } else {
                            // Bare head
                            let skinCol = Color(red: 0.72, green: 0.61, blue: 0.52)
                            var barePath = Path()
                            barePath.move(to: CGPoint(x: -20, y: -322))
                            barePath.addLine(to: CGPoint(x: -21, y: -358))
                            barePath.addQuadCurve(to: CGPoint(x: 0, y: -380), control: CGPoint(x: -21, y: -380))
                            barePath.addQuadCurve(to: CGPoint(x: 21, y: -358), control: CGPoint(x: 21, y: -380))
                            barePath.addLine(to: CGPoint(x: 20, y: -322))
                            barePath.addQuadCurve(to: CGPoint(x: -20, y: -322), control: CGPoint(x: 0, y: -313))
                            barePath.closeSubpath()

                            hdCtx.fill(barePath, with: .color(skinCol))
                            hdCtx.stroke(barePath, with: .color(Color(red: 0.16, green: 0.11, blue: 0.08)), style: StrokeStyle(lineWidth: 1.6))

                            for ex in [-7.0, 7.0] {
                                let eyeRect = CGRect(x: ex - 1.9, y: -354.0 - 1.9, width: 3.8, height: 3.8)
                                hdCtx.fill(Path(ellipseIn: eyeRect), with: .color(config.eye))
                            }
                        }
                    }

                    // Shield
                    if config.shield {
                        upCtx.drawLayer { shCtx in
                            shCtx.concatenate(CGAffineTransform(translationX: 42.0 + s * 12.0, y: -232.0 - s * 40.0 + br))
                            shCtx.concatenate(CGAffineTransform(rotationAngle: s * 8.0 * .pi / 180.0))

                            var shPath = Path()
                            if config.shieldShape == "round" {
                                shPath.move(to: CGPoint(x: -38, y: -30))
                                shPath.addQuadCurve(to: CGPoint(x: 0, y: -62), control: CGPoint(x: -38, y: -62))
                                shPath.addQuadCurve(to: CGPoint(x: 38, y: -30), control: CGPoint(x: 38, y: -62))
                                shPath.addQuadCurve(to: CGPoint(x: 0, y: 50), control: CGPoint(x: 38, y: 30))
                                shPath.addQuadCurve(to: CGPoint(x: -38, y: -30), control: CGPoint(x: -38, y: 30))
                                shPath.closeSubpath()
                            } else { // Heater
                                shPath.move(to: CGPoint(x: 0, y: -60))
                                shPath.addLine(to: CGPoint(x: 32, y: -45))
                                shPath.addLine(to: CGPoint(x: 30, y: 12))
                                shPath.addQuadCurve(to: CGPoint(x: 0, y: 72), control: CGPoint(x: 22, y: 50))
                                shPath.addQuadCurve(to: CGPoint(x: -30, y: 12), control: CGPoint(x: -22, y: 50))
                                shPath.addLine(to: CGPoint(x: -32, y: -45))
                                shPath.closeSubpath()
                            }

                            shCtx.fill(shPath, with: .color(fallbackBodyColor))
                            shCtx.fill(shPath, with: torsoShading)
                            shCtx.stroke(shPath, with: .color(Color(red: 0.03, green: 0.04, blue: 0.05)), style: StrokeStyle(lineWidth: 3.5))

                            var shDeco = Path()
                            shDeco.move(to: CGPoint(x: -30, y: -10))
                            shDeco.addLine(to: CGPoint(x: 30, y: -10))
                            shDeco.move(to: CGPoint(x: 0, y: -58))
                            shDeco.addLine(to: CGPoint(x: 0, y: 70))
                            shCtx.stroke(shDeco, with: .color((config.emblemCol ?? Color(red: 0.48, green: 0.09, blue: 0.09)).opacity(0.8)), style: StrokeStyle(lineWidth: 6.0))

                            let bossRect = CGRect(x: -9, y: -9, width: 18, height: 18)
                            shCtx.fill(Path(ellipseIn: bossRect), with: .color(Color(red: 0.96, green: 0.85, blue: 0.52)))

                            // Wound splat on shield
                            if wound > 0 {
                                shCtx.drawLayer { splatCtx in
                                    splatCtx.opacity = min(0.95, wound)
                                    let bloodCol = Color(red: 0.54, green: 0.03, blue: 0.03)
                                    for c in [(-6.0, -12.0, 30.0), (12.0, 14.0, 21.0), (-14.0, 30.0, 16.0), (16.0, -32.0, 12.0)] {
                                        let bRect = CGRect(x: c.0 - c.2, y: c.1 - c.2, width: c.2 * 2.0, height: c.2 * 2.0)
                                        splatCtx.fill(Path(ellipseIn: bRect), with: .color(bloodCol))
                                    }
                                }
                            }
                        }
                    }

                    // Main Arm & Weapon
                    let S = CGPoint(x: 20.0, y: -306.0 + br)
                    let Ee = P(S, a1, 70.0)
                    let Hh = P(Ee, a2, 66.0)

                    var armPath = Path()
                    armPath.move(to: S)
                    armPath.addLine(to: Ee)
                    armPath.addLine(to: Hh)
                    drawLimb(in: upCtx, path: armPath, colors: C, width: 21.0)

                    // Weapon Group
                    upCtx.drawLayer { swCtx in
                        swCtx.concatenate(CGAffineTransform(translationX: Hh.x, y: Hh.y))
                        let weaponAngle = -(a3 + w) * .pi / 180.0
                        swCtx.concatenate(CGAffineTransform(rotationAngle: weaponAngle))
                        swCtx.concatenate(CGAffineTransform(scaleX: weaponScale, y: weaponScale))

                        drawWeapon(in: swCtx, weapon: config.weapon)
                    }

                    // Off-hand weapon for twinblades
                    if config.weapon == "twinblades" {
                        let S2 = CGPoint(x: -18.0, y: -306.0 + br)
                        let E2 = P(S2, a1 * 0.6 - 10.0, 70.0)
                        let H2 = P(E2, a2 * 0.7 - 10.0, 66.0)

                        var armPath2 = Path()
                        armPath2.move(to: S2)
                        armPath2.addLine(to: E2)
                        armPath2.addLine(to: H2)
                        drawLimb(in: upCtx, path: armPath2, colors: C, width: 19.0)

                        upCtx.drawLayer { sw2Ctx in
                            sw2Ctx.concatenate(CGAffineTransform(translationX: H2.x, y: H2.y))
                            let weaponAngle2 = -(a3 * 0.8 + 20.0 + w) * .pi / 180.0
                            sw2Ctx.concatenate(CGAffineTransform(rotationAngle: weaponAngle2))
                            sw2Ctx.concatenate(CGAffineTransform(scaleX: weaponScale, y: weaponScale))

                            drawWeapon(in: sw2Ctx, weapon: "twinblades")
                        }
                    }
                }
            }
        }
    }

    static func weaponTip(config: FighterRigConfig, pose: [Double], time: Double) -> CGPoint {
        let p = pose.count >= 8 ? pose : [500.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]
        let rawX = p[0]
        let rawLean = p[1]
        let a1 = p[2]
        let a2 = p[3]
        let a3 = p[4]
        let f = p[6]
        let cr = p[7]

        let sz = config.size
        let ph = config.ph

        let swayX = sin(time * 1.8 + ph) * 3.5 * config.facing
        let idleLean = sin(time * 1.8 + ph + 0.4) * 1.2
        let x = rawX + swayX
        let lean = rawLean + idleLean

        let br = sin(time * 2.3 + ph) * 3.2
        let w = sin(time * 1.7 + ph) * 2.2
        let dy = 715.0 + f * 20.0 + cr * sz

        let tipLocalX: Double
        let tipLocalY: Double
        switch config.weapon {
        case "longsword": tipLocalX = 170.0; tipLocalY = 0.0
        case "greatsword": tipLocalX = 245.0; tipLocalY = 0.0
        case "axe": tipLocalX = 184.0; tipLocalY = -20.0
        case "mace": tipLocalX = 172.0; tipLocalY = 0.0
        case "spear": tipLocalX = 280.0; tipLocalY = 0.0
        case "scythe": tipLocalX = 290.0; tipLocalY = -20.0
        case "twinblades": tipLocalX = 145.0; tipLocalY = 0.0
        default: tipLocalX = 150.0; tipLocalY = 0.0
        }

        let S = CGPoint(x: 20.0, y: -306.0 + br)
        let Ee = P(S, a1, 70.0)
        let Hh = P(Ee, a2, 66.0)

        let weaponRad = -(a3 + w) * .pi / 180.0
        let wTipX = Hh.x + weaponScale * (tipLocalX * cos(weaponRad) - tipLocalY * sin(weaponRad))
        let wTipY = Hh.y + weaponScale * (tipLocalX * sin(weaponRad) + tipLocalY * cos(weaponRad))

        let leanRad = lean * .pi / 180.0
        let relY = wTipY + 165.0
        let torsoTipX = wTipX * cos(leanRad) - relY * sin(leanRad)
        let torsoTipY = -165.0 + wTipX * sin(leanRad) + relY * cos(leanRad)

        var bodyX = torsoTipX * sz
        var bodyY = torsoTipY * sz

        if f != 0 {
            let fRad = -f * 88.0 * .pi / 180.0
            let rx = bodyX * cos(fRad) - bodyY * sin(fRad)
            let ry = bodyX * sin(fRad) + bodyY * cos(fRad)
            bodyX = rx
            bodyY = ry
        }

        bodyX *= config.facing

        return CGPoint(x: x + bodyX, y: dy + bodyY)
    }

    private static func drawLimb(in context: GraphicsContext, path: Path, colors: [Color], width: Double) {
        let fallbackCol = colors.indices.contains(1) ? colors[1] : Color.gray
        let mainCol = colors.indices.contains(2) ? colors[2] : Color.white
        context.stroke(path, with: .color(fallbackCol), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(mainCol.opacity(0.85)), style: StrokeStyle(lineWidth: width * 0.65, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(Color.black), style: StrokeStyle(lineWidth: 2.2))
    }

    private static func P(_ origin: CGPoint, _ angleDeg: Double, _ length: Double) -> CGPoint {
        let rad = angleDeg * .pi / 180.0
        return CGPoint(
            x: Double(origin.x) + cos(rad) * length,
            y: Double(origin.y) - sin(rad) * length
        )
    }

    private static func drawWeapon(in context: GraphicsContext, weapon: String) {
        let bladeColor = Color(red: 0.6, green: 0.64, blue: 0.68)
        let goldColor = Color(red: 0.96, green: 0.85, blue: 0.52)
        let darkGrip = Color(red: 0.1, green: 0.07, blue: 0.04)

        func drawGrip() {
            let guardRect = CGRect(x: -4, y: -21, width: 9, height: 42)
            context.fill(Path(roundedRect: guardRect, cornerSize: CGSize(width: 2.5, height: 2.5)), with: .color(goldColor))
            let hiltRect = CGRect(x: -38, y: -4.5, width: 35, height: 9)
            context.fill(Path(hiltRect), with: .color(darkGrip))
            let pommelRect = CGRect(x: -46.5, y: -6.5, width: 13, height: 13)
            context.fill(Path(ellipseIn: pommelRect), with: .color(goldColor))
        }

        switch weapon {
        case "longsword", "twinblades":
            let L = weapon == "twinblades" ? 125.0 : 150.0
            var bPath = Path()
            bPath.move(to: CGPoint(x: 0, y: -5))
            bPath.addLine(to: CGPoint(x: L, y: -4))
            bPath.addLine(to: CGPoint(x: L + 20.0, y: 0))
            bPath.addLine(to: CGPoint(x: L, y: 4))
            bPath.addLine(to: CGPoint(x: 0, y: 5))
            bPath.closeSubpath()
            context.fill(bPath, with: .color(bladeColor))

            var fuller = Path()
            fuller.move(to: CGPoint(x: 12, y: 0))
            fuller.addLine(to: CGPoint(x: L - 10.0, y: 0))
            context.stroke(fuller, with: .color(Color.white.opacity(0.45)), style: StrokeStyle(lineWidth: 1.4))
            drawGrip()

        case "greatsword":
            let L = 215.0
            var bPath = Path()
            bPath.move(to: CGPoint(x: 0, y: -9))
            bPath.addLine(to: CGPoint(x: L, y: -8))
            bPath.addLine(to: CGPoint(x: L + 30.0, y: 0))
            bPath.addLine(to: CGPoint(x: L, y: 8))
            bPath.addLine(to: CGPoint(x: 0, y: 9))
            bPath.closeSubpath()
            context.fill(bPath, with: .color(bladeColor))
            context.stroke(bPath, with: .color(Color(red: 0.04, green: 0.05, blue: 0.06)), style: StrokeStyle(lineWidth: 1.2))

            var fuller = Path()
            fuller.move(to: CGPoint(x: 14, y: 0))
            fuller.addLine(to: CGPoint(x: L - 14.0, y: 0))
            context.stroke(fuller, with: .color(Color.white.opacity(0.4)), style: StrokeStyle(lineWidth: 2.0))

            let guardRect = CGRect(x: -8, y: -30, width: 12, height: 60)
            context.fill(Path(roundedRect: guardRect, cornerSize: CGSize(width: 3, height: 3)), with: .color(goldColor))
            let hiltRect = CGRect(x: -58, y: -5.5, width: 52, height: 11)
            context.fill(Path(hiltRect), with: .color(darkGrip))
            let pommelRect = CGRect(x: -68, y: -8, width: 16, height: 16)
            context.fill(Path(ellipseIn: pommelRect), with: .color(goldColor))

        case "axe":
            let L = 130.0
            let shaftRect = CGRect(x: -30, y: -4, width: L + 20.0, height: 8)
            context.fill(Path(roundedRect: shaftRect, cornerSize: CGSize(width: 2, height: 2)), with: .color(Color(red: 0.23, green: 0.16, blue: 0.1)))

            var head = Path()
            head.move(to: CGPoint(x: L - 20.0, y: -6))
            head.addQuadCurve(to: CGPoint(x: L + 54.0, y: -40), control: CGPoint(x: L + 22.0, y: -72))
            head.addQuadCurve(to: CGPoint(x: L + 8.0, y: -4), control: CGPoint(x: L + 40.0, y: -6))
            head.addLine(to: CGPoint(x: L - 20.0, y: -4))
            head.closeSubpath()
            context.fill(head, with: .color(bladeColor))
            context.stroke(head, with: .color(Color.black), style: StrokeStyle(lineWidth: 1.4))

        case "mace":
            let L = 125.0
            let shaftRect = CGRect(x: -30, y: -4.5, width: L + 10.0, height: 9)
            context.fill(Path(roundedRect: shaftRect, cornerSize: CGSize(width: 2, height: 2)), with: .color(Color(red: 0.16, green: 0.12, blue: 0.08)))

            let ballRect = CGRect(x: L - 3, y: -25, width: 50, height: 50)
            context.fill(Path(ellipseIn: ballRect), with: .color(bladeColor))
            context.stroke(Path(ellipseIn: ballRect), with: .color(Color.black), style: StrokeStyle(lineWidth: 2.0))

        case "spear":
            let L = 230.0
            let shaftRect = CGRect(x: -70, y: -3.5, width: L + 60.0, height: 7)
            context.fill(Path(roundedRect: shaftRect, cornerSize: CGSize(width: 2, height: 2)), with: .color(Color(red: 0.23, green: 0.16, blue: 0.1)))

            var tip = Path()
            tip.move(to: CGPoint(x: L - 10.0, y: -13))
            tip.addLine(to: CGPoint(x: L + 50.0, y: 0))
            tip.addLine(to: CGPoint(x: L - 10.0, y: 13))
            tip.addQuadCurve(to: CGPoint(x: L - 10.0, y: -13), control: CGPoint(x: L - 2.0, y: 0))
            tip.closeSubpath()
            context.fill(tip, with: .color(bladeColor))
            context.stroke(tip, with: .color(Color.black), style: StrokeStyle(lineWidth: 1.2))

        case "scythe":
            let L = 200.0
            let shaftRect = CGRect(x: -60, y: -3.5, width: L + 40.0, height: 7)
            context.fill(Path(roundedRect: shaftRect, cornerSize: CGSize(width: 2, height: 2)), with: .color(Color(red: 0.16, green: 0.12, blue: 0.09)))

            var blade = Path()
            blade.move(to: CGPoint(x: L - 4.0, y: -4))
            blade.addQuadCurve(to: CGPoint(x: L + 110.0, y: -34), control: CGPoint(x: L + 40.0, y: -70))
            blade.addQuadCurve(to: CGPoint(x: L + 10.0, y: 4), control: CGPoint(x: L + 50.0, y: -44))
            blade.closeSubpath()
            context.fill(blade, with: .color(bladeColor))
            context.stroke(blade, with: .color(Color.black), style: StrokeStyle(lineWidth: 1.4))

        default:
            drawGrip()
        }
    }
}
