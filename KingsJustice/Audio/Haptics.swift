import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum Haptics {
    static func play(_ name: String) {
        #if canImport(UIKit)
        DispatchQueue.main.async {
            switch name.lowercased() {
            case "light":
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            case "medium":
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            case "heavy":
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()
            case "success":
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            case "warning":
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.warning)
            case "error":
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.error)
            case "tap":
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.prepare()
                generator.impactOccurred(intensity: 0.8)
            case "parry":
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.prepare()
                generator.impactOccurred()
            case "impact":
                // Double thump: a heavy hit followed by a short aftershock.
                let first = UIImpactFeedbackGenerator(style: .heavy)
                first.prepare()
                first.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    let second = UIImpactFeedbackGenerator(style: .rigid)
                    second.impactOccurred(intensity: 0.6)
                }
            case "perfect":
                let first = UIImpactFeedbackGenerator(style: .rigid)
                first.prepare()
                first.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    let second = UIImpactFeedbackGenerator(style: .heavy)
                    second.impactOccurred()
                }
            case "kill":
                let gen = UIImpactFeedbackGenerator(style: .heavy)
                gen.prepare()
                gen.impactOccurred()
                for k in 1...3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.09 * Double(k)) {
                        let g = UIImpactFeedbackGenerator(style: .heavy)
                        g.impactOccurred(intensity: 1.0 - 0.25 * Double(k))
                    }
                }
            case "select":
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            default:
                break
            }
        }
        #endif
    }
}
