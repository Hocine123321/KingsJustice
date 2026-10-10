import XCTest
@testable import KingsJustice

final class InputPaletteTests: XCTestCase {
    func testEveryDefendInputHasItsOwnColour() {
        let hexes = (InputPalette.defendInputs + ["grab"]).map { InputPalette.hex(for: $0) }
        XCTAssertEqual(Set(hexes).count, hexes.count)
        XCTAssertFalse(hexes.contains("#ffffff"))
    }

    func testEveryMoveRingUsesItsInputColour() {
        for (id, move) in GameData.moves {
            XCTAssertNotEqual(InputPalette.hex(for: move.input), "#ffffff", "\(id) has an input with no palette colour")
        }
    }

    func testJumpIsGreenAndDuckIsYellow() {
        XCTAssertEqual(InputPalette.hex(for: "jump"), "#4cd08a")
        XCTAssertEqual(InputPalette.hex(for: "duck"), "#f1c40f")
    }
}
