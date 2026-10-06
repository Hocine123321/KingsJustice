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
