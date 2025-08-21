import UIKit

/// Utility class for image loading, validation, and caching
class ImageUtils {
    
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
    static func applyImageIconStyling(_ image: UIImage?, shape: String, size: String) -> UIImage? {
        guard let image = image else { return nil }
        
        let targetSize = CGSize(width: 20, height: 20) // Smaller icon size with padding
        
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
    
    /// Adds an enhanced ring around an image with transparent spacer and padding
    /// - Parameters:
    ///   - image: The source image
    ///   - ringWidth: Width of the colored ring
    ///   - ringColor: Color of the ring
    /// - Returns: Image with enhanced ring added
    static func addEnhancedRingToImage(_ image: UIImage, ringWidth: CGFloat, ringColor: UIColor) -> UIImage {
        let size = image.size
        let spacerWidth = ringWidth // Transparent spacer same width as ring
        let bottomPadding: CGFloat = 2.0 // Additional padding beneath the ring
        
        // Calculate total size: image + spacer + ring + bottom padding
        let totalRingSpace = spacerWidth + ringWidth
        let newSize = CGSize(
            width: size.width + totalRingSpace * 2,
            height: size.height + totalRingSpace * 2 + bottomPadding
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the original image in the center (accounting for spacer and ring)
        let imageRect = CGRect(
            x: totalRingSpace,
            y: totalRingSpace,
            width: size.width,
            height: size.height
        )
        image.draw(in: imageRect)
        
        // Draw the transparent spacer ring (invisible, just for spacing)
        // This creates the gap between image and colored ring
        
        // Draw the colored ring
        context?.setStrokeColor(ringColor.cgColor)
        context?.setLineWidth(ringWidth)
        
        let ringRect = CGRect(
            x: ringWidth/2,
            y: ringWidth/2,
            width: newSize.width - ringWidth,
            height: newSize.height - ringWidth - bottomPadding
        )
        
        if image.size.width == image.size.height {
            // Circular ring for square images
            context?.strokeEllipse(in: ringRect)
        } else {
            // Rounded rectangle ring for non-square images
            let cornerRadius = min(size.width, size.height) * 0.1
            context?.addPath(UIBezierPath(roundedRect: ringRect, cornerRadius: cornerRadius).cgPath)
            context?.strokePath()
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.withRenderingMode(.alwaysOriginal) ?? image
    }
    
    /// Legacy function for backward compatibility
    /// - Parameters:
    ///   - image: The source image
    ///   - ringWidth: Width of the ring
    ///   - ringColor: Color of the ring
    /// - Returns: Image with ring added
    static func addRingToImage(_ image: UIImage, ringWidth: CGFloat, ringColor: UIColor) -> UIImage {
        return addEnhancedRingToImage(image, ringWidth: ringWidth, ringColor: ringColor)
    }
}