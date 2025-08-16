import UIKit

/// Represents a tab item in the tab bar overlay
struct TabsBarItem {
    /// Unique identifier for the tab
    let id: String
    /// Optional title displayed under the icon
    let title: String?
    /// Optional system icon name (SF Symbol)
    let systemIcon: String?
    /// Optional custom image asset name
    let image: String?
    /// Optional badge value for the tab
    var badge: TabsBarBadge?
}


/// Represents different types of badges that can be displayed on a tab
enum TabsBarBadge {
    /// Numeric badge value
    case number(Int)
    /// Dot badge (typically used for notifications)
    case dot
}
/// A view controller that manages a tab bar overlay for Liquid Glass components
final class TabsBarOverlay: UIViewController, UITabBarDelegate {

    private(set) var items: [TabsBarItem] = []
    private var idToIndex: [String: Int] = [:]
    private let tabBar = UITabBar()
    var onSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Updates the tab bar with new items and configuration
    /// - Parameters:
    ///   - items: Array of tab items to display
    ///   - initialId: ID of the tab to select initially
    ///   - visible: Whether the tab bar should be visible
    /// - Note: This method should only be called on the main thread
    func update(items: [TabsBarItem], initialId: String?, visible: Bool) {
        self.items = items
        idToIndex = Dictionary(uniqueKeysWithValues: items.enumerated().map { ($0.element.id, $0.offset) })

        let barItems: [UITabBarItem] = items.enumerated().map { (idx, model) in
            let image: UIImage?
            if let name = model.systemIcon {
                // Validate system icon name by attempting to create image
                image = UIImage(systemName: name) ?? UIImage()
            } else if let asset = model.image {
                image = UIImage(named: asset)
            } else {
                image = nil
            }
            let item = UITabBarItem(title: model.title ?? "", image: image, tag: idx)
            applyBadge(model.badge, to: item)
            return item
        }
        tabBar.items = barItems

        if let initialId, let idx = idToIndex[initialId], let items = tabBar.items, idx < items.count {
            tabBar.selectedItem = items[idx]
        } else {
            tabBar.selectedItem = tabBar.items?.first
        }

        view.isHidden = !visible
    }

    /// Selects a tab by its ID
    /// - Parameter id: The ID of the tab to select
    func select(id: String) {
        guard let idx = idToIndex[id], let items = tabBar.items, idx < items.count else { return }
        tabBar.selectedItem = items[idx]
    }

    /// Sets a badge value for a specific tab
    /// - Parameters:
    ///   - id: The ID of the tab to update
    ///   - value: The badge value to set (nil to remove badge)
    func setBadge(id: String, value: TabsBarBadge?) {
        guard let idx = idToIndex[id], let items = tabBar.items, idx < items.count else { return }
        applyBadge(value, to: items[idx])
    }

    /// Applies a badge value to a UITabBarItem
    /// - Parameters:
    ///   - badge: The badge value to apply
    ///   - item: The UITabBarItem to update
    private func applyBadge(_ badge: TabsBarBadge?, to item: UITabBarItem) {
        switch badge {
        case .number(let n):
            item.badgeValue = n > 0 ? "\(n)" : nil
        case .dot:
            item.badgeValue = "•"
        case .none:
            item.badgeValue = nil
        }
    }

    // MARK: UITabBarDelegate
    /// Called when a tab is selected by the user
    /// - Parameters:
    ///   - tabBar: The tab bar that was selected
    ///   - item: The tab bar item that was selected
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let idx = item.tag
        guard idx >= 0, idx < items.count else { return }
        onSelected?(items[idx].id)
    }
}
