import SwiftUI

struct MenuBarView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var displayManager: DisplayManager
    let layoutEngine: LayoutEngine
    @State private var showingPreferences = false

    private var displayCount: Int { displayManager.currentConfig.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            Divider()
            quickActionsSection
            Divider()
            layoutsSection
            if !settingsStore.windowRules.isEmpty {
                Divider()
                rulesSection
            }
            Divider()
            displayInfoSection
            Divider()
            footerSection
        }
        .frame(width: 260)
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            Image(systemName: "macwindow.on.rectangle")
                .font(.title3)
            Text("WindowFlow")
                .font(.headline)
            Spacer()
            Text("\(displayCount) display\(displayCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Quick Actions")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            HStack(spacing: 4) {
                QuickActionButton(icon: "rectangle.lefthalf.filled", label: "Left") {
                    layoutEngine.moveFrontmostToLeftHalf()
                }
                QuickActionButton(icon: "rectangle.righthalf.filled", label: "Right") {
                    layoutEngine.moveFrontmostToRightHalf()
                }
                QuickActionButton(icon: "rectangle.tophalf.filled", label: "Top") {
                    layoutEngine.moveFrontmostToTopHalf()
                }
                QuickActionButton(icon: "rectangle.bottomhalf.filled", label: "Bottom") {
                    layoutEngine.moveFrontmostToBottomHalf()
                }
                QuickActionButton(icon: "arrow.up.left.and.arrow.down.right", label: "Max") {
                    layoutEngine.maximizeFrontmost()
                }
                QuickActionButton(icon: "rectangle.center.inset.filled", label: "Center") {
                    layoutEngine.centerFrontmost()
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)

            if displayCount > 1 {
                HStack(spacing: 4) {
                    ForEach(0..<displayCount, id: \.self) { index in
                        QuickActionButton(
                            icon: "display",
                            label: "Display \(index + 1)"
                        ) {
                            layoutEngine.moveFrontmostToDisplay(index)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
    }

    private var layoutsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Layouts")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            let layouts = settingsStore.layouts(forDisplayCount: displayCount)
            ForEach(layouts) { layout in
                LayoutMenuItem(layout: layout) {
                    layoutEngine.applyLayout(layout, rules: settingsStore.windowRules)
                }
            }
        }
        .padding(.bottom, 4)
    }

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Window Rules")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            ForEach(settingsStore.windowRules) { rule in
                HStack {
                    Image(systemName: rule.isEnabled ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(rule.isEnabled ? .green : .secondary)
                        .font(.caption)
                    Text(rule.appName.isEmpty ? rule.appBundleID : rule.appName)
                        .font(.caption)
                    Spacer()
                    Text("Display \(rule.displayIndex + 1)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
            }
        }
        .padding(.bottom, 4)
    }

    private var displayInfoSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Connected Displays")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)

            ForEach(displayManager.currentConfig.displays) { display in
                HStack {
                    Image(systemName: display.isMain ? "display" : "rectangle.on.rectangle")
                        .font(.caption)
                    Text("\(Int(display.width)) x \(Int(display.height))")
                        .font(.caption)
                    if display.isMain {
                        Text("(Main)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 1)
            }
        }
        .padding(.bottom, 4)
    }

    private var footerSection: some View {
        VStack(spacing: 2) {
            Button {
                showingPreferences = true
                if let url = URL(string: "windowflow://preferences") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("Preferences...")
                    Spacer()
                    Text("\u{2318},")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("Quit WindowFlow")
                    Spacer()
                    Text("\u{2318}Q")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct LayoutMenuItem: View {
    let layout: Layout
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: layout.icon)
                    .frame(width: 20)
                Text(layout.name)
                    .font(.callout)
                Spacer()
                if layout.displayCount > 0 {
                    Text("\(layout.displayCount) \(layout.displayCount == 1 ? "display" : "displays")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let keyCode = layout.hotkeyKeyCode {
                    Text(hotkeyDescription(keyCode: keyCode, modifiers: layout.hotkeyModifiers ?? 0))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
    }

    private func hotkeyDescription(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []
        if modifiers & HotkeyModifier.control != 0 { parts.append("\u{2303}") }
        if modifiers & HotkeyModifier.option != 0 { parts.append("\u{2325}") }
        if modifiers & HotkeyModifier.shift != 0 { parts.append("\u{21E7}") }
        if modifiers & HotkeyModifier.command != 0 { parts.append("\u{2318}") }
        // Simplified key name display
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        switch keyCode {
        case KeyCode.leftArrow: return "\u{2190}"
        case KeyCode.rightArrow: return "\u{2192}"
        case KeyCode.upArrow: return "\u{2191}"
        case KeyCode.downArrow: return "\u{2193}"
        case KeyCode.returnKey: return "\u{21A9}"
        case KeyCode.tab: return "\u{21E5}"
        case KeyCode.space: return "\u{2423}"
        case KeyCode.one: return "1"
        case KeyCode.two: return "2"
        case KeyCode.three: return "3"
        case KeyCode.four: return "4"
        case KeyCode.five: return "5"
        case KeyCode.six: return "6"
        default:
            let characters = "asdfhgzxcvbqweryt123456"
            let index = Int(keyCode)
            if index < characters.count {
                let charIndex = characters.index(characters.startIndex, offsetBy: index)
                return String(characters[charIndex]).uppercased()
            }
            return "?"
        }
    }
}
