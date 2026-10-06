import XCTest
import SwiftUI
@testable import KingsJustice

@MainActor
final class RenderTests: XCTestCase {

    func testParseSharedSVGDefs() {
        let doc = SVGDocument(markup: SharedSVGDefs.markup)
        XCTAssertGreaterThan(doc.rootNodes.count, 0, "SharedSVGDefs should parse to non-empty root nodes")
        XCTAssertGreaterThan(doc.localGradients.count + SVGDefsRegistry.shared.gradients.count, 0, "Shared SVG defs should contain gradients")
    }

    func testParseAllArenaFragments() {
        for (key, arena) in GameData.arenas {
            let bgDoc = SVGDocument(markup: arena.bg)
            XCTAssertGreaterThan(bgDoc.rootNodes.count, 0, "Arena \(key) bg should parse")

            let clDoc = SVGDocument(markup: arena.cl)
            XCTAssertGreaterThan(clDoc.rootNodes.count, 0, "Arena \(key) cl should parse")

            let gndDoc = SVGDocument(markup: arena.gnd)
            XCTAssertGreaterThan(gndDoc.rootNodes.count, 0, "Arena \(key) gnd should parse")

            let fgDoc = SVGDocument(markup: arena.fg)
            XCTAssertGreaterThan(fgDoc.rootNodes.count, 0, "Arena \(key) fg should parse")
        }
    }

    func testPathParserHandlesAllCommands() {
        let pathData = "M 10 20 m 5 5 L 30 40 l 10 10 H 100 h 10 V 200 v 20 Q 50 50 70 80 q 10 10 20 20 T 150 150 t 10 10 C 10 20 30 40 50 60 c 5 5 10 10 15 15 A 30 50 0 0 1 200 300 a 20 20 0 1 0 30 30 Z"
        let path = SVGPathParser.parsePath(d: pathData)
        XCTAssertFalse(path.isEmpty, "Path parser should parse path data with all commands")
    }

    func testArcConversionProducesFinitePoints() {
        let arcPathData = "M 10 10 A 30 50 45 1 1 100 200 A 15 25 0 0 0 10 10"
        let path = SVGPathParser.parsePath(d: arcPathData)
        XCTAssertFalse(path.isEmpty)

        path.forEach { element in
            switch element {
            case .move(to: let p):
                XCTAssertTrue(p.x.isFinite && p.y.isFinite)
            case .line(to: let p):
                XCTAssertTrue(p.x.isFinite && p.y.isFinite)
            case .quadCurve(to: let p, control: let c):
                XCTAssertTrue(p.x.isFinite && p.y.isFinite && c.x.isFinite && c.y.isFinite)
            case .curve(to: let p, control1: let c1, control2: let c2):
                XCTAssertTrue(p.x.isFinite && p.y.isFinite && c1.x.isFinite && c1.y.isFinite && c2.x.isFinite && c2.y.isFinite)
            case .closeSubpath:
                break
            }
        }
    }

    func testColorParser() {
        let c1 = SVGColorParser.parseColor("#0a7")
        XCTAssertNotNil(c1)

        let c2 = SVGColorParser.parseColor("#07080b")
        XCTAssertNotNil(c2)

        let c3 = SVGColorParser.parseColor("gold")
        XCTAssertNotNil(c3)

        let c4 = SVGColorParser.parseColor("none")
        XCTAssertEqual(c4, Color.clear)

        let fill1 = SVGColorParser.parseFill("url(#kS) #5d6877")
        if case .url(let id, let fallback) = fill1 {
            XCTAssertEqual(id, "kS")
            XCTAssertNotNil(fallback)
        } else {
            XCTFail("Should parse url(#kS) #5d6877 as url fill with fallback")
        }
    }
}
