import UIKit

/// Utility class for parsing and validating color strings
class ColorUtils {
    
    /// Parses a hex color string to UIColor
    /// - Parameter hex: Hex color string (e.g., "#FF5733", "#F57", "#FF5733FF")
    /// - Returns: UIColor if valid, nil otherwise
    static func parseHexColor(_ hex: String) -> UIColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove # if present
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // Validate length
        guard hexString.count == 3 || hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        
        // Expand 3-digit hex to 6-digit
        if hexString.count == 3 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }
        
        // Parse components
        var alpha: CGFloat = 1.0
        if hexString.count == 8 {
            let alphaHex = String(hexString.suffix(2))
            hexString = String(hexString.prefix(6))
            if let alphaInt = Int(alphaHex, radix: 16) {
                alpha = CGFloat(alphaInt) / 255.0
            }
        }
        
        guard let colorInt = Int(hexString, radix: 16) else {
            return nil
        }
        
        let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
        let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
        let blue = CGFloat(colorInt & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Parses an RGBA color string to UIColor
    /// - Parameter rgba: RGBA color string (e.g., "rgba(255, 87, 51, 0.8)")
    /// - Returns: UIColor if valid, nil otherwise
    static func parseRgbaColor(_ rgba: String) -> UIColor? {
        let pattern = #"rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*([01](?:\.\d+)?))?\s*\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: rgba.utf16.count)
        guard let match = regex.firstMatch(in: rgba, options: [], range: range) else {
            return nil
        }
        
        func extractValue(at index: Int) -> Double? {
            let range = match.range(at: index)
            guard range.location != NSNotFound else { return nil }
            let substring = (rgba as NSString).substring(with: range)
            return Double(substring)
        }
        
        guard let red = extractValue(at: 1),
              let green = extractValue(at: 2),
              let blue = extractValue(at: 3) else {
            return nil
        }
        
        let alpha = extractValue(at: 4) ?? 1.0
        
        // Validate ranges
        guard red >= 0 && red <= 255 &&
              green >= 0 && green <= 255 &&
              blue >= 0 && blue <= 255 &&
              alpha >= 0 && alpha <= 1 else {
            return nil
        }
        
        return UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    /// Parses a color string (hex or RGBA) to UIColor
    /// - Parameter colorString: Color string in hex or RGBA format
    /// - Returns: UIColor if valid, nil otherwise
    static func parseColor(_ colorString: String?) -> UIColor? {
        guard let colorString = colorString?.trimmingCharacters(in: .whitespacesAndNewlines),
              !colorString.isEmpty else {
            return nil
        }
        
        if colorString.hasPrefix("#") {
            return parseHexColor(colorString)
        } else if colorString.lowercased().hasPrefix("rgba") || colorString.lowercased().hasPrefix("rgb") {
            return parseRgbaColor(colorString)
        }
        
        return nil
    }
}