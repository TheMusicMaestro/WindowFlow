import SwiftUI
import AppKit

@main
struct WindowFlowApp: App {
    @StateObject private var displayManager = DisplayManager()
    @StateObject private var settingsStore = SettingsStore.shared
    @State private var showingPreferences = false

    private let windowManager = WindowManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                settingsStore: settingsStore,
                displayManager: displayManager,
                layoutEngine: LayoutEngine(
                    windowManager: windowManager,
                    displayManager: displayManager
                )
            )
        } label: {
            Image(systemName: "macwindow.on.rectangle")
        }

        Window("Preferences", id: "preferences") {
            PreferencesView(settingsStore: settingsStore)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 520, height: 420)
    }

    init() {
        checkAccessibility()
        registerDefaultHotkeys()
    }

    private func checkAccessibility() {
        if !WindowManager.hasAccessibilityPermission {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                WindowManager.requestAccessibilityPermission()
            }
        }
    }

    private func registerDefaultHotkeys() {
        let displayMgr = DisplayManager()
        let winMgr = WindowManager()
        let engine = LayoutEngine(windowManager: winMgr, displayManager: displayMgr)
        let hotkeys = HotkeyManager.shared
        let mods = HotkeyModifier.control | HotkeyModifier.option

        // Quick actions: Ctrl+Option+Arrow
        hotkeys.register(keyCode: KeyCode.leftArrow, modifiers: mods) {
            engine.moveFrontmostToLeftHalf()
        }
        hotkeys.register(keyCode: KeyCode.rightArrow, modifiers: mods) {
            engine.moveFrontmostToRightHalf()
        }
        hotkeys.register(keyCode: KeyCode.upArrow, modifiers: mods) {
            engine.moveFrontmostToTopHalf()
        }
        hotkeys.register(keyCode: KeyCode.downArrow, modifiers: mods) {
            engine.moveFrontmostToBottomHalf()
        }

        // Maximize: Ctrl+Option+Return
        hotkeys.register(keyCode: KeyCode.returnKey, modifiers: mods) {
            engine.maximizeFrontmost()
        }

        // Center: Ctrl+Option+C
        hotkeys.register(keyCode: KeyCode.c, modifiers: mods) {
            engine.centerFrontmost()
        }

        // Move to displays: Ctrl+Option+1/2/3
        hotkeys.register(keyCode: KeyCode.one, modifiers: mods) {
            engine.moveFrontmostToDisplay(0)
        }
        hotkeys.register(keyCode: KeyCode.two, modifiers: mods) {
            engine.moveFrontmostToDisplay(1)
        }
        hotkeys.register(keyCode: KeyCode.three, modifiers: mods) {
            engine.moveFrontmostToDisplay(2)
        }

        // Register hotkeys for custom layouts that have them
        for layout in SettingsStore.shared.allLayouts {
            if let keyCode = layout.hotkeyKeyCode, let modifiers = layout.hotkeyModifiers {
                hotkeys.register(keyCode: keyCode, modifiers: modifiers) {
                    engine.applyLayout(layout, rules: SettingsStore.shared.windowRules)
                }
            }
        }
    }
}
