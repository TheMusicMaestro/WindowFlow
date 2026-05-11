import Foundation
import Combine

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private let userDefaults = UserDefaults.standard
    private let customLayoutsKey = "com.windowflow.customLayouts"
    private let windowRulesKey = "com.windowflow.windowRules"
    private let launchAtLoginKey = "com.windowflow.launchAtLogin"
    private let showDockIconKey = "com.windowflow.showDockIcon"
    private let enableSoundKey = "com.windowflow.enableSound"
    private let animateWindowsKey = "com.windowflow.animateWindows"
    private let gapSizeKey = "com.windowflow.gapSize"

    @Published var customLayouts: [Layout] {
        didSet { saveLayouts() }
    }

    @Published var windowRules: [WindowRule] {
        didSet { saveRules() }
    }

    @Published var launchAtLogin: Bool {
        didSet { userDefaults.set(launchAtLogin, forKey: launchAtLoginKey) }
    }

    @Published var showDockIcon: Bool {
        didSet { userDefaults.set(showDockIcon, forKey: showDockIconKey) }
    }

    @Published var enableSound: Bool {
        didSet { userDefaults.set(enableSound, forKey: enableSoundKey) }
    }

    @Published var animateWindows: Bool {
        didSet { userDefaults.set(animateWindows, forKey: animateWindowsKey) }
    }

    @Published var gapSize: Double {
        didSet { userDefaults.set(gapSize, forKey: gapSizeKey) }
    }

    private init() {
        customLayouts = Self.loadLayouts(from: userDefaults, key: customLayoutsKey)
        windowRules = Self.loadRules(from: userDefaults, key: windowRulesKey)
        launchAtLogin = userDefaults.bool(forKey: launchAtLoginKey)
        showDockIcon = userDefaults.object(forKey: showDockIconKey) as? Bool ?? false
        enableSound = userDefaults.object(forKey: enableSoundKey) as? Bool ?? true
        animateWindows = userDefaults.object(forKey: animateWindowsKey) as? Bool ?? true
        gapSize = userDefaults.object(forKey: gapSizeKey) as? Double ?? 0
    }

    // MARK: - All Layouts (built-in + custom)

    var allLayouts: [Layout] {
        PresetLayouts.allPresets + customLayouts
    }

    func layouts(forDisplayCount count: Int) -> [Layout] {
        allLayouts.filter { $0.displayCount == 0 || $0.displayCount <= count }
    }

    // MARK: - CRUD Operations

    func addLayout(_ layout: Layout) {
        customLayouts.append(layout)
    }

    func updateLayout(_ layout: Layout) {
        if let index = customLayouts.firstIndex(where: { $0.id == layout.id }) {
            customLayouts[index] = layout
        }
    }

    func deleteLayout(_ layout: Layout) {
        customLayouts.removeAll(where: { $0.id == layout.id })
    }

    func addRule(_ rule: WindowRule) {
        windowRules.append(rule)
    }

    func updateRule(_ rule: WindowRule) {
        if let index = windowRules.firstIndex(where: { $0.id == rule.id }) {
            windowRules[index] = rule
        }
    }

    func deleteRule(_ rule: WindowRule) {
        windowRules.removeAll(where: { $0.id == rule.id })
    }

    // MARK: - Persistence

    private func saveLayouts() {
        guard let data = try? JSONEncoder().encode(customLayouts) else { return }
        userDefaults.set(data, forKey: customLayoutsKey)
    }

    private func saveRules() {
        guard let data = try? JSONEncoder().encode(windowRules) else { return }
        userDefaults.set(data, forKey: windowRulesKey)
    }

    private static func loadLayouts(from defaults: UserDefaults, key: String) -> [Layout] {
        guard let data = defaults.data(forKey: key),
              let layouts = try? JSONDecoder().decode([Layout].self, from: data) else {
            return []
        }
        return layouts
    }

    private static func loadRules(from defaults: UserDefaults, key: String) -> [WindowRule] {
        guard let data = defaults.data(forKey: key),
              let rules = try? JSONDecoder().decode([WindowRule].self, from: data) else {
            return []
        }
        return rules
    }

    // MARK: - Export / Import

    func exportToJSON() -> Data? {
        let exportData = ExportData(layouts: customLayouts, rules: windowRules)
        return try? JSONEncoder().encode(exportData)
    }

    func importFromJSON(_ data: Data) -> Bool {
        guard let exportData = try? JSONDecoder().decode(ExportData.self, from: data) else {
            return false
        }
        customLayouts.append(contentsOf: exportData.layouts)
        windowRules.append(contentsOf: exportData.rules)
        return true
    }

    private struct ExportData: Codable {
        let layouts: [Layout]
        let rules: [WindowRule]
    }
}
