import Capacitor
import UIKit

// MARK: - Color Utilities

/// Utility class for parsing and validating color strings
private class ColorUtils {
    
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

// Helper decode
/// Represents a tab item as received from JavaScript
private struct JSItem: Decodable {
    /// Unique identifier for the tab
    let id: String
    /// Optional title displayed under the icon
    let title: String?
    /// Optional system icon name (SF Symbol)
    let systemIcon: String?
    /// Optional custom image asset name
    let image: String?
    /// Optional badge value for the tab
    let badge: JSBadge?
}
/// Represents different types of badges that can be received from JavaScript
private enum JSBadge: Decodable {
    /// Numeric badge value
    case number(Int)
    /// Dot badge (typically used for notifications)
    case dot
    /// No badge
    case null

    /// Initializes a JSBadge from a decoder
    /// - Parameter decoder: The decoder to use
    /// - Throws: Decoding errors if the value cannot be decoded
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let s = try? c.decode(String.self), s == "dot" { self = .dot; return }
        if let n = try? c.decode(Int.self) { self = .number(n); return }
        self = .null
    }
}

/// Plugin for managing Liquid Glass tab bar overlays in Ionic applications
@objc(TabsBarPlugin)
public class TabsBarPlugin: CAPPlugin {

    private var overlayVC: TabsBarOverlay? {
        didSet {
            // Clean up old overlay if it exists
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParent()
        }
    }

    public override func load() {
        // Lazy creation on first configure()
    }

    /// Helper method for consistent error handling
    private func handleError(_ call: CAPPluginCall, message: String) {
        call.reject(message)
    }

    /// Configures the tab bar with the provided options
    /// - Parameter call: The Capacitor plugin call with configuration options
    @objc func configure(_ call: CAPPluginCall) {
        guard let itemsArr = call.getArray("items", JSObject.self) else {
            self.handleError(call, message: "Missing 'items'")
            return
        }

        // JSON → Decodable
        let data = try? JSONSerialization.data(withJSONObject: itemsArr, options: [])
        guard let data else { self.handleError(call, message: "Invalid items"); return }
        let jsItems: [JSItem]
        do {
            jsItems = try JSONDecoder().decode([JSItem].self, from: data)
        } catch {
            self.handleError(call, message: "Failed to decode items: \(error)")
            return
        }

        // Validate items array is not empty
        guard !jsItems.isEmpty else {
            self.handleError(call, message: "Items array cannot be empty")
            return
        }

        // Validate each item has a valid ID
        for item in jsItems {
            guard !item.id.isEmpty else {
                self.handleError(call, message: "Each item must have a non-empty 'id'")
                return
            }
        }

        let initialId = call.getString("initialId")
        let visible = call.getBool("visible") ?? true
        
        // Parse color options
        let selectedIconColor = ColorUtils.parseColor(call.getString("selectedIconColor"))
        let unselectedIconColor = ColorUtils.parseColor(call.getString("unselectedIconColor"))
        
        // Log warnings for invalid colors but continue with defaults
        if call.getString("selectedIconColor") != nil && selectedIconColor == nil {
            print("TabsBar Warning: Invalid selectedIconColor format, using default")
        }
        if call.getString("unselectedIconColor") != nil && unselectedIconColor == nil {
            print("TabsBar Warning: Invalid unselectedIconColor format, using default")
        }

        let items: [TabsBarItem] = jsItems.map { js in
            // Make the type explicit so the compiler is happy
            let badge: TabsBarBadge? = {
                guard let b = js.badge else { return nil }
                switch b {
                case .number(let n): return .number(n)
                case .dot:           return .dot
                case .null:          return nil
                }
            }()

            return TabsBarItem(
                id: js.id,
                title: js.title,
                systemIcon: js.systemIcon,
                image: js.image,
                badge: badge
            )
        }

        DispatchQueue.main.async {
            self.ensureOverlay()
            // Ensure overlay is properly initialized before updating
            guard let overlay = self.overlayVC else {
                self.handleError(call, message: "Failed to initialize overlay")
                return
            }
            overlay.update(
                items: items,
                initialId: initialId,
                visible: visible,
                selectedIconColor: selectedIconColor,
                unselectedIconColor: unselectedIconColor
            )
        }
        call.resolve()
    }

    /// Shows the tab bar overlay
    /// - Parameter call: The Capacitor plugin call
    @objc func show(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let overlay = self.overlayVC else {
                self.handleError(call, message: "Overlay not initialized")
                return
            }
            overlay.view.isHidden = false
        }
        call.resolve()
    }

    /// Hides the tab bar overlay
    /// - Parameter call: The Capacitor plugin call
    @objc func hide(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let overlay = self.overlayVC else {
                self.handleError(call, message: "Overlay not initialized")
                return
            }
            overlay.view.isHidden = true
        }
        call.resolve()
    }

    /// Selects a specific tab by ID
    /// - Parameter call: The Capacitor plugin call with the ID of the tab to select
    @objc func select(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else { self.handleError(call, message: "Missing 'id'"); return }
        DispatchQueue.main.async {
            guard let overlay = self.overlayVC else {
                self.handleError(call, message: "Overlay not initialized")
                return
            }
            overlay.select(id: id)
        }
        call.resolve()
    }

    /// Sets a badge value for a specific tab
    /// - Parameter call: The Capacitor plugin call with the tab ID and badge value
    @objc func setBadge(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else { self.handleError(call, message: "Missing 'id'"); return }
        let badgeValue: TabsBarBadge? = {
            if call.getString("value") == "dot" { return .dot }
            if call.getValue("value") is NSNull { return nil }
            if let n = call.getInt("value") {
                // Validate badge number is not negative
                if n < 0 { return nil }
                return .number(n)
            }
            return nil
        }()
        DispatchQueue.main.async {
            guard let overlay = self.overlayVC else {
                self.handleError(call, message: "Overlay not initialized")
                return
            }
            overlay.setBadge(id: id, value: badgeValue)
        }
        call.resolve()
    }

    /// Gets the safe area insets for the current view
    /// - Parameter call: The Capacitor plugin call
    @objc func getSafeAreaInsets(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let v = self.bridge?.viewController?.view
            let i = v?.safeAreaInsets ?? .zero
            call.resolve([
                "top": i.top, "bottom": i.bottom, "left": i.left, "right": i.right
            ])
        }
    }

    /// Ensures the overlay view controller is created and properly configured
    private func ensureOverlay() {
        guard overlayVC == nil else { return }
        guard let hostVC = bridge?.viewController else { return }

        let overlay = TabsBarOverlay()
        overlay.onSelected = { [weak self, weak overlay] id in
            guard let self = self, let overlay = overlay else { return }
            self.notifyListeners("selected", data: ["id": id])
        }

        hostVC.addChild(overlay)
        hostVC.view.addSubview(overlay.view)
        overlay.view.translatesAutoresizingMaskIntoConstraints = false
        overlay.didMove(toParent: hostVC)

        NSLayoutConstraint.activate([
            overlay.view.leadingAnchor.constraint(equalTo: hostVC.view.leadingAnchor),
            overlay.view.trailingAnchor.constraint(equalTo: hostVC.view.trailingAnchor),
            overlay.view.bottomAnchor.constraint(equalTo: hostVC.view.bottomAnchor)
        ])

        self.overlayVC = overlay
    }
}
