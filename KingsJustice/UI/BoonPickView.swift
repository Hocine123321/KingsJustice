import SwiftUI

/// Pick one of three boons between Survival waves.
struct BoonPickView: View {
    let wave: Int
    let offer: [Boon]
    let taken: [String]
    let onPick: (String) -> Void
    @State private var shown: Bool = false

    var body: some View {
        ZStack {
            BackgroundGradientView()

            GeometryReader { geo in
                let wide = geo.size.width > geo.size.height
                VStack(spacing: wide ? 12 : 18) {
                    HeaderKickView(kick: "Wave \(wave) survived", title: "Choose a Boon")

                    if wide {
                        HStack(spacing: 12) { cards }
                    } else {
                        VStack(spacing: 10) { cards }
                    }

                    Text("Boons last until your run ends.")
                        .font(.system(size: 11, weight: .regular, design: .serif).italic())
                        .foregroundColor(UITheme.textCream.opacity(0.7))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .onAppear { shown = true }
    }

    @ViewBuilder
    private var cards: some View {
        ForEach(Array(offer.enumerated()), id: \.element.id) { idx, boon in
            Button(action: {
                UIAudio.onFirstUserTap()
                UIAudio.playSfx(.uiConfirm)
                UIAudio.triggerHaptic("tap")
                onPick(boon.id)
            }) {
                VStack(spacing: 8) {
                    Text(boon.name.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.6)
                        .foregroundColor(UITheme.textGold)
                        .multilineTextAlignment(.center)
                    Text(boon.desc)
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundColor(UITheme.textCream)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    let have = BoonCatalog.stacks(boon.id, in: taken)
                    if have > 0 && boon.maxStacks > 1 && boon.maxStacks < 99 {
                        Text("Owned: \(have)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(UITheme.textCream.opacity(0.6))
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 110)
                .background(RoundedRectangle(cornerRadius: 12).fill(UITheme.bgCard))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(UITheme.textGold.opacity(0.55), lineWidth: 1.2))
            }
            .buttonStyle(DriftButtonStyle())
            .opacity(shown ? 1.0 : 0.0)
            .offset(y: shown ? 0.0 : 18.0)
            .animation(.easeOut(duration: 0.4).delay(0.12 * Double(idx)), value: shown)
        }
    }
}
