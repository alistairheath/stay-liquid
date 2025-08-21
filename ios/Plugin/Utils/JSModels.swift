import Foundation

/// Represents an image icon configuration as received from JavaScript
public struct JSImageIcon: Decodable {
    /// Shape of the icon container ("circle" or "square")
    public let shape: String
    /// Image scaling behavior ("cover", "stretch", or "fit")
    public let size: String
    /// Image source - either base64 data URI or HTTP/HTTPS URL
    public let image: String
    /// Optional ring configuration
    public let ring: JSImageIconRing?
}

/// Represents the ring configuration for an image icon
public struct JSImageIconRing: Decodable {
    public let enabled: Bool
    public let width: Double
}