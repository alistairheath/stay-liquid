import SwiftUI
import UIKit
import Foundation

/// Represents an image icon configuration
struct ImageIcon {
    /// Shape of the icon container ("circle" or "square")
    let shape: String
    /// Image scaling behavior ("cover", "stretch", or "fit")
    let size: String
    /// Image source - either base64 data URI or HTTP/HTTPS URL
    let image: String
    /// Optional ring configuration for selected state
    let ring: ImageIconRing?
}

/// Represents ring configuration for image icons
struct ImageIconRing {
    /// Whether to show ring around selected image
    let enabled: Bool
    /// Width of the ring (default: 2.0)
    let width: Double?
}

/// Represents a tab item in the tab bar overlay
struct TabsBarItem: Identifiable {
    /// Unique identifier for the tab
    let id: String
    /// Optional title displayed under the icon
    let title: String?
    /// Optional system icon name (SF Symbol) - used as fallback
    let systemIcon: String
    /// Optional custom image asset name
    let image: String?
    /// Optional enhanced image icon configuration
    let imageIcon: ImageIcon?
    /// Optional badge value for the tab
    var badge: TabsBarBadge?
}

/// Represents different types of badges that can be displayed on a tab
enum TabsBarBadge: Equatable {
    /// Numeric badge value
    case number(Int)
    /// Dot badge (typically used for notifications)
    case dot
}

/// A view controller that manages a tab bar overlay for Liquid Glass components
final class TabsBarOverlay: UIViewController {

    private var hostingController: UIHostingController<AnyView>?
    private var currentItems: [TabsBarItem] = []
    private var currentInitialId: String?
    private var currentVisible: Bool = false
    private var currentSelectedIconColor: UIColor?
    private var currentUnselectedIconColor: UIColor?
    
    var onSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    /// Updates the tab bar with new items and configuration
    /// - Parameters:
    ///   - items: Array of tab items to display
    ///   - initialId: ID of the tab to select initially
    ///   - visible: Whether the tab bar should be visible
    ///   - selectedIconColor: Optional color for selected tab icons
    ///   - unselectedIconColor: Optional color for unselected tab icons
    /// - Note: This method should only be called on the main thread
    func update(items: [TabsBarItem], initialId: String?, visible: Bool, selectedIconColor: UIColor? = nil, unselectedIconColor: UIColor? = nil) {
        self.currentItems = items
        self.currentInitialId = initialId
        self.currentVisible = visible
        self.currentSelectedIconColor = selectedIconColor
        self.currentUnselectedIconColor = unselectedIconColor
        
        if hostingController == nil {
            setupHostingController()
        }
        
        updateSwiftUIContent()
        view.isHidden = !visible
    }

    /// Selects a tab by its ID
    /// - Parameter id: The ID of the tab to select
    func select(id: String) {
        self.currentInitialId = id
        updateSwiftUIContent()
    }

    /// Sets a badge value for a specific tab
    /// - Parameters:
    ///   - id: The ID of the tab to update
    ///   - value: The badge value to set (nil to remove badge)
    func setBadge(id: String, value: TabsBarBadge?) {
        if let index = currentItems.firstIndex(where: { $0.id == id }) {
            currentItems[index].badge = value
            updateSwiftUIContent()
        }
    }
    
    private func setupHostingController() {
        let tabsBarView = TabsBarView(
            items: currentItems,
            initialId: currentInitialId,
            selectedIconColor: currentSelectedIconColor,
            unselectedIconColor: currentUnselectedIconColor,
            onSelected: { [weak self] id in
                self?.onSelected?(id)
            }
        )
        
        hostingController = UIHostingController(rootView: AnyView(tabsBarView))
        
        guard let hc = hostingController else { return }
        
        addChild(hc)
        view.addSubview(hc.view)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hc.didMove(toParent: self)
    }
    
    private func updateSwiftUIContent() {
        guard let hc = hostingController else { return }
        
        let tabsBarView = TabsBarView(
            items: currentItems,
            initialId: currentInitialId,
            selectedIconColor: currentSelectedIconColor,
            unselectedIconColor: currentUnselectedIconColor,
            onSelected: { [weak self] id in
                self?.onSelected?(id)
            }
        )
        hc.rootView = AnyView(tabsBarView)
    }
}

// MARK: - SwiftUI Views

struct TabsBarView: View {
    let items: [TabsBarItem]
    @State var selectedId: String?
    let selectedIconColor: UIColor?
    let unselectedIconColor: UIColor?
    let onSelected: (String) -> Void
    
    init(items: [TabsBarItem], initialId: String?, selectedIconColor: UIColor?, unselectedIconColor: UIColor?, onSelected: @escaping (String) -> Void) {
        self.items = items
        _selectedId = State(initialValue: initialId ?? items.first?.id)
        self.selectedIconColor = selectedIconColor
        self.unselectedIconColor = unselectedIconColor
        self.onSelected = onSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                ForEach(items) { item in
                    Button(action: {
                        selectedId = item.id
                        onSelected(item.id)
                    }) {
                        VStack(spacing: 4) {
                            TabIconView(item: item, isSelected: item.id == selectedId, selectedIconColor: selectedIconColor, unselectedIconColor: unselectedIconColor)
                            if let title = item.title {
                                Text(title)
                                    .font(.caption2)
                                    .foregroundColor(item.id == selectedId ? Color(selectedIconColor ?? .systemBlue) : Color(unselectedIconColor ?? .systemGray))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color.white) // Or your desired background color
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct TabIconView: View {
    let item: TabsBarItem
    let isSelected: Bool
    let selectedIconColor: UIColor?
    let unselectedIconColor: UIColor?

    @State private var iconImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let uiImage = iconImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24) // Standard icon size
                        .foregroundColor(isSelected ? Color(selectedIconColor ?? .systemBlue) : Color(unselectedIconColor ?? .systemGray))
                } else {
                    Image(systemName: item.systemIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(isSelected ? Color(selectedIconColor ?? .systemBlue) : Color(unselectedIconColor ?? .systemGray))
                }
            }
            .onAppear(perform: loadImage)
            .onChange(of: item.imageIcon?.image) { _ in loadImage() } // Reload if image source changes
            .onChange(of: isSelected) { _ in loadImage() } // Reload to apply ring if selection changes

            if let badge = item.badge {
                BadgeView(badge: badge)
                    .offset(x: 8, y: -8) // Adjust position as needed
            }
        }
    }
    
    private func loadImage() {
        if let imageIcon = item.imageIcon {
            ImageUtils.processImageIcon(JSImageIcon(shape: imageIcon.shape, size: imageIcon.size, image: imageIcon.image, ring: imageIcon.ring)) { image in
                DispatchQueue.main.async {
                    if let img = image {
                        let ringColor = self.isSelected ? self.selectedIconColor : self.unselectedIconColor
                        if let ring = imageIcon.ring, ring.enabled {
                            self.iconImage = ImageUtils.addEnhancedRingToImage(img, ringWidth: CGFloat(ring.width ?? 2.0), ringColor: ringColor ?? (self.isSelected ? .systemBlue : .systemGray))
                        } else {
                            self.iconImage = img
                        }
                    } else {
                        self.iconImage = UIImage(systemName: self.item.systemIcon)
                    }
                }
            }
        } else {
            self.iconImage = UIImage(systemName: self.item.systemIcon)
        }
    }
}

struct BadgeView: View {
    let badge: TabsBarBadge

    var body: some View {
        Group {
            switch badge {
            case .number(let n):
                Text("\(n)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
            case .dot:
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

