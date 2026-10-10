import Foundation

extension GameEngine {
    // MARK: - Save & Settings Persistence

    func saveAll() {
        let encoder = JSONEncoder()
        if let set = try? encoder.encode(settings) {
            UserDefaults.standard.set(set, forKey: "kj_set")
        }
        if let sav = try? encoder.encode(save) {
            UserDefaults.standard.set(sav, forKey: "kj_save")
        }
    }

    func loadAll() {
        let decoder = JSONDecoder()
        if let setData = UserDefaults.standard.data(forKey: "kj_set"),
           let loadedSet = try? decoder.decode(GameSettings.self, from: setData) {
            self.settings = loadedSet
        }
        if let savData = UserDefaults.standard.data(forKey: "kj_save"),
           let loadedSav = try? decoder.decode(SaveData.self, from: savData) {
            self.save = loadedSav
        }
    }

    // MARK: - Shop API

    var tonics: [ShopTonic] {
        return [
            ShopTonic(id: "heal", name: "Healing Draught", desc: "Tap the flask mid-fight: restore 35% health. Once per fight.", price: 60, owned: save.invHeal),
            ShopTonic(id: "focus", name: "Battle Focus", desc: "Start the next fight with your Focus meter half full.", price: 50, owned: save.invFocus),
            ShopTonic(id: "edge", name: "Whetstone", desc: "+25% damage dealt for the next fight.", price: 70, owned: save.invEdge),
            ShopTonic(id: "tough", name: "Iron Gambeson", desc: "20% less damage taken for the next fight.", price: 80, owned: save.invTough)
        ]
    }

    func canBuy(id: String) -> Bool {
        guard let tonic = tonics.first(where: { $0.id == id }) else { return false }
        return save.gold >= tonic.price
    }

    @discardableResult
    func buy(id: String) -> Bool {
        guard canBuy(id: id) else { return false }
        switch id {
        case "heal":
            save.gold -= 60
            save.invHeal += 1
        case "focus":
            save.gold -= 50
            save.invFocus += 1
        case "edge":
            save.gold -= 70
            save.invEdge += 1
        case "tough":
            save.gold -= 80
            save.invTough += 1
        default:
            return false
        }
        saveAll()
        updateHud()
        return true
    }

    func prepareTonicsForFight() {
        if save.invFocus > 0 {
            save.invFocus -= 1
            stamina = 50.0
        }
        if save.invEdge > 0 {
            save.invEdge -= 1
            edge = true
        }
        if save.invTough > 0 {
            save.invTough -= 1
            tough = true
        }
        potion = (save.invHeal > 0) ? 1 : 0
        if potion > 0 {
            save.invHeal -= 1
        }
        saveAll()
    }

    func drinkPotion() {
        guard on && started && !over && !paused && potion > 0 else { return }
        potion = 0
        hp = min(maxhp, hp + maxhp * 0.35)
        say("Restored", col: "#8fd0a0")
        flashScreen(color: "#6fe08a", opacity: 0.2)
        onSfx?(.potion, 1.0)
        updateHud()
    }
}
