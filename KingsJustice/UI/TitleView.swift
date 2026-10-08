import SwiftUI

struct TitleView: View {
    let onBegin: () -> Void
    @State private var revealed: Bool = false
    @State private var pulse: Bool = false

    init(onBegin: @escaping () -> Void) {
        self.onBegin = onBegin
    }

    var body: some View {
        ZStack {
            BackgroundGradientView()
            TitleBackdropView(fadeStart: 0.55, fadeEnd: 0.95)

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("A MEDIEVAL DUEL")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(revealed ? 6.0 : 14.0)
                        .foregroundColor(UITheme.textCream)
                        .opacity(revealed ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 1.4).delay(0.4), value: revealed)

                    Text("The King's Justice")
                        .font(.system(size: 44, weight: .regular, design: .serif).italic())
                        .foregroundColor(UITheme.textCreamBright)
                        .shadow(color: UITheme.bloodRed.opacity(0.9), radius: 22)
                        .scaleEffect(revealed ? 1.0 : 1.08)
                        .opacity(revealed ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 1.6).delay(0.9), value: revealed)
                }
                .padding(.bottom, 8)

                PillButton(title: "Begin", isPrimary: true, action: onBegin)
                    .opacity(revealed ? (pulse ? 1.0 : 0.72) : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(2.0), value: revealed)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
                    .padding(.bottom, 56)
            }
            .padding()
        }
        .onAppear {
            revealed = true
            pulse = true
        }
    }
}
