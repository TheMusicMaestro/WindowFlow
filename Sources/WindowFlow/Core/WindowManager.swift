import Foundation
import CoreGraphics
import ApplicationServices

struct ManagedWindow {
    let axElement: AXUIElement
    let ownerPID: pid_t
    let ownerName: String
    let bundleID: String
    let title: String
    var position: CGPoint
    var size: CGSize
}

final class WindowManager {

    // MARK: - Accessibility Permission

    static var hasAccessibilityPermission: Bool {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt: false] as CFDictionary
        )
    }

    static func requestAccessibilityPermission() {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt: true] as CFDictionary
        )
    }

    // MARK: - List Windows

    func listWindows() -> [ManagedWindow] {
        var windows: [ManagedWindow] = []
        let runningApps = NSWorkspace.shared.runningApplications

        for app in runningApps {
            guard app.activationPolicy == .regular else { continue }

            let pid = app.processIdentifier
            let appElement = AXUIElementCreateApplication(pid)

            var windowsRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(
                appElement,
                kAXWindowsAttribute as CFString,
                &windowsRef
            )
            guard result == .success,
                  let axWindows = windowsRef as? [AXUIElement] else { continue }

            for axWindow in axWindows {
                guard let title = axWindow.stringAttribute(kAXTitleAttribute),
                      !title.isEmpty else { continue }

                // Skip minimized windows
                if let minimized = axWindow.boolAttribute(kAXMinimizedAttribute), minimized {
                    continue
                }

                let position = axWindow.positionAttribute() ?? .zero
                let size = axWindow.sizeAttribute() ?? .zero

                let window = ManagedWindow(
                    axElement: axWindow,
                    ownerPID: pid,
                    ownerName: app.localizedName ?? "Unknown",
                    bundleID: app.bundleIdentifier ?? "",
                    title: title,
                    position: position,
                    size: size
                )
                windows.append(window)
            }
        }
        return windows
    }

    // MARK: - Move & Resize

    func moveAndResize(window: ManagedWindow, to frame: CGRect) {
        let position = frame.origin
        let size = frame.size

        var pos = position
        var sz = CGSize(width: size.width, height: size.height)

        if let posValue = AXValueCreate(.cgPoint, &pos) {
            AXUIElementSetAttributeValue(
                window.axElement,
                kAXPositionAttribute as CFString,
                posValue
            )
        }

        if let sizeValue = AXValueCreate(.cgSize, &sz) {
            AXUIElementSetAttributeValue(
                window.axElement,
                kAXSizeAttribute as CFString,
                sizeValue
            )
        }
    }

    func moveAndResize(axElement: AXUIElement, to frame: CGRect) {
        var pos = frame.origin
        var sz = frame.size

        if let posValue = AXValueCreate(.cgPoint, &pos) {
            AXUIElementSetAttributeValue(
                axElement,
                kAXPositionAttribute as CFString,
                posValue
            )
        }

        if let sizeValue = AXValueCreate(.cgSize, &sz) {
            AXUIElementSetAttributeValue(
                axElement,
                kAXSizeAttribute as CFString,
                sizeValue
            )
        }
    }
}

// MARK: - AXUIElement Extensions

private extension AXUIElement {
    func stringAttribute(_ attribute: String) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        guard result == .success else { return nil }
        return value as? String
    }

    func boolAttribute(_ attribute: String) -> Bool? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        guard result == .success else { return nil }
        return (value as? NSNumber)?.boolValue
    }

    func positionAttribute() -> CGPoint? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            self, kAXPositionAttribute as CFString, &value
        )
        guard result == .success, let axValue = value else { return nil }
        var point = CGPoint.zero
        AXValueGetValue(axValue as! AXValue, .cgPoint, &point)
        return point
    }

    func sizeAttribute() -> CGSize? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            self, kAXSizeAttribute as CFString, &value
        )
        guard result == .success, let axValue = value else { return nil }
        var size = CGSize.zero
        AXValueGetValue(axValue as! AXValue, .cgSize, &size)
        return size
    }
}
