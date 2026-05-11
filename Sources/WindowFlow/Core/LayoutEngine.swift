import Foundation
import CoreGraphics

final class LayoutEngine {
    private let windowManager: WindowManager
    private let displayManager: DisplayManager

    init(windowManager: WindowManager, displayManager: DisplayManager) {
        self.windowManager = windowManager
        self.displayManager = displayManager
    }

    /// Apply a layout to all current windows.
    func applyLayout(_ layout: Layout, rules: [WindowRule] = []) {
        displayManager.refresh()
        let config = displayManager.currentConfig
        let windows = windowManager.listWindows()

        guard !windows.isEmpty, !config.displays.isEmpty else { return }

        // First, apply any matching rules
        var handledWindows = Set<pid_t>()
        let enabledRules = rules.filter { $0.isEnabled }

        for window in windows {
            if let rule = enabledRules.first(where: { $0.appBundleID == window.bundleID }) {
                let displayIdx = min(rule.displayIndex, config.count - 1)
                if let display = config.display(at: displayIdx) {
                    let usableFrame = displayManager.usableFrame(for: display)
                    let targetFrame = rule.zone.absoluteFrame(in: usableFrame)
                    windowManager.moveAndResize(window: window, to: targetFrame)
                    handledWindows.insert(window.ownerPID)
                }
            }
        }

        // Then, assign remaining windows to zones
        let unhandledWindows = windows.filter { !handledWindows.contains($0.ownerPID) }
        let zones = layout.zones.filter { $0.appBundleIDs.isEmpty }

        guard !zones.isEmpty else { return }

        for (index, window) in unhandledWindows.enumerated() {
            let zone = zones[index % zones.count]
            let displayIdx = min(zone.displayIndex, config.count - 1)

            if let display = config.display(at: displayIdx) {
                let usableFrame = displayManager.usableFrame(for: display)
                let targetFrame = zone.absoluteFrame(in: usableFrame)
                windowManager.moveAndResize(window: window, to: targetFrame)
            }
        }
    }

    /// Apply a specific zone to the frontmost window.
    func applyZoneToFrontmost(_ zone: LayoutZone) {
        displayManager.refresh()
        let config = displayManager.currentConfig

        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return }
        let pid = frontmostApp.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)

        var focusedRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedWindowAttribute as CFString,
            &focusedRef
        )
        guard result == .success else { return }
        let focusedWindow = focusedRef as! AXUIElement

        let displayIdx = min(zone.displayIndex, config.count - 1)
        if let display = config.display(at: displayIdx) {
            let usableFrame = displayManager.usableFrame(for: display)
            let targetFrame = zone.absoluteFrame(in: usableFrame)
            windowManager.moveAndResize(axElement: focusedWindow, to: targetFrame)
        }
    }

    /// Quick actions for the frontmost window.
    func moveFrontmostToLeftHalf() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0, y: 0, width: 0.5, height: 1))
    }

    func moveFrontmostToRightHalf() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0.5, y: 0, width: 0.5, height: 1))
    }

    func moveFrontmostToTopHalf() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0, y: 0, width: 1, height: 0.5))
    }

    func moveFrontmostToBottomHalf() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0, y: 0.5, width: 1, height: 0.5))
    }

    func maximizeFrontmost() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0, y: 0, width: 1, height: 1))
    }

    func centerFrontmost() {
        applyZoneToFrontmost(LayoutZone(displayIndex: 0, x: 0.15, y: 0.1, width: 0.7, height: 0.8))
    }

    func moveFrontmostToDisplay(_ displayIndex: Int) {
        applyZoneToFrontmost(LayoutZone(displayIndex: displayIndex, x: 0, y: 0, width: 1, height: 1))
    }
}
