import Capacitor
import UIKit

// Helper decode
private struct JSItem: Decodable {
    let id: String
    let title: String?
    let systemIcon: String?
    let image: String?
    let badge: JSBadge?
}
private enum JSBadge: Decodable {
    case number(Int)
    case dot
    case null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let s = try? c.decode(String.self), s == "dot" { self = .dot; return }
        if let n = try? c.decode(Int.self) { self = .number(n); return }
        self = .null
    }
}

@objc(TabsBarPlugin)
public class TabsBarPlugin: CAPPlugin {

    private var overlayVC: TabsBarOverlay?

    public override func load() {
        // Lazy creation on first configure()
    }

    @objc func configure(_ call: CAPPluginCall) {
        guard let itemsArr = call.getArray("items", JSObject.self) else {
            call.reject("Missing 'items'")
            return
        }

        // JSON → Decodable
        let data = try? JSONSerialization.data(withJSONObject: itemsArr, options: [])
        guard let data else { call.reject("Invalid items"); return }
        let jsItems = (try? JSONDecoder().decode([JSItem].self, from: data)) ?? []

        let initialId = call.getString("initialId")
        let visible = call.getBool("visible") ?? true

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
            self.overlayVC?.update(items: items, initialId: initialId, visible: visible)
        }
        call.resolve()
    }

    @objc func show(_ call: CAPPluginCall) {
        DispatchQueue.main.async { self.overlayVC?.view.isHidden = false }
        call.resolve()
    }

    @objc func hide(_ call: CAPPluginCall) {
        DispatchQueue.main.async { self.overlayVC?.view.isHidden = true }
        call.resolve()
    }

    @objc func select(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else { call.reject("Missing 'id'"); return }
        DispatchQueue.main.async { self.overlayVC?.select(id: id) }
        call.resolve()
    }

    @objc func setBadge(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else { call.reject("Missing 'id'"); return }
        let badgeValue: TabsBarBadge? = {
            if call.getString("value") == "dot" { return .dot }
            if call.getValue("value") is NSNull { return nil }
            if let n = call.getInt("value") { return .number(n) }
            return nil
        }()
        DispatchQueue.main.async { self.overlayVC?.setBadge(id: id, value: badgeValue) }
        call.resolve()
    }

    @objc func getSafeAreaInsets(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let v = self.bridge?.viewController?.view
            let i = v?.safeAreaInsets ?? .zero
            call.resolve([
                "top": i.top, "bottom": i.bottom, "left": i.left, "right": i.right
            ])
        }
    }

    private func ensureOverlay() {
        guard overlayVC == nil else { return }
        guard let hostVC = bridge?.viewController else { return }

        let overlay = TabsBarOverlay()
        overlay.onSelected = { [weak self] id in
            self?.notifyListeners("selected", data: ["id": id])
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
