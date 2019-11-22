import Foundation

class VolumeItem: TouchBar.Button {

    private var previousVolume: CGFloat


    override init(alignment: Alignment) {
        previousVolume = NSSound.systemVolume

        super.init(alignment: alignment)

        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(updateIcon),
            name: NSNotification.Name(rawValue: "com.apple.sound.settingsChangedNotification"),
            object: nil
        )

        target = self
        action = #selector(toggleMute)
        swipeLeftAction = #selector(decreaseVolume)
        swipeRightAction = #selector(increaseVolume)

        updateIcon()
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func updateIcon() {
        let volumeLevel = NSSound.systemVolume
        if volumeLevel == 0.0 { image = NSImage(named: "VolumeMuteIcon") }
        else if volumeLevel <= 0.33 { image = NSImage(named: "Volume0Icon") }
        else if volumeLevel <= 0.66 { image = NSImage(named: "Volume1Icon") }
        else if volumeLevel < 1.0 { image = NSImage(named: "Volume2Icon") }
        else { image = NSImage(named: "Volume3Icon") }
    }

    @objc
    private func increaseVolume() {
        let systemVolume = NSSound.systemVolume
        let volume = min(1.0, systemVolume + 0.12)
        if volume != systemVolume { NSSound.setSystemVolume(volume) }
        previousVolume = volume
        updateIcon()
    }

    @objc
    private func decreaseVolume() {
        let systemVolume = NSSound.systemVolume
        let volume = max(0.0, systemVolume - 0.12)
        if volume != systemVolume { NSSound.setSystemVolume(volume) }
        previousVolume = volume
        updateIcon()
    }

    @objc
    private func toggleMute() {
        if NSSound.systemVolume == 0.0 {
            NSSound.setSystemVolume(previousVolume)
        } else {
            NSSound.setSystemVolume(0.0)
        }
        updateIcon()
    }
}
