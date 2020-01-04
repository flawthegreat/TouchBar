import CoreGraphics

class Keyboard {

    typealias KeyCode = UInt32

    struct ControlKey {
        static var volumeUp: KeyCode = 0
        static var volumeDown: KeyCode = 1
        static var brightnessUp: KeyCode = 2
        static var brightnessDown: KeyCode = 3
        static var capsLock: KeyCode = 4
        static var help: KeyCode = 5
        static var power: KeyCode = 6
        static var mute: KeyCode = 7
        static var upArrow: KeyCode = 8
        static var downArrow: KeyCode = 9
        static var numLock: KeyCode = 10

        static var contrastUp: KeyCode = 11
        static var contrastDown: KeyCode = 12
        static var launchPanel: KeyCode = 13
        static var eject: KeyCode = 14
        static var vidMirror: KeyCode = 15

        static var play: KeyCode = 16
        static var next: KeyCode = 17
        static var previous: KeyCode = 18
        static var fast: KeyCode = 19
        static var rewind: KeyCode = 20

        static var illuminationUp: KeyCode = 21
        static var illuminationDown: KeyCode = 22
        static var illuminationToggle: KeyCode = 23
    }

    
    class func pressKey(withKeyCode keyCode: KeyCode) {
        func sendEvent(down: Bool) {
            let event = NSEvent.otherEvent(
                with: .systemDefined,
                location: .zero,
                modifierFlags: .init(rawValue: (down ? 0xa00 : 0xb00)),
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: 8,
                data1: Int((keyCode << 16) | (down ? 0xa00 : 0xb00)),
                data2: -1
            )

            event?.cgEvent?.post(tap: .cghidEventTap)
        }

        sendEvent(down: true)
        sendEvent(down: false)
    }
}
