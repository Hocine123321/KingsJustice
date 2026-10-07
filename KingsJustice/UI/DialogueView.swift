import SwiftUI

/// Speech-bubble overlay for mid-combat enemy taunts and barks.
struct TauntBubbleView: View {
    let speaker: String
    let text: String
    
    @State private var visibleCount: Int = 0

    init(speaker: String, text: String) {
        self.speaker = speaker
        self.text = text
    }

    private var displayedText: String {
        guard visibleCount > 0 else { return "" }
        let count = min(visibleCount, text.count)
        return String(text.prefix(count))
    }

    var body: some View {
        VStack(alignment: .center, spacing: 3) {
            if !speaker.isEmpty {
                Text(speaker.uppercased())
                    .font(UITheme.kickFont)
                    .tracking(2.0)
                    .foregroundColor(UITheme.textGold)
                    .lineLimit(1)
            }

            Text(displayedText)
                .font(.system(size: 13, weight: .medium, design: .serif).italic())
                .foregroundColor(UITheme.textCreamBright)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: 380)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(UITheme.bgPanel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(UITheme.textGold.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.6), radius: 6, x: 0, y: 3)
        .task(id: text) {
            visibleCount = 0
            guard !text.isEmpty else { return }
            for i in 1...text.count {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: 18_000_000) // ~18ms per character
                if Task.isCancelled { break }
                visibleCount = i
            }
        }
    }
}

/// Reusable card view for pre-fight or post-victory campaign narration between fights.
struct StoryCardView: View {
    let title: String
    let subtitle: String?
    let bodyText: String
    let buttonTitle: String
    let onContinue: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        bodyText: String,
        buttonTitle: String = "Continue",
        onContinue: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.bodyText = bodyText
        self.buttonTitle = buttonTitle
        self.onContinue = onContinue
    }

    var body: some View {
        ZStack {
            UITheme.bgNearBlack.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle.uppercased())
                        .font(UITheme.kickFont)
                        .tracking(3.0)
                        .foregroundColor(UITheme.textMuted)
                }

                Text(title)
                    .font(UITheme.titleFont)
                    .foregroundColor(UITheme.textGold)
                    .multilineTextAlignment(.center)

                Rectangle()
                    .fill(UITheme.borderCream)
                    .frame(height: 1)
                    .frame(maxWidth: 160)
                    .padding(.vertical, 4)

                Text(bodyText)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(UITheme.textCreamBright)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                if let onContinue = onContinue {
                    PillButton(title: buttonTitle, isPrimary: true) {
                        onContinue()
                    }
                    .padding(.top, 12)
                }
            }
            .padding(28)
            .frame(maxWidth: 440)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(UITheme.bgPanel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(UITheme.borderCream, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.7), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 20)
        }
    }
}
