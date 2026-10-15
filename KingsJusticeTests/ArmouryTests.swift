import XCTest
import SwiftUI
@testable import KingsJustice

final class ArmouryTests: XCTestCase {
    private func isHex(_ s: String) -> Bool {
        return s.range(of: "^#[0-9a-fA-F]{6}$", options: .regularExpression) != nil
    }

    func testCatalogIsWellFormed() {
        XCTAssertEqual(Set(Armoury.all.map { $0.id }).count, Armoury.all.count, "duplicate id")
        for l in Armoury.all {
            XCTAssertGreaterThan(l.price, 0, l.id)
            XCTAssertEqual(l.colors.count, 3, l.id)
            for c in l.colors + [l.trim] + [l.eye, l.glow].compactMap({ $0 }) {
                XCTAssertTrue(isHex(c), "\(l.id) \(c)")
                XCTAssertNotNil(SVGColorParser.parseColor(c), "\(l.id) \(c)")
            }
        }
        XCTAssertEqual(Armoury.livery(id: "ember")?.name, "Emberforged")
        XCTAssertNil(Armoury.livery(id: "nope"))
        XCTAssertNil(Armoury.livery(id: nil))
    }

    func testBuyingChargesOnceAndNeedsEnoughGold() {
        var s = SaveData()
        s.gold = 119
        XCTAssertFalse(Armoury.canBuy(s, id: "ember"))
        XCTAssertFalse(Armoury.buy(&s, id: "ember"))
        XCTAssertEqual(s.gold, 119)
        s.gold = 500
        XCTAssertTrue(Armoury.buy(&s, id: "ember"))
        XCTAssertEqual(s.gold, 380)
        XCTAssertTrue(Armoury.isOwned(s, id: "ember"))
        XCTAssertFalse(Armoury.buy(&s, id: "ember"), "cannot buy twice")
        XCTAssertEqual(s.gold, 380)
        XCTAssertFalse(Armoury.buy(&s, id: "nope"))
    }

    func testOnlyOwnedLiveriesCanBeWornAndEachStyleKeepsItsOwn() {
        var s = SaveData()
        s.gold = 1000
        XCTAssertFalse(Armoury.equip(&s, id: "frost", style: "knight"), "not owned yet")
        Armoury.buy(&s, id: "frost")
        Armoury.buy(&s, id: "ember")
        XCTAssertTrue(Armoury.equip(&s, id: "frost", style: "knight"))
        XCTAssertTrue(Armoury.equip(&s, id: "ember", style: "duelist"))
        XCTAssertEqual(Armoury.equippedId(s, style: "knight"), "frost")
        XCTAssertEqual(Armoury.equippedId(s, style: "duelist"), "ember")
        XCTAssertNil(Armoury.equippedId(s, style: "berserker"))
        Armoury.unequip(&s, style: "knight")
        XCTAssertNil(Armoury.equippedId(s, style: "knight"))
        XCTAssertEqual(Armoury.equippedId(s, style: "duelist"), "ember")
    }

    func testAHandEditedSaveCannotWearAnUnownedOrUnknownLivery() {
        var s = SaveData()
        s.liveries["knight"] = "gilded"
        XCTAssertNil(Armoury.equippedId(s, style: "knight"))
        s.ownedLiveries = ["ghost-livery"]
        s.liveries["knight"] = "ghost-livery"
        XCTAssertNil(Armoury.equippedId(s, style: "knight"))
    }

    func testDressingChangesOnlyColoursNeverStatsOrSilhouette() {
        let l = Armoury.livery(id: "ember")!
        for style in GameData.styles {
            let d = Armoury.dressed(style, with: l)
            XCTAssertEqual(d.look.colors, l.colors)
            XCTAssertEqual(d.look.trim, l.trim)
            XCTAssertEqual(d.look.helm, style.look.helm)
            XCTAssertEqual(d.look.cape, style.look.cape)
            XCTAssertEqual(d.look.weapon, style.look.weapon)
            XCTAssertEqual(d.look.size, style.look.size)
            XCTAssertEqual(d.look.shield, style.look.shield)
            XCTAssertEqual(d.id, style.id)
            XCTAssertEqual(d.dmgMul, style.dmgMul)
            XCTAssertEqual(d.takeMul, style.takeMul)
            XCTAssertEqual(d.parryBonus, style.parryBonus)
            XCTAssertEqual(d.windows.perfect, style.windows.perfect)
            XCTAssertEqual(d.windows.good, style.windows.good)
        }
        XCTAssertEqual(Armoury.dressed(GameData.styles[0], with: nil).look.colors, GameData.styles[0].look.colors)
    }

    func testEyeAndGlowFallBackToTheStylesOwnWhenTheLiveryHasNone() {
        let l = Armoury.livery(id: "verdant")!
        XCTAssertNil(l.eye)
        let style = GameData.styles[0]
        let d = Armoury.dressed(style, with: l)
        XCTAssertEqual(d.look.eye, style.look.eye)
        XCTAssertEqual(d.look.glow, style.look.glow)
    }

    func testEngineBuysWearsAndRendersTheLivery() {
        let e = GameEngine()
        e.save = SaveData()
        e.save.gold = 400
        e.save.style = "knight"
        e.styleDef = GameData.styles.first(where: { $0.id == "knight" })!
        let plain = e.rsStyle.look.colors
        XCTAssertTrue(e.buyLivery("royal"))
        XCTAssertEqual(e.save.gold, 200)
        XCTAssertEqual(e.rsStyle.look.colors, Armoury.livery(id: "royal")!.colors)
        XCTAssertEqual(e.styleDef.look.colors, plain, "the base style is never overwritten")
        e.wearLivery(nil)
        XCTAssertEqual(e.rsStyle.look.colors, plain)
        e.wearLivery("royal")
        XCTAssertEqual(e.rsStyle.look.colors, Armoury.livery(id: "royal")!.colors)
        XCTAssertFalse(e.buyLivery("gilded"), "320 gold is more than the 200 left")
    }

    func testOldSavesLoadEmptyAndPurchasesRoundTrip() throws {
        let old = try JSONDecoder().decode(SaveData.self, from: Data("{\"gold\": 3}".utf8))
        XCTAssertEqual(old.ownedLiveries, [])
        XCTAssertEqual(old.liveries, [:])
        var s = SaveData()
        s.gold = 500
        Armoury.buy(&s, id: "ashen")
        Armoury.equip(&s, id: "ashen", style: "duelist")
        let back = try JSONDecoder().decode(SaveData.self, from: try JSONEncoder().encode(s))
        XCTAssertEqual(back, s)
    }
}
