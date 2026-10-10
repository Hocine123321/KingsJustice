import SwiftUI

/// Cinematic champion card shown while the fight is loading in, followed by a quick FIGHT! beat.
struct FightIntroView<Engine: UIEngine>: View {
    @ObservedObject var engine: Engine
    @State private var cardIn: Bool = false
    @State private var fightVisible: Bool = false
    @State private var fightPop: Bool = false

    init(engine: Engine) {
        self.engine = engine
    }

    var body: some View {
        ZStack {
            if !engine.started {
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(UITheme.textGold.opacity(0.8))
                        .frame(width: cardIn ? 220.0 : 0.0, height: 1)
                    Text(engine.enemyName.uppercased())
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .tracking(cardIn ? 5.0 : 16.0)
                        .foregroundColor(UITheme.textCreamBright)
                        .shadow(color: UITheme.bloodRed.opacity(0.9), radius: 14)
                    Text(engine.enemyTitle)
                        .font(.system(size: 14, weight: .regular, design: .serif).italic())
                        .foregroundColor(UITheme.textGold)
                    Rectangle()
                        .fill(UITheme.textGold.opacity(0.8))
                        .frame(width: cardIn ? 220.0 : 0.0, height: 1)
                }
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.0),
                            Gradient.Stop(color: Color.black.opacity(0.68), location: 0.35),
                            Gradient.Stop(color: Color.black.opacity(0.68), location: 0.65),
                            Gradient.Stop(color: Color.black.opacity(0.0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(cardIn ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.55), value: cardIn)
                .transition(.opacity)
                .onAppear { cardIn = true }
            }

            if !engine.phaseBanner.isEmpty {
                VStack(spacing: 4) {
                    Text(engine.phaseBanner.uppercased())
                        .font(.system(size: 34, weight: .heavy, design: .serif))
                        .tracking(8.0)
                        .foregroundColor(UITheme.textCreamBright)
                        .shadow(color: UITheme.bloodRed, radius: 16)
                    Text(engine.enemyName.uppercased() + " GROWS DESPERATE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(3.0)
                        .foregroundColor(UITheme.textGold)
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            Gradient.Stop(color: Color.black.opacity(0.0), location: 0.0),
                            Gradient.Stop(color: UITheme.bloodRed.opacity(0.55), location: 0.5),
                            Gradient.Stop(color: Color.black.opacity(0.0), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .transition(.opacity)
            }

            if fightVisible {
                Text("FIGHT!")
                    .font(.system(size: 56, weight: .heavy, design: .serif).italic())
                    .tracking(4.0)
                    .foregroundColor(UITheme.textGold)
                    .shadow(color: UITheme.bloodRed, radius: 18)
                    .scaleEffect(fightPop ? 1.0 : 1.8)
                    .opacity(fightPop ? 1.0 : 0.0)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: engine.started)
        .animation(.easeOut(duration: 0.35), value: engine.phaseBanner)
        .allowsHitTesting(false)
        .onChange(of: engine.started) { s in
            if s {
                cardIn = false
                fightPop = false
                fightVisible = true
                withAnimation(.easeOut(duration: 0.26)) { fightPop = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeIn(duration: 0.3)) { fightVisible = false }
                }
            }
        }
    }
}
