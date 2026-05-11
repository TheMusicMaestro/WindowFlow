import Foundation

enum PresetLayouts {

    // MARK: - Single Monitor Layouts

    static let focus = Layout(
        name: "Focus",
        icon: "rectangle.center.inset.filled",
        zones: [
            LayoutZone(name: "Center", displayIndex: 0, x: 0.1, y: 0.05, width: 0.8, height: 0.9)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let halves = Layout(
        name: "Halves",
        icon: "rectangle.split.2x1",
        zones: [
            LayoutZone(name: "Left", displayIndex: 0, x: 0, y: 0, width: 0.5, height: 1),
            LayoutZone(name: "Right", displayIndex: 0, x: 0.5, y: 0, width: 0.5, height: 1)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let thirds = Layout(
        name: "Thirds",
        icon: "rectangle.split.3x1",
        zones: [
            LayoutZone(name: "Left", displayIndex: 0, x: 0, y: 0, width: 0.333, height: 1),
            LayoutZone(name: "Center", displayIndex: 0, x: 0.333, y: 0, width: 0.334, height: 1),
            LayoutZone(name: "Right", displayIndex: 0, x: 0.667, y: 0, width: 0.333, height: 1)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let coding = Layout(
        name: "Coding",
        icon: "chevron.left.forwardslash.chevron.right",
        zones: [
            LayoutZone(name: "Editor", displayIndex: 0, x: 0, y: 0, width: 0.6, height: 1),
            LayoutZone(name: "Terminal / Browser", displayIndex: 0, x: 0.6, y: 0, width: 0.4, height: 1)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let quadrants = Layout(
        name: "Quadrants",
        icon: "square.grid.2x2",
        zones: [
            LayoutZone(name: "Top Left", displayIndex: 0, x: 0, y: 0, width: 0.5, height: 0.5),
            LayoutZone(name: "Top Right", displayIndex: 0, x: 0.5, y: 0, width: 0.5, height: 0.5),
            LayoutZone(name: "Bottom Left", displayIndex: 0, x: 0, y: 0.5, width: 0.5, height: 0.5),
            LayoutZone(name: "Bottom Right", displayIndex: 0, x: 0.5, y: 0.5, width: 0.5, height: 0.5)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let mainWithSidebar = Layout(
        name: "Main + Sidebar",
        icon: "sidebar.right",
        zones: [
            LayoutZone(name: "Main", displayIndex: 0, x: 0, y: 0, width: 0.7, height: 1),
            LayoutZone(name: "Sidebar", displayIndex: 0, x: 0.7, y: 0, width: 0.3, height: 1)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    static let stacked = Layout(
        name: "Stacked",
        icon: "rectangle.split.1x2",
        zones: [
            LayoutZone(name: "Top", displayIndex: 0, x: 0, y: 0, width: 1, height: 0.5),
            LayoutZone(name: "Bottom", displayIndex: 0, x: 0, y: 0.5, width: 1, height: 0.5)
        ],
        displayCount: 0,
        isBuiltIn: true
    )

    // MARK: - Dual Monitor Layouts

    static let dualFullscreen = Layout(
        name: "Dual Full",
        icon: "rectangle.on.rectangle",
        zones: [
            LayoutZone(name: "Primary Full", displayIndex: 0, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Secondary Full", displayIndex: 1, x: 0, y: 0, width: 1, height: 1)
        ],
        displayCount: 2,
        isBuiltIn: true
    )

    static let dualCoding = Layout(
        name: "Dual Coding",
        icon: "rectangle.on.rectangle",
        zones: [
            LayoutZone(name: "Editor", displayIndex: 0, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Browser", displayIndex: 1, x: 0, y: 0, width: 0.5, height: 1),
            LayoutZone(name: "Terminal", displayIndex: 1, x: 0.5, y: 0, width: 0.5, height: 1)
        ],
        displayCount: 2,
        isBuiltIn: true
    )

    static let dualPresentation = Layout(
        name: "Presentation",
        icon: "play.rectangle",
        zones: [
            LayoutZone(name: "Slides", displayIndex: 1, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Notes", displayIndex: 0, x: 0, y: 0, width: 1, height: 1)
        ],
        displayCount: 2,
        isBuiltIn: true
    )

    // MARK: - Triple Monitor Layouts

    static let tripleSpread = Layout(
        name: "Triple Spread",
        icon: "rectangle.3.group",
        zones: [
            LayoutZone(name: "Left Full", displayIndex: 0, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Center Full", displayIndex: 1, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Right Full", displayIndex: 2, x: 0, y: 0, width: 1, height: 1)
        ],
        displayCount: 3,
        isBuiltIn: true
    )

    static let tripleCoding = Layout(
        name: "Triple Coding",
        icon: "rectangle.3.group",
        zones: [
            LayoutZone(name: "Reference", displayIndex: 0, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Editor", displayIndex: 1, x: 0, y: 0, width: 1, height: 1),
            LayoutZone(name: "Browser", displayIndex: 2, x: 0, y: 0, width: 0.5, height: 1),
            LayoutZone(name: "Terminal", displayIndex: 2, x: 0.5, y: 0, width: 0.5, height: 1)
        ],
        displayCount: 3,
        isBuiltIn: true
    )

    // MARK: - All Presets

    static let allPresets: [Layout] = [
        // Universal
        focus, halves, thirds, coding, quadrants, mainWithSidebar, stacked,
        // Dual
        dualFullscreen, dualCoding, dualPresentation,
        // Triple
        tripleSpread, tripleCoding
    ]

    /// Returns presets appropriate for the given display count.
    static func presets(forDisplayCount count: Int) -> [Layout] {
        allPresets.filter { $0.displayCount == 0 || $0.displayCount <= count }
    }
}
