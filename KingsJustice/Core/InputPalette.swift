import Foundation

/// One colour per defensive action, shared by the touch buttons and the circles in the arena,
/// so the colour you see coming is the button you press.
enum InputPalette {
    /// When on, uses the Okabe-Ito colour-blind safe set instead of the default one.
    static var safeMode: Bool = false

    static var parry: String { return safeMode ? "#56b4e9" : "#6fb7ff" }   // blue
    static var duck: String { return safeMode ? "#f0e442" : "#f1c40f" }    // yellow
    static var jump: String { return safeMode ? "#009e73" : "#4cd08a" }    // green
    static var dodge: String { return safeMode ? "#d55e00" : "#ff5a3a" }   // red-orange
    static var grab: String { return safeMode ? "#cc79a7" : "#c58bff" }    // violet: parry + dodge together

    /// Hex colour for a defend input name; unknown inputs fall back to white.
    static func hex(for input: String) -> String {
        switch input {
        case "parry": return parry
        case "duck": return duck
        case "jump": return jump
        case "dodge": return dodge
        case "grab": return grab
        default: return "#ffffff"
        }
    }

    static let defendInputs: [String] = ["parry", "dodge", "duck", "jump"]
}
