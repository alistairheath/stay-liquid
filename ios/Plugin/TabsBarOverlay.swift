import UIKit

struct TabsBarItem {
    let id: String
    let title: String?
    let systemIcon: String?
    let image: String?
    var badge: TabsBarBadge?
}

enum TabsBarBadge {
    case number(Int)
    case dot
}

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
            tabBar.topAnchor.constraint(equalTo: view.topAnchor),          // NEW
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)      // CHANGED
        ])
    }

    func update(items: [TabsBarItem], initialId: String?, visible: Bool) {
        self.items = items
        idToIndex = Dictionary(uniqueKeysWithValues: items.enumerated().map { ($0.element.id, $0.offset) })

        let barItems: [UITabBarItem] = items.enumerated().map { (idx, model) in
            let image: UIImage?
            if let name = model.systemIcon {
                image = UIImage(systemName: name)
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
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func select(id: String) {
        guard let idx = idToIndex[id], let items = tabBar.items, idx < items.count else { return }
        tabBar.selectedItem = items[idx]
    }

    func setBadge(id: String, value: TabsBarBadge?) {
        guard let idx = idToIndex[id], let items = tabBar.items, idx < items.count else { return }
        applyBadge(value, to: items[idx])
    }

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
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let idx = item.tag
        guard idx >= 0, idx < items.count else { return }
        onSelected?(items[idx].id)
    }
}
