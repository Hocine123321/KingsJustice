import SwiftUI

extension Color {
    /// Initialize a Color from a hex string supporting #rgb, #rrggbb, or #aarrggbb format.
    init(hex: String) {
        var cleanHex: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        let length: Int = cleanHex.count
        switch length {
        case 3: // #RGB
            red = Double((rgbValue >> 8) & 0xF) / 15.0
            green = Double((rgbValue >> 4) & 0xF) / 15.0
            blue = Double(rgbValue & 0xF) / 15.0
            alpha = 1.0
        case 6: // #RRGGBB
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
            alpha = 1.0
        case 8: // #AARRGGBB
            alpha = Double((rgbValue >> 24) & 0xFF) / 255.0
            red = Double((rgbValue >> 16) & 0xFF) / 255.0
            green = Double((rgbValue >> 8) & 0xFF) / 255.0
            blue = Double(rgbValue & 0xFF) / 255.0
        default:
            red = 1.0
            green = 1.0
            blue = 1.0
            alpha = 1.0
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
