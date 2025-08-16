import UIKit

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
struct TabsBarItem {
    /// Unique identifier for the tab
    let id: String
    /// Optional title displayed under the icon
    let title: String?
    /// Optional system icon name (SF Symbol) - used as fallback
    let systemIcon: String?
    /// Optional custom image asset name
    let image: String?
    /// Optional enhanced image icon configuration
    let imageIcon: ImageIcon?
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
    
    // Color configuration
    private var selectedIconColor: UIColor?
    private var unselectedIconColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.topAnchor.constraint(equalTo: view.topAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        self.items = items
        self.selectedIconColor = selectedIconColor
        self.unselectedIconColor = unselectedIconColor
        idToIndex = Dictionary(uniqueKeysWithValues: items.enumerated().map { ($0.element.id, $0.offset) })

        let barItems: [UITabBarItem] = items.enumerated().map { (idx, model) in
            let item = UITabBarItem(title: model.title ?? "", image: nil, tag: idx)
            applyBadge(model.badge, to: item)
            
            // Load image with priority: imageIcon > systemIcon > image > placeholder
          self.loadImageForItem(model, tabBarItem: item)
            
            return item
        }
        tabBar.items = barItems
        
        // Apply color configuration
        applyColorConfiguration()

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
        // Ensure colors are applied after selection change
        applyColorConfiguration()
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
        
        /// Loads an image for a tab item with fallback logic
        /// - Parameters:
        ///   - model: The tab item model
        ///   - tabBarItem: The UITabBarItem to update
        
    }
    
  func loadImageForItem(_ model: TabsBarItem, tabBarItem: UITabBarItem) {
      // Priority 1: imageIcon (enhanced image support)
      if let imageIcon = model.imageIcon {
          loadImageIcon(imageIcon) { [weak self] image in
              DispatchQueue.main.async {
                  if let image = image {
                      // Use original rendering mode to preserve image content
                      tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
                      // Store reference to original image for ring rendering
                      tabBarItem.selectedImage = self?.createSelectedImageWithRing(image, imageIcon: imageIcon)
                  } else {
                      // Fallback to systemIcon if imageIcon fails
                      self?.loadFallbackImage(for: model, tabBarItem: tabBarItem)
                  }
              }
          }
          return
      }
      
      // Priority 2: systemIcon (SF Symbols)
      if let systemIconName = model.systemIcon {
          let image = UIImage(systemName: systemIconName) ?? UIImage()
          tabBarItem.image = image
          return
      }
      
      // Priority 3: image (bundled asset)
      if let assetName = model.image {
          tabBarItem.image = UIImage(named: assetName)
          return
      }
      
      // Priority 4: placeholder (empty image)
      tabBarItem.image = UIImage()
  }
  
  /// Loads fallback image when imageIcon fails
  /// - Parameters:
  ///   - model: The tab item model
  ///   - tabBarItem: The UITabBarItem to update
  func loadFallbackImage(for model: TabsBarItem, tabBarItem: UITabBarItem) {
      if let systemIconName = model.systemIcon {
          tabBarItem.image = UIImage(systemName: systemIconName) ?? UIImage()
      } else if let assetName = model.image {
          tabBarItem.image = UIImage(named: assetName)
      } else {
          tabBarItem.image = UIImage()
      }
  }
  
  /// Loads an image icon using the ImageUtils
  /// - Parameters:
  ///   - imageIcon: The image icon configuration
  ///   - completion: Completion handler with the loaded image
  func loadImageIcon(_ imageIcon: ImageIcon, completion: @escaping (UIImage?) -> Void) {
      // Convert to JSImageIcon format for ImageUtils
      let jsImageIcon = JSImageIcon(shape: imageIcon.shape, size: imageIcon.size, image: imageIcon.image, ring: imageIcon.ring)
      ImageUtils.processImageIcon(jsImageIcon, completion: completion)
  }
  
    /// Helper struct to bridge between ImageIcon and JSImageIcon
    private struct JSImageIcon {
        let shape: String
        let size: String
        let image: String
        let ring: ImageIconRing?
    }
    
    /// Creates a selected image with ring if configured
    /// - Parameters:
    ///   - image: The base image
    ///   - imageIcon: The image icon configuration
    /// - Returns: Image with ring for selected state, or original image
    private func createSelectedImageWithRing(_ image: UIImage, imageIcon: ImageIcon) -> UIImage {
        guard let ring = imageIcon.ring, ring.enabled else {
            return image.withRenderingMode(.alwaysOriginal)
        }
        
        let ringWidth = CGFloat(ring.width ?? 2.0)
        let selectedColor = selectedIconColor ?? UIColor.systemBlue
        
        return ImageUtils.addRingToImage(image, ringWidth: ringWidth, ringColor: selectedColor)
    }
    
    /// Image utilities for loading and processing images
    private class ImageUtils {
        
        /// Supported image formats
        private static let supportedFormats: Set<String> = ["png", "jpg", "jpeg", "svg", "webp"]
        
        /// Maximum file size (5MB)
        private static let maxFileSize: Int = 5 * 1024 * 1024
        
        /// Image cache with URL as key
        private static var imageCache: [String: UIImage] = [:]
        
        /// Loading states for remote images
        private static var loadingStates: [String: Bool] = [:]
        
        /// Validates if a string is a valid base64 data URI
        /// - Parameter dataUri: The data URI string to validate
        /// - Returns: True if valid base64 data URI, false otherwise
        static func isValidBase64DataUri(_ dataUri: String) -> Bool {
            let pattern = #"^data:image/(png|jpeg|jpg|svg\+xml|webp);base64,"#
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: dataUri.utf16.count)
            return regex?.firstMatch(in: dataUri, options: [], range: range) != nil
        }
        
        /// Validates if a string is a valid HTTP/HTTPS URL
        /// - Parameter urlString: The URL string to validate
        /// - Returns: True if valid HTTP/HTTPS URL, false otherwise
        static func isValidHttpUrl(_ urlString: String) -> Bool {
            guard let url = URL(string: urlString) else { return false }
            return url.scheme == "http" || url.scheme == "https"
        }
        
        /// Loads an image from base64 data URI
        /// - Parameter dataUri: The base64 data URI
        /// - Returns: UIImage if successful, nil otherwise
        static func loadImageFromBase64(_ dataUri: String) -> UIImage? {
            guard let commaIndex = dataUri.firstIndex(of: ",") else { return nil }
            let base64String = String(dataUri[dataUri.index(after: commaIndex)...])
            guard let data = Data(base64Encoded: base64String) else { return nil }
            return UIImage(data: data)
        }
        
        /// Loads an image from a remote URL with caching
        /// - Parameters:
        ///   - urlString: The URL string
        ///   - completion: Completion handler with result
        static func loadImageFromUrl(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
            // Check cache first
            if let cachedImage = imageCache[urlString] {
                completion(cachedImage)
                return
            }
            
            // Check if already loading
            if loadingStates[urlString] == true {
                // Wait a bit and try again (simple debouncing)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    loadImageFromUrl(urlString, completion: completion)
                }
                return
            }
            
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            loadingStates[urlString] = true
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                defer {
                    loadingStates[urlString] = false
                }
                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      error == nil else {
                    print("TabsBar: Failed to load image from \(urlString): \(error?.localizedDescription ?? "Unknown error")")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // Validate content type
                if let contentType = httpResponse.mimeType {
                    let validTypes = ["image/png", "image/jpeg", "image/jpg", "image/svg+xml", "image/webp"]
                    if !validTypes.contains(contentType.lowercased()) {
                        print("TabsBar: Unsupported image format: \(contentType)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                }
                
                // Validate file size
                if data.count > maxFileSize {
                    print("TabsBar: Image file too large: \(data.count) bytes")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("TabsBar: Failed to create image from data")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                // Cache the image
                imageCache[urlString] = image
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            task.resume()
        }
        
        /// Processes an image icon configuration and returns a UIImage
        /// - Parameters:
        ///   - imageIcon: The image icon configuration
        ///   - completion: Completion handler with the processed image
        static func processImageIcon(_ imageIcon: JSImageIcon, completion: @escaping (UIImage?) -> Void) {
            let imageSource = imageIcon.image
            
            // Handle base64 data URI
            if isValidBase64DataUri(imageSource) {
                let image = loadImageFromBase64(imageSource)
                let processedImage = applyImageIconStyling(image, shape: imageIcon.shape, size: imageIcon.size)
                completion(processedImage)
                return
            }
            
            // Handle remote URL
            if isValidHttpUrl(imageSource) {
                loadImageFromUrl(imageSource) { image in
                    let processedImage = applyImageIconStyling(image, shape: imageIcon.shape, size: imageIcon.size)
                    completion(processedImage)
                }
                return
            }
            
            print("TabsBar: Invalid image source: \(imageSource)")
            completion(nil)
        }
        
        /// Applies styling to an image based on shape and size parameters
        /// - Parameters:
        ///   - image: The source image
        ///   - shape: The shape ("circle" or "square")
        ///   - size: The size behavior ("cover", "stretch", or "fit")
        /// - Returns: Styled UIImage or nil
        private static func applyImageIconStyling(_ image: UIImage?, shape: String, size: String) -> UIImage? {
            guard let image = image else { return nil }
            
            let targetSize = CGSize(width: 24, height: 24) // Smaller icon size with padding
            
            // Apply size behavior
            let resizedImage: UIImage
            switch size.lowercased() {
            case "cover":
                resizedImage = resizeImageAspectFill(image, targetSize: targetSize)
            case "stretch":
                resizedImage = resizeImageToFill(image, targetSize: targetSize)
            case "fit":
                resizedImage = resizeImageAspectFit(image, targetSize: targetSize)
            default:
                resizedImage = resizeImageAspectFit(image, targetSize: targetSize)
            }
            
            // Apply shape
            switch shape.lowercased() {
            case "circle":
                return makeCircularImage(resizedImage)
            case "square":
                return resizedImage
            default:
                return resizedImage
            }
        }
        
        /// Resizes image to fill target size (aspect fill)
        private static func resizeImageAspectFill(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            let ratio = max(widthRatio, heightRatio)
            
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            let rect = CGRect(x: (targetSize.width - newSize.width) / 2,
                             y: (targetSize.height - newSize.height) / 2,
                             width: newSize.width,
                             height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        }
        
        /// Resizes image to fill target size exactly (stretch)
        private static func resizeImageToFill(_ image: UIImage, targetSize: CGSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
            image.draw(in: CGRect(origin: .zero, size: targetSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        }
        
        /// Resizes image to fit within target size (aspect fit) with padding
        private static func resizeImageAspectFit(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            let padding: CGFloat = 4.0 // Add padding around the image
            let availableSize = CGSize(width: targetSize.width - padding * 2, height: targetSize.height - padding * 2)
            
            let widthRatio = availableSize.width / size.width
            let heightRatio = availableSize.height / size.height
            let ratio = min(widthRatio, heightRatio)
            
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            let rect = CGRect(x: (targetSize.width - newSize.width) / 2,
                             y: (targetSize.height - newSize.height) / 2,
                             width: newSize.width,
                             height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        }
        
        /// Creates a circular version of the image
        private static func makeCircularImage(_ image: UIImage) -> UIImage {
            let size = image.size
            let rect = CGRect(origin: .zero, size: size)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            let context = UIGraphicsGetCurrentContext()
            
            context?.addEllipse(in: rect)
            context?.clip()
            
            image.draw(in: rect)
            
            let circularImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return circularImage ?? image
        }
        
        /// Clears the image cache
        static func clearCache() {
            imageCache.removeAll()
            loadingStates.removeAll()
        }
        
        /// Adds a ring around an image
        /// - Parameters:
        ///   - image: The source image
        ///   - ringWidth: Width of the ring
        ///   - ringColor: Color of the ring
        /// - Returns: Image with ring added
        static func addRingToImage(_ image: UIImage, ringWidth: CGFloat, ringColor: UIColor) -> UIImage {
            let size = image.size
            let newSize = CGSize(width: size.width + ringWidth * 2, height: size.height + ringWidth * 2)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            let context = UIGraphicsGetCurrentContext()
            
            // Draw the ring
            context?.setStrokeColor(ringColor.cgColor)
            context?.setLineWidth(ringWidth)
            let ringRect = CGRect(x: ringWidth/2, y: ringWidth/2,
                                width: size.width + ringWidth, height: size.height + ringWidth)
            
            if image.size.width == image.size.height {
                // Circular ring for square images
                context?.strokeEllipse(in: ringRect)
            } else {
                // Rounded rectangle ring for non-square images
                let cornerRadius = min(size.width, size.height) * 0.1
                context?.addPath(UIBezierPath(roundedRect: ringRect, cornerRadius: cornerRadius).cgPath)
                context?.strokePath()
            }
            
            // Draw the original image in the center
            let imageRect = CGRect(x: ringWidth, y: ringWidth, width: size.width, height: size.height)
            image.draw(in: imageRect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage?.withRenderingMode(.alwaysOriginal) ?? image
        }
    }
    
    /// Applies the configured colors to the tab bar
    private func applyColorConfiguration() {
        // Apply tint colors if configured
        if let selectedColor = selectedIconColor {
            tabBar.tintColor = selectedColor
        }
        
        if let unselectedColor = unselectedIconColor {
            tabBar.unselectedItemTintColor = unselectedColor
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
        // Ensure colors are applied after selection
        applyColorConfiguration()
        onSelected?(items[idx].id)
    }
}
