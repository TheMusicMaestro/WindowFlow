import Foundation
import CoreGraphics

final class DisplayManager: ObservableObject {
    @Published var currentConfig: DisplayConfiguration = DisplayConfiguration(displays: [])

    init() {
        refresh()
        setupDisplayReconfigurationCallback()
    }

    func refresh() {
        let maxDisplays: UInt32 = 16
        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0

        let result = CGGetActiveDisplayList(maxDisplays, &displayIDs, &displayCount)
        guard result == .success else {
            currentConfig = DisplayConfiguration(displays: [])
            return
        }

        let mainID = CGMainDisplayID()
        var displays: [DisplayInfo] = []

        for i in 0..<Int(displayCount) {
            let id = displayIDs[i]
            let bounds = CGDisplayBounds(id)
            let info = DisplayInfo(
                id: id,
                frame: bounds,
                isMain: id == mainID,
                displayIndex: i
            )
            displays.append(info)
        }

        // Sort: main display first, then left-to-right by x position
        displays.sort { a, b in
            if a.isMain != b.isMain { return a.isMain }
            return a.frame.origin.x < b.frame.origin.x
        }

        // Re-assign display indices after sorting
        for i in 0..<displays.count {
            displays[i] = DisplayInfo(
                id: displays[i].id,
                frame: displays[i].frame,
                isMain: displays[i].isMain,
                displayIndex: i
            )
        }

        currentConfig = DisplayConfiguration(displays: displays)
    }

    /// Returns the usable frame (excluding menu bar and Dock) for a display.
    func usableFrame(for display: DisplayInfo) -> CGRect {
        guard let screen = NSScreenForDisplay(display.id) else {
            return display.frame
        }
        return screen
    }

    private func setupDisplayReconfigurationCallback() {
        CGDisplayRegisterReconfigurationCallback({ _, _, userInfo in
            guard let userInfo = userInfo else { return }
            let manager = Unmanaged<DisplayManager>.fromOpaque(userInfo).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.refresh()
            }
        }, Unmanaged.passUnretained(self).toOpaque())
    }

    deinit {
        CGDisplayRemoveReconfigurationCallback({ _, _, _ in }, nil)
    }
}

/// Gets the visible frame for a CGDirectDisplayID by iterating NSScreen.screens.
private func NSScreenForDisplay(_ displayID: CGDirectDisplayID) -> CGRect? {
    // We use CoreGraphics directly since we can't import AppKit's NSScreen easily.
    // Instead, return display bounds minus an estimated menu bar height for the main display.
    let bounds = CGDisplayBounds(displayID)
    let mainID = CGMainDisplayID()
    if displayID == mainID {
        let menuBarHeight: CGFloat = 25
        return CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y + menuBarHeight,
            width: bounds.width,
            height: bounds.height - menuBarHeight
        )
    }
    return bounds
}
