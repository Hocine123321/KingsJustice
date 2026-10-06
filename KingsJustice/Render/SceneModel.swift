import SwiftUI
import Combine

@MainActor
public final class SceneModel: ObservableObject {
    @Published public var currentArenaKey: String = ""

    public var bgImage: Image?
    public var clImage: Image?
    public var gndImage: Image?
    public var fgImage: Image?

    public var bgDoc: SVGDocument?
    public var clDoc: SVGDocument?
    public var gndDoc: SVGDocument?
    public var fgDoc: SVGDocument?

    public let particleSystem = ParticleSystem()
    private var lastTime: Double = 0.0

    public init() {}

    public func updateArenaIfNeeded(arenaKey: String, arenaDef: ArenaDef?) {
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
        let wColor = SVGColorParser.parseColor(arena.weather.color) ?? Color.white
        particleSystem.setupWeather(
            type: arena.weather.type,
            count: arena.weather.count,
            color: arena.weather.color,
            wind: arena.weather.wind
        )
    }

    public func update(time: Double, source: (any RenderSource)?) {
        let dt = lastTime > 0 ? max(0.001, min(0.1, time - lastTime)) : 0.016
        lastTime = time

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
            particleSystem.update(dt: dt, time: time, weatherType: wType, wind: wind)
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

    public func drawBgLayer(in context: GraphicsContext, size: CGSize) {
        if let img = bgImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = bgDoc {
            doc.draw(in: context, size: size)
        }
    }

    public func drawClLayer(in context: GraphicsContext, size: CGSize) {
        if let img = clImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = clDoc {
            doc.draw(in: context, size: size)
        }
    }

    public func drawGndLayer(in context: GraphicsContext, size: CGSize) {
        if let img = gndImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = gndDoc {
            doc.draw(in: context, size: size)
        }
    }

    public func drawFgLayer(in context: GraphicsContext, size: CGSize) {
        if let img = fgImage {
            context.draw(img, in: CGRect(origin: .zero, size: CGSize(width: 1600, height: 900)))
        } else if let doc = fgDoc {
            doc.draw(in: context, size: size)
        }
    }
}
