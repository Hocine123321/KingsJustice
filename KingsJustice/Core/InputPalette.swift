import Foundation

/// One colour per defensive action, shared by the touch buttons and the circles in the arena,
/// so the colour you see coming is the button you press.
enum InputPalette {
    static let parry = "#6fb7ff"   // icy blue
    static let duck = "#f1c40f"    // yellow
    static let jump = "#4cd08a"    // green
    static let dodge = "#ff5a3a"   // red-orange
    static let grab = "#c58bff"    // violet: parry + dodge together

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
