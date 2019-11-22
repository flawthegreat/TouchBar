import Foundation
import AudioToolbox

let animationDuration: TimeInterval = 0.2
let swipeThreshold: CGFloat = 20.0

public struct Offset {
    var left: CGFloat = 0.0
    var right: CGFloat = 0.0
}

public extension Date {
    func string(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

public extension NSView {
    static func animate(
        withDuration duration: TimeInterval,
        changes: (NSAnimationContext) -> Void,
        completionHandler: (() -> Void)?
    ) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            changes(context)
        }, completionHandler: completionHandler)
    }

    static func animate(
        withDuration duration: TimeInterval,
        _ changes: (NSAnimationContext) -> Void
    ) {
        animate(withDuration: duration, changes: changes, completionHandler: nil)
    }
}

public extension NotificationCenter {
    func addObserver(
        _ observer: Any,
        selector: Selector,
        names: [NSNotification.Name],
        object: Any?
    ) {
        for name in names {
            addObserver(observer, selector: selector, name: name, object: object)
        }
    }
}

public extension NSScreen {
//    private static var _service: io_object_t?
//
//    private static var service: io_object_t {
//        if _service != nil { return _service! }
//
//        var iterator: io_iterator_t = 0
//
//        IOServiceGetMatchingServices(
//            kIOMasterPortDefault,
//            IOServiceMatching("IODisplayConnect"),
//            &iterator
//        )
//        _service = IOIteratorNext(iterator)
//
//        return _service!
//    }

    static var displayBrightness: CGFloat {
        return CGFloat(CoreDisplay_Display_GetUserBrightness(0))

//        var brightnessLevel: Float = 0.0
//        IODisplayGetFloatParameter(
//            service,
//            0,
//            kIODisplayBrightnessKey as CFString,
//            &brightnessLevel
//        )
//
//        return CGFloat(brightnessLevel)
    }

    static func setDisplayBrightness(to brightness: CGFloat) {
        CoreDisplay_Display_SetUserBrightness(0, Double(brightness))

//        IODisplaySetFloatParameter(
//            service,
//            0,
//            kIODisplayBrightnessKey as CFString,
//            Float(brightness)
//        )
    }
}

public extension NSSound {
    static var defaultOutputDevice: AudioDeviceID {
        var defaultOutputDeviceID = AudioDeviceID(0)
        var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))

        var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
        )

        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &getDefaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceIDSize,
            &defaultOutputDeviceID
        )

        return defaultOutputDeviceID
    }

    static var systemVolume: CGFloat {
        var volume = Float32(0.0)
        var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster
        )

        AudioObjectGetPropertyData(
            defaultOutputDevice,
            &volumePropertyAddress,
            0,
            nil,
            &volumeSize,
            &volume
        )

        return CGFloat(volume)
    }

    static func setSystemVolume(_ newVolume: CGFloat) {
        var volume = Float(min(1.0, max(0.0, newVolume)))

        var volumePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMaster
        )

        AudioObjectSetPropertyData(
            defaultOutputDevice,
            &volumePropertyAddress,
            0,
            nil,
            UInt32(MemoryLayout.size(ofValue: volume)),
            &volume
        )
    }
}
