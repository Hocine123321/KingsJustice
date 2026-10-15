import Foundation

/// A short walk through every defend input in the Training Yard: answer each one cleanly a few times, then move on.
struct GuidedPractice: Equatable {
    static let steps: [String] = ["parry", "duck", "jump", "dodge", "grab"]
    /// Clean answers (Perfect or Good, not a scraped late one) needed in each step.
    static let required = 4

    private(set) var stepIndex: Int = 0
    private(set) var count: Int = 0
    private(set) var finished: Bool = false

    enum Outcome: Equatable {
        case counted, stepDone, allDone, ignored
    }

    /// The input being practised, or nil once every step is done.
    var currentDrill: String? {
        return finished ? nil : GuidedPractice.steps[stepIndex]
    }

    /// For the HUD label, e.g. "PARRY 2/4 (1/5)".
    var progressText: String {
        guard let d = currentDrill else { return "DONE" }
        let name = TrainingGuide.drills.first(where: { $0.id == d })?.name ?? d
        return "\(name.uppercased()) \(count)/\(GuidedPractice.required) (\(stepIndex + 1)/\(GuidedPractice.steps.count))"
    }

    /// Registers one clean defend. Answers to any other input do not count.
    mutating func register(input: String) -> Outcome {
        guard let d = currentDrill, input == d else { return .ignored }
        count += 1
        if count < GuidedPractice.required { return .counted }
        count = 0
        stepIndex += 1
        if stepIndex >= GuidedPractice.steps.count {
            finished = true
            return .allDone
        }
        return .stepDone
    }
}

extension GameEngine {
    var guidedActive: Bool { return guided != nil }

    func startGuidedPractice() {
        guard training else { return }
        let g = GuidedPractice()
        guided = g
        drill = g.currentDrill
    }

    func cancelGuidedPractice() {
        guided = nil
    }

    /// Called for every clean defend. Moves the drill on when a step is complete.
    func registerGuidedSuccess(input: String) {
        guard var g = guided else { return }
        let outcome = g.register(input: input)
        guided = g
        switch outcome {
        case .counted, .ignored:
            break
        case .stepDone:
            drill = g.currentDrill
            say("Step complete", col: "#9be8a8")
        case .allDone:
            drill = nil
            guided = nil
            say("Practice complete", col: "#9be8a8")
        }
    }
}
