import AudioToolbox

final class VolumeItem: TouchBar.Button {

    override init(alignment: Alignment) {
        super.init(alignment: alignment)

        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            name: NSNotification.Name(rawValue: "com.apple.sound.settingsChangedNotification")
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            names: [.volumeLevelHasChanged, .defaultAudioOutputDeviceHasChanged]
        )

        target = self
        middleAction = #selector(toggleMute)
        leftAction = #selector(decreaseVolume)
        rightAction = #selector(increaseVolume)

        update()
    }

    required init?(coder: NSCoder) { fatalError() }


    override func update() {
        if SoundManager.shared.isMuted {
            image = NSImage(named: "VolumeMuteIcon")
            return
        }

        let volumeLevel = SoundManager.shared.volumeLevel
        if volumeLevel == 0 { image = NSImage(named: "Volume0Icon") }
        else if volumeLevel <= 0.375 { image = NSImage(named: "Volume1Icon") }
        else if volumeLevel <= 0.625 { image = NSImage(named: "Volume2Icon") }
        else { image = NSImage(named: "Volume3Icon") }
    }

    @objc
    private func increaseVolume() {
        Keyboard.pressKey(withKeyCode: Keyboard.ControlKey.volumeUp)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [unowned self] in self.update() }
    }

    @objc
    private func decreaseVolume() {
        Keyboard.pressKey(withKeyCode: Keyboard.ControlKey.volumeDown)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [unowned self] in self.update() }
    }

    @objc
    private func toggleMute() {
        Keyboard.pressKey(withKeyCode: Keyboard.ControlKey.mute)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [unowned self] in self.update() }
    }
}

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
            { _, _ in NotificationCenter.default.postNotification(.volumeLevelHasChanged) }
        )

        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultOutputDevicePropertyAddress,
            { _, _, _, _  in
                DispatchQueue.main.async {
                    NotificationCenter.default.postNotification(.defaultAudioOutputDeviceHasChanged)
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
