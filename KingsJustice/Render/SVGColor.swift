import SwiftUI

public enum SVGFill: Equatable {
    case none
    case color(Color)
    case url(id: String, fallback: Color?)
}

public struct SVGColorParser {
    public static func parseColor(_ string: String) -> Color? {
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if str == "none" || str == "transparent" {
            return Color.clear
        }

        if str.hasPrefix("#") {
            let hex = String(str.dropFirst())
            return parseHexColor(hex)
        }

        if str.hasPrefix("rgb") {
            return parseRGBString(str)
        }

        switch str {
        case "black": return Color(red: 0, green: 0, blue: 0)
        case "white": return Color(red: 1, green: 1, blue: 1)
        case "red": return Color(red: 1, green: 0, blue: 0)
        case "green": return Color(red: 0, green: 0.8, blue: 0)
        case "blue": return Color(red: 0, green: 0, blue: 1)
        case "gold": return Color(red: 0.96, green: 0.85, blue: 0.52)
        case "yellow": return Color(red: 1, green: 1, blue: 0)
        case "gray", "grey": return Color(red: 0.5, green: 0.5, blue: 0.5)
        case "darkgray", "darkgrey": return Color(red: 0.2, green: 0.2, blue: 0.2)
        case "lightgray", "lightgrey": return Color(red: 0.8, green: 0.8, blue: 0.8)
        default:
            return nil
        }
    }

    public static func parseHexColor(_ hexString: String) -> Color? {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var intVal: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&intVal) else { return nil }

        let r: Double
        let g: Double
        let b: Double
        let a: Double

        switch hex.count {
        case 3: // #rgb
            r = Double((intVal >> 8) & 0xF) / 15.0
            g = Double((intVal >> 4) & 0xF) / 15.0
            b = Double(intVal & 0xF) / 15.0
            a = 1.0
        case 4: // #rgba
            r = Double((intVal >> 12) & 0xF) / 15.0
            g = Double((intVal >> 8) & 0xF) / 15.0
            b = Double((intVal >> 4) & 0xF) / 15.0
            a = Double(intVal & 0xF) / 15.0
        case 6: // #rrggbb
            r = Double((intVal >> 16) & 0xFF) / 255.0
            g = Double((intVal >> 8) & 0xFF) / 255.0
            b = Double(intVal & 0xFF) / 255.0
            a = 1.0
        case 8: // #rrggbbaa
            r = Double((intVal >> 24) & 0xFF) / 255.0
            g = Double((intVal >> 16) & 0xFF) / 255.0
            b = Double((intVal >> 8) & 0xFF) / 255.0
            a = Double(intVal & 0xFF) / 255.0
        default:
            return nil
        }

        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    private static func parseRGBString(_ str: String) -> Color? {
        let components = str.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted)
            .filter { !$0.isEmpty }
            .compactMap { Double($0) }

        if components.count >= 3 {
            let r = components[0] > 1.0 ? components[0] / 255.0 : components[0]
            let g = components[1] > 1.0 ? components[1] / 255.0 : components[1]
            let b = components[2] > 1.0 ? components[2] / 255.0 : components[2]
            let a = components.count >= 4 ? components[3] : 1.0
            return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
        }
        return nil
    }

    public static func parseFill(_ string: String) -> SVGFill {
        let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.lowercased() == "none" || str.isEmpty {
            return .none
        }

        if str.hasPrefix("url(#") {
            // e.g. "url(#kS) #5d6877" or "url(#wall)"
            guard let closeParen = str.firstIndex(of: ")") else {
                return .none
            }
            let startIdx = str.index(str.startIndex, offsetBy: 5) // after "url(#"
            let id = String(str[startIdx..<closeParen])

            let remainder = String(str[str.index(after: closeParen)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            var fallback: Color? = nil
            if !remainder.isEmpty {
                fallback = parseColor(remainder)
            }
            return .url(id: id, fallback: fallback)
        }

        if let color = parseColor(str) {
            return .color(color)
        }
        return .none
    }

    public static func shadeHex(_ hex: String, _ k: Double) -> String {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard clean.count == 6, let val = UInt32(clean, radix: 16) else { return hex }
        var r = Double((val >> 16) & 0xFF)
        var g = Double((val >> 8) & 0xFF)
        var b = Double(val & 0xFF)
        let target: Double = k < 0 ? 0.0 : 255.0
        let p = abs(k)
        r = round((target - r) * p + r)
        g = round((target - g) * p + g)
        b = round((target - b) * p + b)
        let ri = min(255, max(0, Int(r)))
        let gi = min(255, max(0, Int(g)))
        let bi = min(255, max(0, Int(b)))
        return String(format: "#%02x%02x%02x", ri, gi, bi)
    }
}
