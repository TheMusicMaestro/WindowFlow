import SwiftUI

struct LayoutEditorView: View {
    @State var layout: Layout
    let onSave: (Layout) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(layout.isBuiltIn ? "View Layout" : "Edit Layout")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            // Content
            Form {
                Section("Layout Info") {
                    TextField("Name", text: $layout.name)
                    TextField("SF Symbol Icon", text: $layout.icon)
                    Stepper(
                        "Display count: \(layout.displayCount == 0 ? "Any" : "\(layout.displayCount)")",
                        value: $layout.displayCount,
                        in: 0...3
                    )
                }

                Section("Zones (\(layout.zones.count))") {
                    ForEach(Array(layout.zones.enumerated()), id: \.element.id) { index, zone in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("Zone name", text: Binding(
                                    get: { layout.zones[index].name },
                                    set: { layout.zones[index].name = $0 }
                                ))
                                .font(.callout)

                                Stepper(
                                    "Display \(zone.displayIndex + 1)",
                                    value: Binding(
                                        get: { layout.zones[index].displayIndex },
                                        set: { layout.zones[index].displayIndex = $0 }
                                    ),
                                    in: 0...2
                                )
                                .font(.caption)
                            }

                            HStack {
                                NumberField(label: "X", value: Binding(
                                    get: { layout.zones[index].x },
                                    set: { layout.zones[index].x = $0 }
                                ))
                                NumberField(label: "Y", value: Binding(
                                    get: { layout.zones[index].y },
                                    set: { layout.zones[index].y = $0 }
                                ))
                                NumberField(label: "W", value: Binding(
                                    get: { layout.zones[index].width },
                                    set: { layout.zones[index].width = $0 }
                                ))
                                NumberField(label: "H", value: Binding(
                                    get: { layout.zones[index].height },
                                    set: { layout.zones[index].height = $0 }
                                ))
                            }

                            if !layout.isBuiltIn {
                                HStack {
                                    Spacer()
                                    Button("Remove", role: .destructive) {
                                        layout.zones.remove(at: index)
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if !layout.isBuiltIn {
                        Button {
                            layout.zones.append(LayoutZone(
                                name: "Zone \(layout.zones.count + 1)"
                            ))
                        } label: {
                            Label("Add Zone", systemImage: "plus")
                        }
                    }
                }

                // Layout preview
                Section("Preview") {
                    LayoutPreview(zones: layout.zones)
                        .frame(height: 100)
                }
            }
            .formStyle(.grouped)

            Divider()

            // Footer
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                if !layout.isBuiltIn {
                    Button("Save") {
                        onSave(layout)
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(layout.name.isEmpty || layout.zones.isEmpty)
                }
            }
            .padding()
        }
        .frame(width: 480, height: 560)
    }
}

// MARK: - Supporting Views

struct NumberField: View {
    let label: String
    @Binding var value: Double

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 14)
            TextField("", value: $value, format: .number.precision(.fractionLength(0...2)))
                .font(.caption)
                .frame(width: 44)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct LayoutPreview: View {
    let zones: [LayoutZone]

    private let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .cyan]

    var body: some View {
        GeometryReader { geometry in
            let previewSize = geometry.size

            ForEach(Array(zones.enumerated()), id: \.element.id) { index, zone in
                let color = colors[index % colors.count]
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(color, lineWidth: 1.5)
                    )
                    .overlay(
                        Text(zone.name.isEmpty ? "Zone \(index + 1)" : zone.name)
                            .font(.system(size: 9))
                            .foregroundStyle(color)
                    )
                    .frame(
                        width: previewSize.width * zone.width,
                        height: previewSize.height * zone.height
                    )
                    .offset(
                        x: previewSize.width * zone.x,
                        y: previewSize.height * zone.y
                    )
            }
        }
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
