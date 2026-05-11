# WindowFlow

A lightweight macOS menu bar app that automatically resizes and positions your windows across 1–3 displays.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## Features

- **Menu bar app** — lives unobtrusively in your menu bar
- **Display-aware** — detects 1, 2, or 3 connected monitors and adapts automatically
- **Built-in layouts** — Focus, Halves, Thirds, Coding, Quadrants, Stacked, and more
- **Multi-monitor layouts** — Dual Coding, Presentation, Triple Spread, Triple Coding
- **Custom layouts** — create your own with a visual editor
- **App-specific rules** — always place Slack on display 3, Chrome on the right half, etc.
- **Global hotkeys** — trigger any action with keyboard shortcuts
- **Quick actions** — snap the current window to halves, maximize, center, or move between displays
- **Persistent settings** — your layouts, rules, and preferences are saved automatically

## Default Keyboard Shortcuts

| Action | Shortcut |
|---|---|
| Left Half | `⌃⌥←` |
| Right Half | `⌃⌥→` |
| Top Half | `⌃⌥↑` |
| Bottom Half | `⌃⌥↓` |
| Maximize | `⌃⌥↩` |
| Center | `⌃⌥C` |
| Move to Display 1 | `⌃⌥1` |
| Move to Display 2 | `⌃⌥2` |
| Move to Display 3 | `⌃⌥3` |

## Built-in Layouts

### Universal (any number of displays)
- **Focus** — single centered window (80% width, 90% height)
- **Halves** — two equal columns
- **Thirds** — three equal columns
- **Coding** — 60/40 split (editor + terminal)
- **Quadrants** — four equal quarters
- **Main + Sidebar** — 70/30 split
- **Stacked** — two equal rows

### Dual Monitor
- **Dual Full** — maximize one window per display
- **Dual Coding** — editor full on display 1, browser + terminal split on display 2
- **Presentation** — slides on display 2, notes on display 1

### Triple Monitor
- **Triple Spread** — one window per display
- **Triple Coding** — reference on display 1, editor on display 2, browser + terminal on display 3

## Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

### Build & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/TheMusicMaestro/WindowFlow.git
   cd WindowFlow
   ```

2. **Open in Xcode:**
   ```bash
   open Package.swift
   ```
   This opens the Swift package directly in Xcode.

3. **Build and run** (`⌘R`) — the app will appear in your menu bar.

4. **Grant Accessibility access** when prompted (System Settings → Privacy & Security → Accessibility). The app needs this to move and resize windows.

### First Launch

On first launch, WindowFlow will:
1. Request accessibility permissions (required to manage windows)
2. Detect your connected displays
3. Register default keyboard shortcuts
4. Appear as a window icon in your menu bar

Click the menu bar icon to see quick actions, available layouts, and connected display info.

## Creating Custom Layouts

1. Open Preferences (click the menu bar icon → Preferences)
2. Go to the **Layouts** tab
3. Click **Add Layout**
4. Name your layout and add zones:
   - Each zone has a position (X, Y) and size (Width, Height) as fractions of the display (0.0–1.0)
   - Assign each zone to a display index (0 = primary, 1 = secondary, etc.)
5. Save and apply from the menu bar

## Window Rules

Rules let you automatically place specific apps:

1. Open Preferences → **Rules** tab
2. Click **Add Rule**
3. Enter the app's bundle ID (e.g., `com.tinyspeck.slackmacgap` for Slack)
4. Choose which display and position
5. Rules are applied whenever you trigger a layout

### Finding Bundle IDs

Run this in Terminal to find an app's bundle ID:
```bash
osascript -e 'id of app "Slack"'
```

## Architecture

```
Sources/WindowFlow/
├── WindowFlowApp.swift          # App entry point, menu bar setup
├── Core/
│   ├── WindowManager.swift      # AXUIElement-based window control
│   ├── DisplayManager.swift     # CGDisplay detection & monitoring
│   ├── LayoutEngine.swift       # Applies layouts to windows
│   └── HotkeyManager.swift      # Carbon global hotkeys
├── Models/
│   ├── Layout.swift             # Layout, LayoutZone, WindowRule
│   └── DisplayConfig.swift      # Display configuration models
├── Presets/
│   └── PresetLayouts.swift      # Built-in layout definitions
├── Views/
│   ├── MenuBarView.swift        # Menu bar dropdown UI
│   ├── PreferencesView.swift    # Settings tabs
│   └── LayoutEditorView.swift   # Visual layout editor
└── Storage/
    └── SettingsStore.swift       # UserDefaults persistence
```

## Technologies

- **Swift 5.9** with **SwiftUI** for the UI
- **Accessibility API** (`AXUIElement`) for window manipulation
- **Core Graphics** (`CGDisplay`) for display detection
- **Carbon Events** for global keyboard shortcuts
- **Swift Package Manager** for project structure

## License

MIT
