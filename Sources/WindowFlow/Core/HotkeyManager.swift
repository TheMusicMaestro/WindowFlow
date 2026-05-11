import Foundation
import Carbon
import Combine

/// Manages global keyboard shortcuts using the Carbon Event API.
final class HotkeyManager {
    static let shared = HotkeyManager()

    private var registeredHotkeys: [UInt32: RegisteredHotkey] = [:]
    private var nextID: UInt32 = 1

    struct RegisteredHotkey {
        let id: UInt32
        let ref: EventHotKeyRef
        let handler: () -> Void
    }

    private init() {
        installEventHandler()
    }

    // MARK: - Registration

    @discardableResult
    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) -> UInt32 {
        let hotkeyID = EventHotKeyID(signature: fourCharCode("WFLW"), id: nextID)
        var ref: EventHotKeyRef?

        let carbonModifiers = carbonModifierFlags(from: modifiers)

        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )

        guard status == noErr, let hotkeyRef = ref else {
            return 0
        }

        let id = nextID
        registeredHotkeys[id] = RegisteredHotkey(id: id, ref: hotkeyRef, handler: handler)
        nextID += 1
        return id
    }

    func unregister(id: UInt32) {
        guard let hotkey = registeredHotkeys.removeValue(forKey: id) else { return }
        UnregisterEventHotKey(hotkey.ref)
    }

    func unregisterAll() {
        for (_, hotkey) in registeredHotkeys {
            UnregisterEventHotKey(hotkey.ref)
        }
        registeredHotkeys.removeAll()
    }

    // MARK: - Event Handling

    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handler: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let event = event, let userData = userData else { return OSStatus(eventNotHandledErr) }

            var hotkeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                UInt32(kEventParamDirectObject),
                UInt32(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotkeyID
            )

            guard status == noErr else { return status }

            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            if let registered = manager.registeredHotkeys[hotkeyID.id] {
                DispatchQueue.main.async {
                    registered.handler()
                }
            }

            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
    }

    // MARK: - Helpers

    private func carbonModifierFlags(from flags: UInt32) -> UInt32 {
        var carbonFlags: UInt32 = 0
        if flags & (1 << 0) != 0 { carbonFlags |= UInt32(cmdKey) }
        if flags & (1 << 1) != 0 { carbonFlags |= UInt32(optionKey) }
        if flags & (1 << 2) != 0 { carbonFlags |= UInt32(controlKey) }
        if flags & (1 << 3) != 0 { carbonFlags |= UInt32(shiftKey) }
        return carbonFlags
    }

    private func fourCharCode(_ string: String) -> OSType {
        var result: OSType = 0
        for char in string.utf8.prefix(4) {
            result = (result << 8) | OSType(char)
        }
        return result
    }
}

// Modifier flag constants for use in Layout hotkey definitions.
// Bit 0 = Cmd, Bit 1 = Option, Bit 2 = Control, Bit 3 = Shift
enum HotkeyModifier {
    static let command: UInt32  = 1 << 0
    static let option: UInt32   = 1 << 1
    static let control: UInt32  = 1 << 2
    static let shift: UInt32    = 1 << 3
}

/// Common key codes for macOS virtual key codes.
enum KeyCode {
    static let a: UInt32 = 0x00
    static let s: UInt32 = 0x01
    static let d: UInt32 = 0x02
    static let f: UInt32 = 0x03
    static let h: UInt32 = 0x04
    static let g: UInt32 = 0x05
    static let z: UInt32 = 0x06
    static let x: UInt32 = 0x07
    static let c: UInt32 = 0x08
    static let v: UInt32 = 0x09
    static let b: UInt32 = 0x0B
    static let q: UInt32 = 0x0C
    static let w: UInt32 = 0x0D
    static let e: UInt32 = 0x0E
    static let r: UInt32 = 0x0F
    static let y: UInt32 = 0x10
    static let t: UInt32 = 0x11
    static let one: UInt32 = 0x12
    static let two: UInt32 = 0x13
    static let three: UInt32 = 0x14
    static let four: UInt32 = 0x15
    static let five: UInt32 = 0x17
    static let six: UInt32 = 0x16
    static let leftArrow: UInt32 = 0x7B
    static let rightArrow: UInt32 = 0x7C
    static let downArrow: UInt32 = 0x7D
    static let upArrow: UInt32 = 0x7E
    static let returnKey: UInt32 = 0x24
    static let tab: UInt32 = 0x30
    static let space: UInt32 = 0x31
    static let m: UInt32 = 0x2E
    static let n: UInt32 = 0x2D
}
