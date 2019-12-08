import Foundation
import AudioToolbox

class SoundManager {

    public static let shared = SoundManager()

    private var defaultOutputDeviceTypeSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    private var muteStateTypeSize = UInt32(MemoryLayout<Int>.size)
    private var volumeTypeSize = UInt32(MemoryLayout<Float>.size)

    private var defaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMaster
    )

    private var mutePropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyMute,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMaster
    )

    private var volumePropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMaster
    )

    private var defaultOutputDevice = AudioDeviceID(0)

    public var volumeLevel: Float {
        updateDefaultOutputDevice()
        unmute()

        var volumeLevel: Float = 0
        AudioObjectGetPropertyData(
            defaultOutputDevice,
            &volumePropertyAddress,
            0,
            nil,
            &volumeTypeSize,
            &volumeLevel
        )

        return volumeLevel
    }


    private init() {
        updateDefaultOutputDevice()

        AudioObjectAddPropertyListenerBlock(
            defaultOutputDevice,
            &volumePropertyAddress,
            DispatchQueue.main,
            { _, _ in
                NotificationCenter.default.post(
                    name: .volumeLevelHasChanged,
                    object: nil
                )
            }
        )

        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultOutputDevicePropertyAddress,
            { _, _, _, _  in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .defaultAudioOutputDeviceHasChanged,
                        object: nil
                    )
                }
                return 0
            },
            nil
        )
    }


    public func setVolumeLevel(_ level: Float) {
        updateDefaultOutputDevice()
        unmute()

        var volumeLevel = min(1, max(0, level))
        AudioObjectSetPropertyData(
            defaultOutputDevice,
            &volumePropertyAddress,
            0,
            nil,
            volumeTypeSize,
            &volumeLevel
        )
    }

    private func updateDefaultOutputDevice() {
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultOutputDevicePropertyAddress,
            0,
            nil,
            &defaultOutputDeviceTypeSize,
            &defaultOutputDevice
        )
    }

    private func unmute() {
        var mute = 0
        AudioObjectSetPropertyData(
            defaultOutputDevice,
            &mutePropertyAddress,
            0,
            nil,
            muteStateTypeSize,
            &mute
        )
    }
}
