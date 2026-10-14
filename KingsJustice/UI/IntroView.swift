import SwiftUI

/// The three story beats shown once, on the first launch.
enum IntroStory {
    static let lines: [String] = [
        "The kingdom lies shattered. Its king rules from a hollow throne.",
        "Six champions guard the road to him. Each holds a battlefield, and each fights to a beat.",
        "Read the beat. Parry the blade. Break the king."
    ]

    /// Index of the line after this one, or nil when the story is over.
    static func next(after index: Int) -> Int? {
        let n = index + 1
        return n < lines.count ? n : nil
    }

    static func shouldShow(save: SaveData) -> Bool {
        return save.seen["intro"] != true
    }
}

/// A short text-only story hook. Tap to continue, or Skip. It advances on its own too.
struct IntroView: View {
    let onDone: () -> Void
    @State private var index: Int = 0
    @State private var finished: Bool = false

    private func advance() {
        guard !finished else { return }
        if let n = IntroStory.next(after: index) {
            index = n
        } else {
            finish()
        }
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        onDone()
    }

    var body: some View {
        ZStack {
            BackgroundGradientView()

            VStack(spacing: 18) {
                Spacer()
                Text(L10n.t(IntroStory.lines[index]))
                    .font(.system(size: 22, weight: .regular, design: .serif).italic())
                    .foregroundColor(UITheme.textCreamBright)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 32)
                    .id(index)
                    .transition(.opacity)
                HStack(spacing: 8) {
                    ForEach(0..<IntroStory.lines.count, id: \.self) { i in
                        Circle()
                            .fill(i == index ? UITheme.textGold : UITheme.textCream.opacity(0.25))
                            .frame(width: 6, height: 6)
                    }
                }
                Spacer()
            }

            VStack {
                HStack {
                    Spacer()
                    PillButton(title: "Skip", action: finish)
                        .frame(width: 110)
                }
                .padding(16)
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { advance() }
        .task(id: index) {
            try? await Task.sleep(nanoseconds: 3_600_000_000)
            if !Task.isCancelled { advance() }
        }
        .animation(.easeInOut(duration: 0.6), value: index)
    }
}
