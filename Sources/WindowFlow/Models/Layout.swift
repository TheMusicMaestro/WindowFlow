import Foundation
import CoreGraphics

/// A zone within a layout, defined as fractional positions relative to a display.
struct LayoutZone: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var displayIndex: Int
    /// Fractional position and size (0.0 - 1.0) relative to the display's usable area.
    var x: Double
    var y: Double
    var width: Double
    var height: Double
    /// Optional: only match windows from these app bundle IDs.
    var appBundleIDs: [String]

    init(
        id: UUID = UUID(),
        name: String = "",
        displayIndex: Int = 0,
        x: Double = 0,
        y: Double = 0,
        width: Double = 1,
        height: Double = 1,
        appBundleIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.displayIndex = displayIndex
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.appBundleIDs = appBundleIDs
    }

    func absoluteFrame(in displayFrame: CGRect) -> CGRect {
        CGRect(
            x: displayFrame.origin.x + displayFrame.width * x,
            y: displayFrame.origin.y + displayFrame.height * y,
            width: displayFrame.width * width,
            height: displayFrame.height * height
        )
    }
}

struct Layout: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var zones: [LayoutZone]
    /// Number of displays this layout is designed for (0 = any).
    var displayCount: Int
    var isBuiltIn: Bool
    /// Keyboard shortcut (stored as key + modifiers).
    var hotkeyKeyCode: UInt32?
    var hotkeyModifiers: UInt32?

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "rectangle.split.2x1",
        zones: [LayoutZone] = [],
        displayCount: Int = 0,
        isBuiltIn: Bool = false,
        hotkeyKeyCode: UInt32? = nil,
        hotkeyModifiers: UInt32? = nil
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.zones = zones
        self.displayCount = displayCount
        self.isBuiltIn = isBuiltIn
        self.hotkeyKeyCode = hotkeyKeyCode
        self.hotkeyModifiers = hotkeyModifiers
    }
}

struct WindowRule: Identifiable, Codable, Hashable {
    let id: UUID
    var appBundleID: String
    var appName: String
    var displayIndex: Int
    var zone: LayoutZone
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        appBundleID: String,
        appName: String = "",
        displayIndex: Int = 0,
        zone: LayoutZone = LayoutZone(),
        isEnabled: Bool = true
    ) {
        self.id = id
        self.appBundleID = appBundleID
        self.appName = appName
        self.displayIndex = displayIndex
        self.zone = zone
        self.isEnabled = isEnabled
    }
}
