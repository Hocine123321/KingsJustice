import SwiftUI
import Foundation
import CoreGraphics

public final class SVGNode: @unchecked Sendable {
    public let tag: String
    public var attributes: [String: String]
    public var children: [SVGNode]

    public init(tag: String, attributes: [String: String] = [:], children: [SVGNode] = []) {
        self.tag = tag
        self.attributes = attributes
        self.children = children
    }
}

public struct SVGGradient: Sendable {
    public let id: String
    public let isRadial: Bool
    public let x1: Double
    public let y1: Double
    public let x2: Double
    public let y2: Double
    public let cx: Double
    public let cy: Double
    public let r: Double
    public let gradientUnits: String // "objectBoundingBox" | "userSpaceOnUse"
    public let stops: [Gradient.Stop]
}

public struct SVGClipPath: Sendable {
    public let id: String
    public let nodes: [SVGNode]
}

@MainActor
public final class SVGDefsRegistry {
    public static let shared = SVGDefsRegistry()

    public var gradients: [String: SVGGradient] = [:]
    public var clipPaths: [String: SVGClipPath] = [:]
    public var defNodes: [String: SVGNode] = [:]
    public var noiseImage: CGImage? = nil

    private init() {
        parseSharedDefs()
        noiseImage = SVGDefsRegistry.generateNoiseImage()
    }

    private func parseSharedDefs() {
        let doc = SVGDocument(markup: SharedSVGDefs.markup)
        for (k, v) in doc.localGradients { gradients[k] = v }
        for (k, v) in doc.localClipPaths { clipPaths[k] = v }
        for (k, v) in doc.localDefNodes { defNodes[k] = v }
    }

    public static func generateNoiseImage() -> CGImage? {
        let width = 128
        let height = 128
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        var seed: UInt64 = 12345
        func nextRandom() -> UInt8 {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return UInt8((seed >> 33) & 0xFF)
        }

        for y in 0..<height {
            for x in 0..<width {
                let idx = (y * width + x) * 4
                let val = nextRandom()
                pixels[idx] = val     // R
                pixels[idx + 1] = val // G
                pixels[idx + 2] = val // B
                pixels[idx + 3] = 40  // Alpha ~ 15%
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
}

public final class SVGDocument: @unchecked Sendable {
    public let rootNodes: [SVGNode]
    public var localGradients: [String: SVGGradient] = [:]
    public var localClipPaths: [String: SVGClipPath] = [:]
    public var localDefNodes: [String: SVGNode] = [:]

    public init(markup: String) {
        let parser = SVGFragmentParser(markup: markup)
        self.rootNodes = parser.rootNodes
        self.localGradients = parser.gradients
        self.localClipPaths = parser.clipPaths
        self.localDefNodes = parser.defNodes
    }

    public func draw(in context: GraphicsContext, size: CGSize) {
        let renderState = SVGRenderState()
        for node in rootNodes {
            drawNode(node, in: context, state: renderState)
        }
    }

    private func drawNode(_ node: SVGNode, in context: GraphicsContext, state: SVGRenderState) {
        if node.tag == "defs" || node.tag == "linearGradient" || node.tag == "radialGradient" || node.tag == "clipPath" {
            return
        }

        var newState = state
        updateState(&newState, with: node.attributes)

        context.drawLayer { ctx in
            if newState.opacity < 1.0 {
                ctx.opacity = newState.opacity
            }

            if !newState.transform.isIdentity {
                ctx.concatenate(newState.transform)
            }

            // Apply clipPath
            if let clipId = newState.clipPathId {
                applyClipPath(clipId, in: &ctx)
            }

            // Apply filter
            if let filterId = newState.filterId {
                applyFilter(filterId, node: node, in: ctx, state: newState)
            } else {
                renderNodeContent(node, in: ctx, state: newState)
            }
        }
    }

    private func renderNodeContent(_ node: SVGNode, in context: GraphicsContext, state: SVGRenderState) {
        switch node.tag {
        case "g":
            for child in node.children {
                drawNode(child, in: context, state: state)
            }

        case "rect":
            let x = Double(node.attributes["x"] ?? "0") ?? 0.0
            let y = Double(node.attributes["y"] ?? "0") ?? 0.0
            let w = Double(node.attributes["width"] ?? "0") ?? 0.0
            let h = Double(node.attributes["height"] ?? "0") ?? 0.0
            let rx = Double(node.attributes["rx"] ?? "0") ?? 0.0
            let ry = Double(node.attributes["ry"] ?? node.attributes["rx"] ?? "0") ?? 0.0

            let rect = CGRect(x: x, y: y, width: w, height: h)
            let path: Path
            if rx > 0 || ry > 0 {
                path = Path(roundedRect: rect, cornerSize: CGSize(width: rx, height: ry))
            } else {
                path = Path(rect)
            }
            drawPath(path, in: context, state: state)

        case "circle":
            let cx = Double(node.attributes["cx"] ?? "0") ?? 0.0
            let cy = Double(node.attributes["cy"] ?? "0") ?? 0.0
            let r = Double(node.attributes["r"] ?? "0") ?? 0.0
            let rect = CGRect(x: cx - r, y: cy - r, width: r * 2.0, height: r * 2.0)
            let path = Path(ellipseIn: rect)
            drawPath(path, in: context, state: state)

        case "ellipse":
            let cx = Double(node.attributes["cx"] ?? "0") ?? 0.0
            let cy = Double(node.attributes["cy"] ?? "0") ?? 0.0
            let rx = Double(node.attributes["rx"] ?? "0") ?? 0.0
            let ry = Double(node.attributes["ry"] ?? "0") ?? 0.0
            let rect = CGRect(x: cx - rx, y: cy - ry, width: rx * 2.0, height: ry * 2.0)
            let path = Path(ellipseIn: rect)
            drawPath(path, in: context, state: state)

        case "polygon":
            if let pointsStr = node.attributes["points"] {
                let coords = pointsStr.components(separatedBy: CharacterSet(charactersIn: " ,"))
                    .compactMap { Double($0) }
                var path = Path()
                if coords.count >= 2 {
                    path.move(to: CGPoint(x: coords[0], y: coords[1]))
                    var i = 2
                    while i + 1 < coords.count {
                        path.addLine(to: CGPoint(x: coords[i], y: coords[i + 1]))
                        i += 2
                    }
                    path.closeSubpath()
                    drawPath(path, in: context, state: state)
                }
            }

        case "path":
            if let d = node.attributes["d"] {
                let path = SVGPathParser.parsePath(d: d)
                drawPath(path, in: context, state: state)
            }

        case "use":
            let href = node.attributes["href"] ?? node.attributes["xlink:href"] ?? ""
            let id = href.hasPrefix("#") ? String(href.dropFirst()) : href
            if let refNode = lookupDefNode(id) {
                var useNode = SVGNode(tag: refNode.tag, attributes: refNode.attributes, children: refNode.children)
                for (k, v) in node.attributes {
                    if k != "href" && k != "xlink:href" && k != "id" {
                        useNode.attributes[k] = v
                    }
                }
                drawNode(useNode, in: context, state: state)
            }

        default:
            for child in node.children {
                drawNode(child, in: context, state: state)
            }
        }
    }

    private func drawPath(_ path: Path, in context: GraphicsContext, state: SVGRenderState) {
        // Fill
        switch state.fill {
        case .none:
            break
        case .color(let color):
            let op = state.fillOpacity
            context.fill(path, with: .color(color.opacity(op)))
        case .url(let id, let fallback):
            if let grad = lookupGradient(id) {
                applyGradient(grad, path: path, opacity: state.fillOpacity, in: context)
            } else if let fb = fallback {
                context.fill(path, with: .color(fb.opacity(state.fillOpacity)))
            } else {
                context.fill(path, with: .color(Color.black.opacity(state.fillOpacity)))
            }
        }

        // Stroke
        switch state.stroke {
        case .none:
            break
        case .color(let color):
            let style = StrokeStyle(lineWidth: state.strokeWidth, lineCap: state.strokeCap)
            let op = state.strokeOpacity
            context.stroke(path, with: .color(color.opacity(op)), style: style)
        case .url(let id, let fallback):
            let style = StrokeStyle(lineWidth: state.strokeWidth, lineCap: state.strokeCap)
            if let grad = lookupGradient(id) {
                applyStrokeGradient(grad, path: path, style: style, opacity: state.strokeOpacity, in: context)
            } else if let fb = fallback {
                context.stroke(path, with: .color(fb.opacity(state.strokeOpacity)), style: style)
            } else {
                context.stroke(path, with: .color(Color.black.opacity(state.strokeOpacity)), style: style)
            }
        }
    }

    private func applyGradient(_ grad: SVGGradient, path: Path, opacity: Double, in context: GraphicsContext) {
        let bbox = path.boundingRect
        let isUser = grad.gradientUnits == "userSpaceOnUse"

        let stops = grad.stops.map { Gradient.Stop(color: $0.color.opacity(opacity), location: $0.location) }
        let gradient = Gradient(stops: stops)

        if grad.isRadial {
            let cx = isUser ? grad.cx : bbox.minX + grad.cx * bbox.width
            let cy = isUser ? grad.cy : bbox.minY + grad.cy * bbox.height
            let r = isUser ? grad.r : grad.r * max(bbox.width, bbox.height)
            context.fill(path, with: .radialGradient(gradient, center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: r))
        } else {
            let start = isUser ? CGPoint(x: grad.x1, y: grad.y1) : CGPoint(x: bbox.minX + grad.x1 * bbox.width, y: bbox.minY + grad.y1 * bbox.height)
            let end = isUser ? CGPoint(x: grad.x2, y: grad.y2) : CGPoint(x: bbox.minX + grad.x2 * bbox.width, y: bbox.minY + grad.y2 * bbox.height)
            context.fill(path, with: .linearGradient(gradient, startPoint: start, endPoint: end))
        }
    }

    private func applyStrokeGradient(_ grad: SVGGradient, path: Path, style: StrokeStyle, opacity: Double, in context: GraphicsContext) {
        let bbox = path.boundingRect
        let isUser = grad.gradientUnits == "userSpaceOnUse"

        let stops = grad.stops.map { Gradient.Stop(color: $0.color.opacity(opacity), location: $0.location) }
        let gradient = Gradient(stops: stops)

        if grad.isRadial {
            let cx = isUser ? grad.cx : bbox.minX + grad.cx * bbox.width
            let cy = isUser ? grad.cy : bbox.minY + grad.cy * bbox.height
            let r = isUser ? grad.r : grad.r * max(bbox.width, bbox.height)
            context.stroke(path, with: .radialGradient(gradient, center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: r), style: style)
        } else {
            let start = isUser ? CGPoint(x: grad.x1, y: grad.y1) : CGPoint(x: bbox.minX + grad.x1 * bbox.width, y: bbox.minY + grad.y1 * bbox.height)
            let end = isUser ? CGPoint(x: grad.x2, y: grad.y2) : CGPoint(x: bbox.minX + grad.x2 * bbox.width, y: bbox.minY + grad.y2 * bbox.height)
            context.stroke(path, with: .linearGradient(gradient, startPoint: start, endPoint: end), style: style)
        }
    }

    private func applyClipPath(_ id: String, in context: inout GraphicsContext) {
        guard let clip = lookupClipPath(id) else { return }
        var clipPath = Path()
        for node in clip.nodes {
            if node.tag == "rect" {
                let x = Double(node.attributes["x"] ?? "0") ?? 0.0
                let y = Double(node.attributes["y"] ?? "0") ?? 0.0
                let w = Double(node.attributes["width"] ?? "0") ?? 0.0
                let h = Double(node.attributes["height"] ?? "0") ?? 0.0
                clipPath.addRect(CGRect(x: x, y: y, width: w, height: h))
            } else if node.tag == "path", let d = node.attributes["d"] {
                clipPath.addPath(SVGPathParser.parsePath(d: d))
            }
        }
        if !clipPath.isEmpty {
            context.clip(to: clipPath)
        }
    }

    private func applyFilter(_ id: String, node: SVGNode, in context: GraphicsContext, state: SVGRenderState) {
        switch id {
        case "b1":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 1.6)); renderNodeContent(node, in: ctx, state: state) }
        case "b3":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 3.0)); renderNodeContent(node, in: ctx, state: state) }
        case "b4":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 4.0)); renderNodeContent(node, in: ctx, state: state) }
        case "b6":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 6.0)); renderNodeContent(node, in: ctx, state: state) }
        case "b9":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 9.0)); renderNodeContent(node, in: ctx, state: state) }
        case "glow":
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: 2.2)); renderNodeContent(node, in: ctx, state: state) }
            renderNodeContent(node, in: context, state: state)
        case "bd", "pd", "ink":
            let r: Double = id == "bd" ? 1.2 : (id == "pd" ? 2.0 : 0.4)
            context.drawLayer { ctx in ctx.addFilter(.blur(radius: r)); renderNodeContent(node, in: ctx, state: state) }
        case "metal", "mud", "st":
            renderNodeContent(node, in: context, state: state)
            if let noiseCG = SVGDefsRegistry.shared.noiseImage {
                let noiseImg = Image(decorative: noiseCG, scale: 1.0)
                context.drawLayer { ctx in
                    ctx.opacity = 0.12
                    ctx.draw(noiseImg, in: CGRect(x: 0, y: 0, width: 1600, height: 900))
                }
            }
        default:
            renderNodeContent(node, in: context, state: state)
        }
    }

    private func lookupGradient(_ id: String) -> SVGGradient? {
        return localGradients[id] ?? SVGDefsRegistry.shared.gradients[id]
    }

    private func lookupClipPath(_ id: String) -> SVGClipPath? {
        return localClipPaths[id] ?? SVGDefsRegistry.shared.clipPaths[id]
    }

    private func lookupDefNode(_ id: String) -> SVGNode? {
        return localDefNodes[id] ?? SVGDefsRegistry.shared.defNodes[id]
    }

    private func updateState(_ state: inout SVGRenderState, with attrs: [String: String]) {
        if let fillStr = attrs["fill"] {
            state.fill = SVGColorParser.parseFill(fillStr)
        }
        if let fillOpStr = attrs["fill-opacity"], let v = Double(fillOpStr) {
            state.fillOpacity = v
        }
        if let strokeStr = attrs["stroke"] {
            state.stroke = SVGColorParser.parseFill(strokeStr)
        }
        if let strokeOpStr = attrs["stroke-opacity"], let v = Double(strokeOpStr) {
            state.strokeOpacity = v
        }
        if let widthStr = attrs["stroke-width"], let v = Double(widthStr) {
            state.strokeWidth = v
        }
        if let capStr = attrs["stroke-linecap"] {
            switch capStr {
            case "round": state.strokeCap = .round
            case "square": state.strokeCap = .square
            default: state.strokeCap = .butt
            }
        }
        if let opStr = attrs["opacity"], let v = Double(opStr) {
            state.opacity *= v
        }
        if let clipStr = attrs["clip-path"] {
            if clipStr.hasPrefix("url(#") {
                let id = clipStr.dropFirst(5).dropLast(1)
                state.clipPathId = String(id)
            }
        }
        if let filterStr = attrs["filter"] {
            if filterStr.hasPrefix("url(#") {
                let id = filterStr.dropFirst(5).dropLast(1)
                state.filterId = String(id)
            }
        }
        if let transStr = attrs["transform"] {
            state.transform = state.transform.concatenating(parseTransform(transStr))
        }
    }

    private func parseTransform(_ str: String) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        let items = str.components(separatedBy: ")")
        for item in items {
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            let parts = trimmed.components(separatedBy: "(")
            guard parts.count == 2 else { continue }
            let cmd = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let args = parts[1].components(separatedBy: CharacterSet(charactersIn: " ,"))
                .compactMap { Double($0) }

            switch cmd {
            case "translate":
                let tx = args.count > 0 ? args[0] : 0.0
                let ty = args.count > 1 ? args[1] : 0.0
                transform = transform.translatedBy(x: tx, y: ty)

            case "scale":
                let sx = args.count > 0 ? args[0] : 1.0
                let sy = args.count > 1 ? args[1] : sx
                transform = transform.scaledBy(x: sx, y: sy)

            case "rotate":
                let angle = args.count > 0 ? args[0] * .pi / 180.0 : 0.0
                if args.count >= 3 {
                    let cx = args[1]
                    let cy = args[2]
                    transform = transform.translatedBy(x: cx, y: cy)
                        .rotated(by: angle)
                        .translatedBy(x: -cx, y: -cy)
                } else {
                    transform = transform.rotated(by: angle)
                }

            case "matrix":
                if args.count >= 6 {
                    let m = CGAffineTransform(a: args[0], b: args[1], c: args[2], d: args[3], tx: args[4], ty: args[5])
                    transform = transform.concatenating(m)
                }

            default:
                break
            }
        }
        return transform
    }
}

public struct SVGRenderState {
    public var fill: SVGFill = .color(Color.black)
    public var fillOpacity: Double = 1.0
    public var stroke: SVGFill = .none
    public var strokeWidth: Double = 1.0
    public var strokeCap: CGLineCap = .butt
    public var strokeOpacity: Double = 1.0
    public var opacity: Double = 1.0
    public var clipPathId: String? = nil
    public var filterId: String? = nil
    public var transform: CGAffineTransform = .identity
}

private final class SVGFragmentParser: NSObject, XMLParserDelegate {
    var rootNodes: [SVGNode] = []
    var gradients: [String: SVGGradient] = [:]
    var clipPaths: [String: SVGClipPath] = [:]
    var defNodes: [String: SVGNode] = [:]

    private var nodeStack: [SVGNode] = []
    private var currentStops: [Gradient.Stop] = []

    init(markup: String) {
        super.init()
        let xml = "<svg xmlns=\"http://www.w3.org/2000/svg\">" + markup + "</svg>"
        if let data = xml.data(using: .utf8) {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let node = SVGNode(tag: elementName, attributes: attributeDict)

        if elementName == "stop" {
            let offsetStr = attributeDict["offset"] ?? "0"
            var offset = Double(offsetStr.replacingOccurrences(of: "%", with: "")) ?? 0.0
            if offsetStr.contains("%") { offset /= 100.0 }

            let colorStr = attributeDict["stop-color"] ?? attributeDict["color"] ?? "#000000"
            let opacityStr = attributeDict["stop-opacity"] ?? "1"
            let op = Double(opacityStr) ?? 1.0

            if let baseColor = SVGColorParser.parseColor(colorStr) {
                currentStops.append(Gradient.Stop(color: baseColor.opacity(op), location: offset))
            }
            return
        }

        if elementName == "linearGradient" || elementName == "radialGradient" {
            currentStops = []
        }

        if let parent = nodeStack.last {
            parent.children.append(node)
        } else if elementName != "svg" {
            rootNodes.append(node)
        }

        nodeStack.append(node)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let node = nodeStack.popLast() else { return }

        if let id = node.attributes["id"] {
            defNodes[id] = node
        }

        if elementName == "linearGradient" || elementName == "radialGradient" {
            if let id = node.attributes["id"] {
                let isRadial = (elementName == "radialGradient")
                let units = node.attributes["gradientUnits"] ?? "objectBoundingBox"
                let grad = SVGGradient(
                    id: id,
                    isRadial: isRadial,
                    x1: Double(node.attributes["x1"] ?? "0") ?? 0.0,
                    y1: Double(node.attributes["y1"] ?? "0") ?? 0.0,
                    x2: Double(node.attributes["x2"] ?? "1") ?? 1.0,
                    y2: Double(node.attributes["y2"] ?? "0") ?? 0.0,
                    cx: Double(node.attributes["cx"] ?? "0.5") ?? 0.5,
                    cy: Double(node.attributes["cy"] ?? "0.5") ?? 0.5,
                    r: Double(node.attributes["r"] ?? "0.5") ?? 0.5,
                    gradientUnits: units,
                    stops: currentStops
                )
                gradients[id] = grad
            }
            currentStops = []
        } else if elementName == "clipPath" {
            if let id = node.attributes["id"] {
                clipPaths[id] = SVGClipPath(id: id, nodes: node.children)
            }
        }
    }
}
