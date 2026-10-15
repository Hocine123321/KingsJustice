import Foundation

/// A colour scheme for a fighter. Purely cosmetic: it recolours the armour and keeps the helm, cape, weapon and size.
struct Livery: Equatable {
    let id: String
    let name: String
    let desc: String
    /// Gold price. All prices live in `Armoury.all`, so tuning them is a one-place change.
    let price: Int
    let colors: [String]   // dark, mid, light
    let trim: String
    let eye: String?       // nil keeps the style's own eye colour
    let glow: String?      // nil keeps the style's own glow (or none)
}

enum Armoury {
    static let all: [Livery] = [
        Livery(id: "ember", name: "Emberforged", desc: "Forged in a dying fire.", price: 120,
               colors: ["#1a0905", "#a8381c", "#f0905a"], trim: "#ffb347", eye: "#ffd36a", glow: "#ff7a2a"),
        Livery(id: "frost", name: "Frostbound", desc: "Cold steel, colder resolve.", price: 120,
               colors: ["#08121c", "#4a7a9c", "#cfe8f5"], trim: "#e8f4ff", eye: "#aee6ff", glow: "#7fc8ff"),
        Livery(id: "verdant", name: "Greenwood", desc: "Worn by the wardens of the old wood.", price: 160,
               colors: ["#0a140a", "#3f6b34", "#a9cf8a"], trim: "#c8a45a", eye: nil, glow: nil),
        Livery(id: "royal", name: "Royal Violet", desc: "Cut for a court that no longer stands.", price: 200,
               colors: ["#12081c", "#5b3a8c", "#c2a4ec"], trim: "#ffd24a", eye: nil, glow: "#a46bff"),
        Livery(id: "ashen", name: "Ashen Ghost", desc: "Grey as the morning after a siege.", price: 240,
               colors: ["#0e0e10", "#6a6a72", "#c8c8d0"], trim: "#9a9aa4", eye: "#ffffff", glow: nil),
        Livery(id: "gilded", name: "Gilded Dawn", desc: "Gold at first light.", price: 320,
               colors: ["#2a1c06", "#c79a2a", "#fff0b8"], trim: "#ffffff", eye: "#fff3c0", glow: "#ffe08a")
    ]

    static func livery(id: String?) -> Livery? {
        guard let id = id else { return nil }
        return all.first(where: { $0.id == id })
    }

    /// The style with the livery's colours painted over its look. Silhouette, weapon and every stat are untouched.
    static func dressed(_ style: StyleDef, with livery: Livery?) -> StyleDef {
        guard let l = livery else { return style }
        let base = style.look
        let look = LookDef(colors: l.colors, trim: l.trim, eye: l.eye ?? base.eye, helm: base.helm, cape: base.cape,
                           weapon: base.weapon, size: base.size, shield: base.shield, glow: l.glow ?? base.glow)
        return StyleDef(id: style.id, name: style.name, desc: style.desc, weapon: style.weapon, windows: style.windows,
                        dmgMul: style.dmgMul, takeMul: style.takeMul, parryBonus: style.parryBonus,
                        special: style.special, look: look)
    }

    static func isOwned(_ s: SaveData, id: String) -> Bool {
        return s.ownedLiveries.contains(id)
    }

    /// The livery worn on a style, but only if it is real and actually owned.
    static func equippedId(_ s: SaveData, style: String) -> String? {
        guard let id = s.liveries[style], isOwned(s, id: id), livery(id: id) != nil else { return nil }
        return id
    }

    static func canBuy(_ s: SaveData, id: String) -> Bool {
        guard let l = livery(id: id), !isOwned(s, id: id) else { return false }
        return s.gold >= l.price
    }

    @discardableResult
    static func buy(_ s: inout SaveData, id: String) -> Bool {
        guard canBuy(s, id: id), let l = livery(id: id) else { return false }
        s.gold -= l.price
        s.ownedLiveries.append(id)
        return true
    }

    /// Wears an owned livery on one style. Returns false for an unknown or unowned one.
    @discardableResult
    static func equip(_ s: inout SaveData, id: String, style: String) -> Bool {
        guard livery(id: id) != nil, isOwned(s, id: id) else { return false }
        s.liveries[style] = id
        return true
    }

    static func unequip(_ s: inout SaveData, style: String) {
        s.liveries[style] = nil
    }
}

/// Lets the shop screen buy and wear liveries without widening the UIEngine protocol.
protocol ArmouryControlling: AnyObject {
    var armourySave: SaveData { get }
    func buyLivery(_ id: String) -> Bool
    /// Wears the livery on the currently chosen fighting style, or takes it off when nil.
    func wearLivery(_ id: String?)
}

extension GameEngine: ArmouryControlling {
    var armourySave: SaveData { return save }

    func buyLivery(_ id: String) -> Bool {
        guard Armoury.buy(&save, id: id) else { return false }
        Armoury.equip(&save, id: id, style: save.style)
        return true
    }

    func wearLivery(_ id: String?) {
        if let id = id {
            Armoury.equip(&save, id: id, style: save.style)
        } else {
            Armoury.unequip(&save, style: save.style)
        }
    }
}
