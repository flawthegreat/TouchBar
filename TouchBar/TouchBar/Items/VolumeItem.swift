import Foundation

class VolumeItem: TouchBar.Button {

    private var previousVolume: Float


    override init(alignment: Alignment) {
        previousVolume = SoundManager.shared.volumeLevel

        super.init(alignment: alignment)

        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            name: NSNotification.Name(rawValue: "com.apple.sound.settingsChangedNotification"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(update),
            names: [.volumeLevelHasChanged, .defaultAudioOutputDeviceHasChanged],
            object: nil
        )

        target = self
        action = #selector(toggleMute)
        swipeLeftAction = #selector(decreaseVolume)
        swipeRightAction = #selector(increaseVolume)

        update()
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    override func update() {
        let volumeLevel = SoundManager.shared.volumeLevel
        if volumeLevel == 0 { image = NSImage(named: "VolumeMuteIcon") }
        else if volumeLevel <= 0.33 { image = NSImage(named: "Volume0Icon") }
        else if volumeLevel <= 0.66 { image = NSImage(named: "Volume1Icon") }
        else if volumeLevel < 1 { image = NSImage(named: "Volume2Icon") }
        else { image = NSImage(named: "Volume3Icon") }
    }

    @objc
    private func increaseVolume() {
        let systemVolume = SoundManager.shared.volumeLevel
        let volume = min(1, systemVolume + 0.12)
        if volume != systemVolume { SoundManager.shared.setVolumeLevel(volume) }
        previousVolume = volume
        update()
    }

    @objc
    private func decreaseVolume() {
        let systemVolume = SoundManager.shared.volumeLevel
        let volume = max(0, systemVolume - 0.12)
        if volume != systemVolume { SoundManager.shared.setVolumeLevel(volume) }
        previousVolume = volume
        update()
    }

    @objc
    private func toggleMute() {
        SoundManager.shared.setVolumeLevel(SoundManager.shared.volumeLevel == 0 ? previousVolume : 0)
        update()
    }
}
