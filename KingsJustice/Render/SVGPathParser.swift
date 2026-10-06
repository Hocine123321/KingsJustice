import SwiftUI

struct SVGPathParser {
    static func parsePath(d: String) -> Path {
        var path = Path()
        let tokens = tokenize(d)
        var idx = 0

        var currentPoint = CGPoint.zero
        var subpathStart = CGPoint.zero
        var lastControlPoint: CGPoint? = nil
        var lastCommand: Character? = nil

        while idx < tokens.count {
            let token = tokens[idx]
            guard let firstChar = token.first, firstChar.isLetter else {
                idx += 1
                continue
            }

            let command = firstChar
            idx += 1

            switch command {
            case "M", "m":
                let isRel = (command == "m")
                var isFirst = true
                while idx + 1 < tokens.count, let x = Double(tokens[idx]), let y = Double(tokens[idx + 1]) {
                    idx += 2
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))
                    if isFirst {
                        path.move(to: target)
                        subpathStart = target
                        isFirst = false
                    } else {
                        path.addLine(to: target)
                    }
                    currentPoint = target
                    lastControlPoint = nil
                }

            case "L", "l":
                let isRel = (command == "l")
                while idx + 1 < tokens.count, let x = Double(tokens[idx]), let y = Double(tokens[idx + 1]) {
                    idx += 2
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))
                    path.addLine(to: target)
                    currentPoint = target
                    lastControlPoint = nil
                }

            case "H", "h":
                let isRel = (command == "h")
                while idx < tokens.count, let x = Double(tokens[idx]) {
                    idx += 1
                    let targetX = isRel ? currentPoint.x + Double(x) : Double(x)
                    let target = CGPoint(x: targetX, y: currentPoint.y)
                    path.addLine(to: target)
                    currentPoint = target
                    lastControlPoint = nil
                }

            case "V", "v":
                let isRel = (command == "v")
                while idx < tokens.count, let y = Double(tokens[idx]) {
                    idx += 1
                    let targetY = isRel ? currentPoint.y + Double(y) : Double(y)
                    let target = CGPoint(x: currentPoint.x, y: targetY)
                    path.addLine(to: target)
                    currentPoint = target
                    lastControlPoint = nil
                }

            case "C", "c":
                let isRel = (command == "c")
                while idx + 5 < tokens.count,
                      let x1 = Double(tokens[idx]), let y1 = Double(tokens[idx + 1]),
                      let x2 = Double(tokens[idx + 2]), let y2 = Double(tokens[idx + 3]),
                      let x = Double(tokens[idx + 4]), let y = Double(tokens[idx + 5]) {
                    idx += 6
                    let cp1 = isRel ? CGPoint(x: currentPoint.x + Double(x1), y: currentPoint.y + Double(y1)) : CGPoint(x: Double(x1), y: Double(y1))
                    let cp2 = isRel ? CGPoint(x: currentPoint.x + Double(x2), y: currentPoint.y + Double(y2)) : CGPoint(x: Double(x2), y: Double(y2))
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))

                    path.addCurve(to: target, control1: cp1, control2: cp2)
                    currentPoint = target
                    lastControlPoint = cp2
                }

            case "S", "s":
                let isRel = (command == "s")
                while idx + 3 < tokens.count,
                      let x2 = Double(tokens[idx]), let y2 = Double(tokens[idx + 1]),
                      let x = Double(tokens[idx + 2]), let y = Double(tokens[idx + 3]) {
                    idx += 4
                    let cp2 = isRel ? CGPoint(x: currentPoint.x + Double(x2), y: currentPoint.y + Double(y2)) : CGPoint(x: Double(x2), y: Double(y2))
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))

                    let cp1: CGPoint
                    if let lastCmd = lastCommand, (lastCmd == "C" || lastCmd == "c" || lastCmd == "S" || lastCmd == "s"), let lastCP = lastControlPoint {
                        cp1 = CGPoint(x: 2 * currentPoint.x - lastCP.x, y: 2 * currentPoint.y - lastCP.y)
                    } else {
                        cp1 = currentPoint
                    }

                    path.addCurve(to: target, control1: cp1, control2: cp2)
                    currentPoint = target
                    lastControlPoint = cp2
                }

            case "Q", "q":
                let isRel = (command == "q")
                while idx + 3 < tokens.count,
                      let x1 = Double(tokens[idx]), let y1 = Double(tokens[idx + 1]),
                      let x = Double(tokens[idx + 2]), let y = Double(tokens[idx + 3]) {
                    idx += 4
                    let cp = isRel ? CGPoint(x: currentPoint.x + Double(x1), y: currentPoint.y + Double(y1)) : CGPoint(x: Double(x1), y: Double(y1))
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))

                    path.addQuadCurve(to: target, control: cp)
                    currentPoint = target
                    lastControlPoint = cp
                }

            case "T", "t":
                let isRel = (command == "t")
                while idx + 1 < tokens.count,
                      let x = Double(tokens[idx]), let y = Double(tokens[idx + 1]) {
                    idx += 2
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))

                    let cp: CGPoint
                    if let lastCmd = lastCommand, (lastCmd == "Q" || lastCmd == "q" || lastCmd == "T" || lastCmd == "t"), let lastCP = lastControlPoint {
                        cp = CGPoint(x: 2 * currentPoint.x - lastCP.x, y: 2 * currentPoint.y - lastCP.y)
                    } else {
                        cp = currentPoint
                    }

                    path.addQuadCurve(to: target, control: cp)
                    currentPoint = target
                    lastControlPoint = cp
                }

            case "A", "a":
                let isRel = (command == "a")
                while idx + 6 < tokens.count,
                      let rx = Double(tokens[idx]),
                      let ry = Double(tokens[idx + 1]),
                      let rot = Double(tokens[idx + 2]),
                      let largeArc = Double(tokens[idx + 3]),
                      let sweep = Double(tokens[idx + 4]),
                      let x = Double(tokens[idx + 5]),
                      let y = Double(tokens[idx + 6]) {
                    idx += 7
                    let target = isRel ? CGPoint(x: currentPoint.x + Double(x), y: currentPoint.y + Double(y)) : CGPoint(x: Double(x), y: Double(y))

                    addArcToBeziers(
                        path: &path,
                        start: currentPoint,
                        rx: rx,
                        ry: ry,
                        xAxisRotation: rot,
                        largeArcFlag: (largeArc != 0),
                        sweepFlag: (sweep != 0),
                        end: target
                    )
                    currentPoint = target
                    lastControlPoint = nil
                }

            case "Z", "z":
                path.closeSubpath()
                currentPoint = subpathStart
                lastControlPoint = nil

            default:
                break
            }

            lastCommand = command
        }

        return path
    }

    private static func tokenize(_ d: String) -> [String] {
        var result: [String] = []
        var currentToken = ""

        var chars = Array(d)
        var i = 0

        while i < chars.count {
            let c = chars[i]

            if c.isLetter {
                if !currentToken.isEmpty {
                    result.append(currentToken)
                    currentToken = ""
                }
                result.append(String(c))
            } else if c == "," || c.isWhitespace {
                if !currentToken.isEmpty {
                    result.append(currentToken)
                    currentToken = ""
                }
            } else if c == "-" {
                // Check if this '-' is exponent e.g. e-5 or E-5
                var isExp = false
                if i > 0 {
                    let prev = chars[i - 1]
                    if prev == "e" || prev == "E" {
                        isExp = true
                    }
                }

                if isExp {
                    currentToken.append(c)
                } else {
                    if !currentToken.isEmpty {
                        result.append(currentToken)
                        currentToken = ""
                    }
                    currentToken.append(c)
                }
            } else {
                currentToken.append(c)
            }
            i += 1
        }

        if !currentToken.isEmpty {
            result.append(currentToken)
        }

        return result
    }

    private static func addArcToBeziers(
        path: inout Path,
        start: CGPoint,
        rx inRx: Double,
        ry inRy: Double,
        xAxisRotation: Double,
        largeArcFlag: Bool,
        sweepFlag: Bool,
        end: CGPoint
    ) {
        let x0 = Double(start.x)
        let y0 = Double(start.y)
        let x1 = Double(end.x)
        let y1 = Double(end.y)

        if x0 == x1 && y0 == y1 { return }

        var rx = abs(inRx)
        var ry = abs(inRy)

        if rx == 0 || ry == 0 {
            path.addLine(to: end)
            return
        }

        let phi = xAxisRotation * .pi / 180.0
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)

        let dx = (x0 - x1) / 2.0
        let dy = (y0 - y1) / 2.0
        let x1p = cosPhi * dx + sinPhi * dy
        let y1p = -sinPhi * dx + cosPhi * dy

        var rxSq = rx * rx
        var rySq = ry * ry
        let x1pSq = x1p * x1p
        let y1pSq = y1p * y1p

        let lambda = x1pSq / rxSq + y1pSq / rySq
        if lambda > 1.0 {
            let sqrtLambda = sqrt(lambda)
            rx *= sqrtLambda
            ry *= sqrtLambda
            rxSq = rx * rx
            rySq = ry * ry
        }

        var num = rxSq * rySq - rxSq * y1pSq - rySq * x1pSq
        if num < 0 { num = 0 }
        let den = rxSq * y1pSq + rySq * x1pSq
        var s = den > 0 ? sqrt(num / den) : 0.0
        if largeArcFlag == sweepFlag {
            s = -s
        }

        let cxp = s * (rx * y1p / ry)
        let cyp = s * (-ry * x1p / rx)

        let cx = cosPhi * cxp - sinPhi * cyp + (x0 + x1) / 2.0
        let cy = sinPhi * cxp + cosPhi * cyp + (y0 + y1) / 2.0

        func vectorAngle(uX: Double, uY: Double, vX: Double, vY: Double) -> Double {
            let dot = uX * vX + uY * vY
            let lenU = sqrt(uX * uX + uY * uY)
            let lenV = sqrt(vX * vX + vY * vY)
            guard lenU > 0 && lenV > 0 else { return 0 }
            var val = dot / (lenU * lenV)
            val = max(-1.0, min(1.0, val))
            let angle = acos(val)
            return (uX * vY - uY * vX) < 0 ? -angle : angle
        }

        let v1X = (x1p - cxp) / rx
        let v1Y = (y1p - cyp) / ry
        let v2X = (-x1p - cxp) / rx
        let v2Y = (-y1p - cyp) / ry

        let theta1 = vectorAngle(uX: 1.0, uY: 0.0, vX: v1X, vY: v1Y)
        var dTheta = vectorAngle(uX: v1X, uY: v1Y, vX: v2X, vY: v2Y)

        if !sweepFlag && dTheta > 0 {
            dTheta -= 2.0 * .pi
        } else if sweepFlag && dTheta < 0 {
            dTheta += 2.0 * .pi
        }

        let segments = Int(ceil(abs(dTheta) / (.pi / 2.0)))
        let delta = dTheta / Double(max(1, segments))
        let t = 8.0 / 3.0 * sin(delta / 4.0) * sin(delta / 4.0) / sin(delta / 2.0)

        var currentTheta = theta1
        for _ in 0..<segments {
            let nextTheta = currentTheta + delta
            let cosTheta = cos(currentTheta)
            let sinTheta = sin(currentTheta)
            let cosNextTheta = cos(nextTheta)
            let sinNextTheta = sin(nextTheta)

            let e1X = cxp + rx * (cosTheta - t * sinTheta)
            let e1Y = cyp + ry * (sinTheta + t * cosTheta)

            let e2X = cxp + rx * (cosNextTheta + t * sinNextTheta)
            let e2Y = cyp + ry * (sinNextTheta - t * cosNextTheta)

            let e3X = cxp + rx * cosNextTheta
            let e3Y = cyp + ry * sinNextTheta

            let cp1X = cosPhi * e1X - sinPhi * e1Y + cx
            let cp1Y = sinPhi * e1X + cosPhi * e1Y + cy

            let cp2X = cosPhi * e2X - sinPhi * e2Y + cx
            let cp2Y = sinPhi * e2X + cosPhi * e2Y + cy

            let p3X = cosPhi * e3X - sinPhi * e3Y + cx
            let p3Y = sinPhi * e3X + cosPhi * e3Y + cy

            path.addCurve(
                to: CGPoint(x: p3X, y: p3Y),
                control1: CGPoint(x: cp1X, y: cp1Y),
                control2: CGPoint(x: cp2X, y: cp2Y)
            )

            currentTheta = nextTheta
        }
    }
}
