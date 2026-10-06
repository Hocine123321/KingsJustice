import SwiftUI

public final class MockRenderSource: RenderSource, ObservableObject {
    @Published public var rsTime: Double = 0.0
    @Published public var rsEnemy: EnemyDef? = GameData.roster.first
    @Published public var rsStyle: StyleDef = GameData.styles.first ?? StyleDef(
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
    @Published public var rsPlayerPose: [Double] = [450.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]
    @Published public var rsEnemyPose: [Double] = [900.0, 0.0, -40.0, 45.0, 70.0, 0.0, 0.0, 0.0]
    @Published public var rsEvents: [RenderNote] = []
    @Published public var rsShake: Double = 0.0
    @Published public var rsHurt: Double = 0.0
    @Published public var rsRoundIsDefend: Bool = true
    @Published public var rsArenaKey: String = "throne"
    @Published public var rsHitStop: Bool = false
    @Published public var rsWound: Double = 0.0
    @Published public var rsFlash: Double = 0.0
    @Published public var rsFocusActive: Bool = false
    @Published public var rsPerfectGlow: Double = 0.0

    private var pendingFX: [RenderFX] = []

    public init() {}

    public func rsDrainFX() -> [RenderFX] {
        let list = pendingFX
        pendingFX.removeAll()
        return list
    }

    public func addFX(_ fx: RenderFX) {
        pendingFX.append(fx)
    }
}

public struct RenderPreviewView: View {
    @StateObject private var mockSource = MockRenderSource()
    @State private var selectedArena: String = "throne"
    @State private var selectedEnemyIdx: Int = 0

    public init() {}

    public var body: some View {
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
