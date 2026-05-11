import SwiftUI

struct PreferencesView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(settingsStore: settingsStore)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)

            LayoutSettingsView(settingsStore: settingsStore)
                .tabItem {
                    Label("Layouts", systemImage: "rectangle.split.2x1")
                }
                .tag(1)

            RulesSettingsView(settingsStore: settingsStore)
                .tabItem {
                    Label("Rules", systemImage: "list.bullet.rectangle")
                }
                .tag(2)

            HotkeysSettingsView(settingsStore: settingsStore)
                .tabItem {
                    Label("Hotkeys", systemImage: "keyboard")
                }
                .tag(3)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(4)
        }
        .frame(width: 520, height: 420)
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        Form {
            Section {
                Toggle("Launch at login", isOn: $settingsStore.launchAtLogin)
                Toggle("Play sound on layout change", isOn: $settingsStore.enableSound)
                Toggle("Animate window movements", isOn: $settingsStore.animateWindows)
            }

            Section("Window Gaps") {
                HStack {
                    Text("Gap size:")
                    Slider(value: $settingsStore.gapSize, in: 0...20, step: 1)
                    Text("\(Int(settingsStore.gapSize)) px")
                        .frame(width: 40)
                        .monospacedDigit()
                }
            }

            Section("Accessibility") {
                HStack {
                    if WindowManager.hasAccessibilityPermission {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Accessibility access granted")
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                        Text("Accessibility access required")
                        Spacer()
                        Button("Grant Access") {
                            WindowManager.requestAccessibilityPermission()
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Layout Settings

struct LayoutSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var selectedLayout: Layout?
    @State private var showingEditor = false

    var body: some View {
        VStack {
            List {
                Section("Built-in Layouts") {
                    ForEach(PresetLayouts.allPresets) { layout in
                        HStack {
                            Image(systemName: layout.icon)
                                .frame(width: 24)
                            Text(layout.name)
                            Spacer()
                            Text("\(layout.zones.count) zones")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            if layout.displayCount > 0 {
                                Text("\(layout.displayCount) displays")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section("Custom Layouts") {
                    ForEach(settingsStore.customLayouts) { layout in
                        HStack {
                            Image(systemName: layout.icon)
                                .frame(width: 24)
                            Text(layout.name)
                            Spacer()
                            Text("\(layout.zones.count) zones")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .contextMenu {
                            Button("Edit") {
                                selectedLayout = layout
                                showingEditor = true
                            }
                            Button("Delete", role: .destructive) {
                                settingsStore.deleteLayout(layout)
                            }
                        }
                    }

                    if settingsStore.customLayouts.isEmpty {
                        Text("No custom layouts yet")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
            }

            HStack {
                Button {
                    selectedLayout = Layout(name: "New Layout")
                    showingEditor = true
                } label: {
                    Label("Add Layout", systemImage: "plus")
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingEditor) {
            if let layout = selectedLayout {
                LayoutEditorView(
                    layout: layout,
                    onSave: { updatedLayout in
                        if settingsStore.customLayouts.contains(where: { $0.id == updatedLayout.id }) {
                            settingsStore.updateLayout(updatedLayout)
                        } else {
                            settingsStore.addLayout(updatedLayout)
                        }
                        showingEditor = false
                    },
                    onCancel: { showingEditor = false }
                )
            }
        }
    }
}

// MARK: - Rules Settings

struct RulesSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var showingAddRule = false
    @State private var newBundleID = ""
    @State private var newAppName = ""
    @State private var newDisplayIndex = 0

    var body: some View {
        VStack {
            List {
                ForEach(settingsStore.windowRules) { rule in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { rule.isEnabled },
                            set: { newValue in
                                var updated = rule
                                updated = WindowRule(
                                    id: rule.id,
                                    appBundleID: rule.appBundleID,
                                    appName: rule.appName,
                                    displayIndex: rule.displayIndex,
                                    zone: rule.zone,
                                    isEnabled: newValue
                                )
                                settingsStore.updateRule(updated)
                            }
                        ))
                        .labelsHidden()

                        VStack(alignment: .leading) {
                            Text(rule.appName.isEmpty ? rule.appBundleID : rule.appName)
                                .font(.callout)
                            Text(rule.appBundleID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Display \(rule.displayIndex + 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            settingsStore.deleteRule(rule)
                        }
                    }
                }

                if settingsStore.windowRules.isEmpty {
                    Text("No window rules defined. Add rules to automatically place specific apps.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }

            HStack {
                Button {
                    showingAddRule = true
                } label: {
                    Label("Add Rule", systemImage: "plus")
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingAddRule) {
            VStack(spacing: 16) {
                Text("Add Window Rule")
                    .font(.headline)

                TextField("App Name (e.g., Slack)", text: $newAppName)
                TextField("Bundle ID (e.g., com.tinyspeck.slackmacgap)", text: $newBundleID)

                Stepper("Display: \(newDisplayIndex + 1)", value: $newDisplayIndex, in: 0...2)

                HStack {
                    Button("Cancel") { showingAddRule = false }
                    Spacer()
                    Button("Add") {
                        let rule = WindowRule(
                            appBundleID: newBundleID,
                            appName: newAppName,
                            displayIndex: newDisplayIndex,
                            zone: LayoutZone(displayIndex: newDisplayIndex, x: 0, y: 0, width: 1, height: 1)
                        )
                        settingsStore.addRule(rule)
                        newBundleID = ""
                        newAppName = ""
                        newDisplayIndex = 0
                        showingAddRule = false
                    }
                    .disabled(newBundleID.isEmpty)
                }
            }
            .frame(width: 350)
            .padding()
        }
    }
}

// MARK: - Hotkeys Settings

struct HotkeysSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Default Keyboard Shortcuts")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)

            List {
                Section("Quick Actions") {
                    HotkeyRow(label: "Left Half", shortcut: "\u{2303}\u{2325}\u{2190}")
                    HotkeyRow(label: "Right Half", shortcut: "\u{2303}\u{2325}\u{2192}")
                    HotkeyRow(label: "Top Half", shortcut: "\u{2303}\u{2325}\u{2191}")
                    HotkeyRow(label: "Bottom Half", shortcut: "\u{2303}\u{2325}\u{2193}")
                    HotkeyRow(label: "Maximize", shortcut: "\u{2303}\u{2325}\u{21A9}")
                    HotkeyRow(label: "Center", shortcut: "\u{2303}\u{2325}C")
                }

                Section("Move to Display") {
                    HotkeyRow(label: "Display 1", shortcut: "\u{2303}\u{2325}1")
                    HotkeyRow(label: "Display 2", shortcut: "\u{2303}\u{2325}2")
                    HotkeyRow(label: "Display 3", shortcut: "\u{2303}\u{2325}3")
                }
            }

            Text("Custom layout hotkeys can be set in the Layouts tab.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

struct HotkeyRow: View {
    let label: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(shortcut)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "macwindow.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("WindowFlow")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Automatic window management for macOS.\nArrange your windows across up to 3 displays\nwith predefined or custom layouts.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.top, 40)
    }
}
