import SwiftUI

/// Beat position of the running fight, so the Training Yard can show a metronome.
protocol BeatClockProviding: AnyObject {
    /// 0 at the start of a beat, rising to just under 1 at the next one.
    var beatPhase: Double { get }
}

extension GameEngine: BeatClockProviding {
    var beatPhase: Double {
        guard bpm > 0.0 else { return 0.0 }
        let beats = t / (60.0 / bpm)
        return beats - floor(beats)
    }
}

/// Lets the pause screen pick a Training Yard drill.
protocol TrainingDrillControlling: AnyObject {
    var drill: String? { get set }
    var guidedActive: Bool { get }
    func startGuidedPractice()
    func cancelGuidedPractice()
}

extension GameEngine: TrainingDrillControlling {}

/// The Training Yard move list: what each button is for and which ring colour it answers.
enum TrainingGuide {
    struct Move: Equatable {
        let id: String
        let name: String
        /// Key into InputPalette, or nil for moves that have no ring colour.
        let paletteKey: String?
        let how: String
    }

    static let moves: [Move] = [
        Move(id: "parry", name: "Parry", paletteKey: "parry", how: "Tap Parry as the blue ring closes. Perfect parries build your combo."),
        Move(id: "dodge", name: "Dodge", paletteKey: "dodge", how: "Tap Dodge as the red-orange ring closes."),
        Move(id: "duck", name: "Duck", paletteKey: "duck", how: "Tap Duck as the yellow ring closes."),
        Move(id: "jump", name: "Jump", paletteKey: "jump", how: "Tap Jump as the green ring closes."),
        Move(id: "grab", name: "Grab", paletteKey: "grab", how: "A violet ring needs Parry and Dodge together."),
        Move(id: "strike", name: "Strike", paletteKey: nil, how: "On your turn, tap Slash, Thrust or Overhead as the ring closes."),
        Move(id: "focus", name: "Focus", paletteKey: nil, how: "Fill the meter with good timing, then tap Focus. You hit harder and your timing windows widen. Enemies do not get easier."),
        Move(id: "heal", name: "Heal", paletteKey: nil, how: "Tap Heal to drink a tonic and restore health.")
    ]

    struct Drill: Equatable {
        /// The input the drill repeats; matches the move's input in GameData.
        let id: String
        let name: String
        /// The enemy move that asks for that input.
        let move: String
    }

    /// Single-input practice: every defend note becomes this input until the drill is turned off.
    static let drills: [Drill] = [
        Drill(id: "parry", name: "Parry", move: "slash"),
        Drill(id: "duck", name: "Duck", move: "low"),
        Drill(id: "jump", name: "Jump", move: "high"),
        Drill(id: "dodge", name: "Dodge", move: "unblockable"),
        Drill(id: "grab", name: "Grab", move: "grab")
    ]

    static func drillMove(for id: String?) -> String? {
        guard let id = id else { return nil }
        return drills.first(where: { $0.id == id })?.move
    }

    /// 1.0 on the beat, fading to 0 well before the next one.
    static func metronomePulse(phase: Double) -> Double {
        let p = phase - floor(phase)
        return max(0.0, 1.0 - p * 3.0)
    }
}

/// A small dot that flashes on every beat. Only shown in the Training Yard.
struct TrainingMetronomeView: View {
    let clock: BeatClockProviding?

    var body: some View {
        TimelineView(.animation) { _ in
            let pulse = TrainingGuide.metronomePulse(phase: clock?.beatPhase ?? 0.0)
            Circle()
                .fill(UITheme.textGold.opacity(0.25 + 0.75 * pulse))
                .frame(width: 8.0 + 6.0 * pulse, height: 8.0 + 6.0 * pulse)
                .shadow(color: UITheme.textGold.opacity(0.6 * pulse), radius: 6)
                .frame(width: 16, height: 16)
        }
        .accessibilityHidden(true)
    }
}

struct TrainingGuideView: View {
    var drills: TrainingDrillControlling?
    let onDone: () -> Void
    @State private var selected: String?
    @State private var guidedOn: Bool

    init(drills: TrainingDrillControlling? = nil, onDone: @escaping () -> Void) {
        self.drills = drills
        self.onDone = onDone
        _selected = State(initialValue: drills?.drill)
        _guidedOn = State(initialValue: drills?.guidedActive ?? false)
    }

    var body: some View {
        ZStack {
            UITheme.bgNearBlack.opacity(0.92).ignoresSafeArea()
            VStack(spacing: 10) {
                Text("MOVE LIST")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(4.0)
                    .foregroundColor(UITheme.textGold)
                    .padding(.top, 14)
                if drills != nil {
                    drillBar
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(TrainingGuide.moves, id: \.id) { move in
                            row(move)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                PillButton(title: "Done", isPrimary: true, action: onDone)
                    .padding(.bottom, 14)
            }
        }
    }

    private var drillBar: some View {
        VStack(spacing: 6) {
            Text("DRILL · ONLY THIS INPUT")
                .font(.system(size: 9, weight: .bold))
                .tracking(3.0)
                .foregroundColor(UITheme.textCream.opacity(0.7))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    guidedChip
                    chip(id: nil, name: "Free")
                    ForEach(TrainingGuide.drills, id: \.id) { d in
                        chip(id: d.id, name: d.name)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var guidedChip: some View {
        Button(action: {
            guidedOn = true
            selected = nil
            drills?.startGuidedPractice()
        }) {
            Text("Guided practice")
                .font(.system(size: 11, weight: .bold))
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundColor(guidedOn ? UITheme.bgNearBlack : UITheme.textCream)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(guidedOn ? UITheme.textGold : UITheme.bgCard))
                .overlay(Capsule().stroke(UITheme.borderCream.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(DriftButtonStyle())
    }

    private func chip(id: String?, name: String) -> some View {
        let on = !guidedOn && (selected == id)
        return Button(action: {
            guidedOn = false
            drills?.cancelGuidedPractice()
            selected = id
            drills?.drill = id
        }) {
            Text(L10n.t(name).uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(2.0)
                .foregroundColor(on ? UITheme.bgNearBlack : UITheme.textCream)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(on ? UITheme.textGold : UITheme.bgCard))
                .overlay(Capsule().stroke(UITheme.borderCream.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(DriftButtonStyle())
    }

    private func row(_ move: TrainingGuide.Move) -> some View {
        let tint = move.paletteKey.map { Color(hex: InputPalette.hex(for: $0)) } ?? UITheme.textCream
        return HStack(alignment: .top, spacing: 10) {
            Circle()
                .stroke(tint, lineWidth: 3)
                .frame(width: 18, height: 18)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.t(move.name).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2.0)
                    .foregroundColor(tint)
                Text(L10n.t(move.how))
                    .font(.system(size: 11))
                    .foregroundColor(UITheme.textCream.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(UITheme.bgCard))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(UITheme.borderCream.opacity(0.2), lineWidth: 1))
    }
}
