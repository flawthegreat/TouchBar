class VolumeItem: TouchBar.Button {

    private static let iconUpdateDelay = 0.05

    override init(alignment: Alignment) {
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
        tapLeftAction = #selector(decreaseVolume)
        tapRightAction = #selector(increaseVolume)

        update()
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
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
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.iconUpdateDelay) { self.update() }
    }

    @objc
    private func decreaseVolume() {
        Keyboard.pressKey(withKeyCode: Keyboard.ControlKey.volumeDown)
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.iconUpdateDelay) { self.update() }
    }

    @objc
    private func toggleMute() {
        Keyboard.pressKey(withKeyCode: Keyboard.ControlKey.mute)
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.iconUpdateDelay) { self.update() }
    }
}
