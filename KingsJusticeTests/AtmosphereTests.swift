import XCTest
import SwiftUI
@testable import KingsJustice

final class AtmosphereTests: XCTestCase {
    func testEveryArenaHasAmbientLife() {
        for key in GameData.arenas.keys {
            XCTAssertNotEqual(Atmosphere.ambientKind(for: key), .quiet, key)
        }
        XCTAssertEqual(Atmosphere.ambientKind(for: "nowhere"), .quiet)
    }

    func testArenasFeelDifferent() {
        XCTAssertEqual(Atmosphere.ambientKind(for: "swamp"), .fireflies)
        XCTAssertEqual(Atmosphere.ambientKind(for: "cathedral"), .bats)
        XCTAssertEqual(Atmosphere.ambientKind(for: "village"), .embers)
        XCTAssertEqual(Atmosphere.ambientKind(for: "pass"), .motes)
    }

    func testAmbientSpotsStayFiniteAndOnStage() {
        let kinds: [Atmosphere.AmbientKind] = [.crows, .bats, .fireflies, .embers, .motes]
        for kind in kinds {
            XCTAssertFalse(Atmosphere.ambientSpots(kind: kind, time: 1.0).isEmpty, "\(kind)")
            var t = -5.0
            while t < 600.0 {
                for s in Atmosphere.ambientSpots(kind: kind, time: t) {
                    XCTAssertTrue(s.x.isFinite && s.y.isFinite && s.size.isFinite && s.flap.isFinite, "\(kind) t=\(t)")
                    XCTAssertTrue(s.x >= -260.0 && s.x <= 1860.0, "\(kind) x=\(s.x)")
                    XCTAssertTrue(s.y >= -60.0 && s.y <= 960.0, "\(kind) y=\(s.y)")
                    XCTAssertTrue(s.alpha >= -1e-9 && s.alpha <= 1.0 + 1e-9, "\(kind) a=\(s.alpha)")
                }
                t += 0.37
            }
        }
        XCTAssertTrue(Atmosphere.ambientSpots(kind: .quiet, time: 3.0).isEmpty)
    }

    func testAmbientSpotsActuallyMove() {
        for kind in [Atmosphere.AmbientKind.crows, .bats, .fireflies, .embers, .motes] {
            XCTAssertNotEqual(Atmosphere.ambientSpots(kind: kind, time: 2.0), Atmosphere.ambientSpots(kind: kind, time: 4.0), "\(kind)")
        }
    }

    func testSecondLayerOnlyOnTheArenasThatEarnIt() {
        XCTAssertEqual(Atmosphere.ambientAccent(for: "village"), .leaves)
        XCTAssertEqual(Atmosphere.ambientAccent(for: "castle"), .sparks)
        XCTAssertEqual(Atmosphere.ambientAccent(for: "cliff"), .sparks)
        XCTAssertEqual(Atmosphere.ambientAccent(for: "swamp"), .quiet)
    }

    func testLeavesAndSparksStayFiniteAndOnStage() {
        let torches = [CGPoint(x: 200.0, y: 300.0), CGPoint(x: 1400.0, y: 500.0)]
        for kind in [Atmosphere.AmbientKind.leaves, .sparks] {
            var t = -5.0
            while t < 300.0 {
                let spots = Atmosphere.ambientSpots(kind: kind, time: t, emitters: torches)
                XCTAssertFalse(spots.isEmpty, "\(kind)")
                for s in spots {
                    XCTAssertTrue(s.x.isFinite && s.y.isFinite && s.size.isFinite && s.flap.isFinite, "\(kind)")
                    XCTAssertTrue(s.x >= -100.0 && s.x <= 1700.0, "\(kind) x=\(s.x)")
                    XCTAssertTrue(s.y >= 0.0 && s.y <= 900.0, "\(kind) y=\(s.y)")
                    XCTAssertTrue(s.alpha >= -1e-9 && s.alpha <= 1.0 + 1e-9, "\(kind) a=\(s.alpha)")
                }
                t += 0.41
            }
        }
        XCTAssertTrue(Atmosphere.ambientSpots(kind: .sparks, time: 2.0).isEmpty)
    }

    func testEveryArenaHasTorchPointsForSparks() {
        for key in GameData.arenas.keys {
            XCTAssertEqual(Atmosphere.torchPoints(for: key).count, 2, key)
        }
    }
}
