import AudioToolbox

class SoundManager {

    static let shared = SoundManager()

    private var defaultOutputDeviceTypeSize = UInt32(MemoryLayout<AudioDeviceID>.size)
    private var muteStateTypeSize = UInt32(MemoryLayout<UInt32>.size)
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

    var volumeLevel: Float {
        updateDefaultOutputDevice()

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

    var isMuted: Bool {
        updateDefaultOutputDevice()

        var isMuted: UInt32 = 0
        AudioObjectGetPropertyData(
            defaultOutputDevice,
            &mutePropertyAddress,
            0,
            nil,
            &muteStateTypeSize,
            &isMuted
        )

        return isMuted != 0
    }


    private init() {
        updateDefaultOutputDevice()

        AudioObjectAddPropertyListenerBlock(
            defaultOutputDevice,
            &volumePropertyAddress,
            DispatchQueue.main,
            { _, _ in NotificationCenter.default.post(notification: .volumeLevelHasChanged) }
        )

        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultOutputDevicePropertyAddress,
            { _, _, _, _  in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(notification: .defaultAudioOutputDeviceHasChanged)
                }
                return 0
            },
            nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(updateDefaultOutputDevice),
            name: .defaultAudioOutputDeviceHasChanged
        )
    }


    @objc
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
}
