import SwiftUI

final class MockRenderSource: RenderSource, ObservableObject {
    @Published var rsTime: Double = 0.0
    @Published var rsEnemy: EnemyDef? = GameData.roster.first
    @Published var rsStyle: StyleDef = GameData.styles.first ?? StyleDef(
        id: "knight",
        name: "Knight",
        desc: "",
        weapon: "longsword",
        windows: TimingWindows(perfect: 0.06, good: 0.115, miss: 0.17),
        dmgMul: 1.0,
        takeMul: 1.0,
        parryBonus: 1.0,
        special: SpecialDef(id: "s", name: "S", desc: "", charge: "", need: 100),
        look: LookDef(colors: ["#0a0807", "#5d6877", "#a7b4c2"], trim: "#d9b45a", eye: "#ff3a3a", helm: "greathelm", cape: "cloak", weapon: "longsword", size: 1.0, shield: true, glow: nil)
    )
    @Published var rsPlayerPose: [Double] = [450.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]
    @Published var rsEnemyPose: [Double] = [900.0, 0.0, -40.0, 45.0, 70.0, 0.0, 0.0, 0.0]
    @Published var rsEvents: [RenderNote] = []
    @Published var rsShake: Double = 0.0
    @Published var rsHurt: Double = 0.0
    @Published var rsRoundIsDefend: Bool = true
    @Published var rsArenaKey: String = "throne"
    @Published var rsHitStop: Bool = false
    @Published var rsWound: Double = 0.0
    @Published var rsFlash: Double = 0.0
    @Published var rsFocusActive: Bool = false
    @Published var rsPerfectGlow: Double = 0.0

    private var pendingFX: [RenderFX] = []

    init() {}

    func rsDrainFX() -> [RenderFX] {
        let list = pendingFX
        pendingFX.removeAll()
        return list
    }

    func addFX(_ fx: RenderFX) {
        pendingFX.append(fx)
    }
}

struct RenderPreviewView: View {
    @StateObject private var mockSource = MockRenderSource()
    @State private var selectedArena: String = "throne"
    @State private var selectedEnemyIdx: Int = 0

    init() {}

    var body: some View {
        VStack(spacing: 0) {
            GameSceneView(source: mockSource)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)

            HStack(spacing: 16) {
                Picker("Arena", selection: $selectedArena) {
                    ForEach(Array(GameData.arenas.keys).sorted(), id: \.self) { key in
                        Text(GameData.arenas[key]?.name ?? key).tag(key)
                    }
                }
                .onChange(of: selectedArena) { newKey in
                    mockSource.rsArenaKey = newKey
                }

                Picker("Enemy", selection: $selectedEnemyIdx) {
                    ForEach(0..<GameData.roster.count, id: \.self) { idx in
                        Text(GameData.roster[idx].name).tag(idx)
                    }
                }
                .onChange(of: selectedEnemyIdx) { idx in
                    if idx < GameData.roster.count {
                        mockSource.rsEnemy = GameData.roster[idx]
                    }
                }

                Button("Spark FX") {
                    mockSource.addFX(.spark(x: 650, y: 450, n: 15))
                }

                Button("Blood FX") {
                    mockSource.addFX(.blood(x: 650, y: 450, n: 20, dir: -1.0, power: 1.0))
                }

                Toggle("Defend Mode", isOn: $mockSource.rsRoundIsDefend)
            }
            .padding(12)
            .background(Color(white: 0.15))
            .foregroundColor(.white)
        }
    }
}
