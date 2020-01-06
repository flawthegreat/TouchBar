final class BrightnessItem: TouchBar.Slider {

    init(alignment: Alignment) {
        super.init(alignment: alignment, value: NSScreen.displayBrightness)

        icon.image = NSImage(named: "BrightnessIcon")
        target = self
        action = #selector(adjustDisplayBrightness)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func adjustDisplayBrightness() {
        NSScreen.displayBrightness = Double(value)
    }
}

extension NSScreen {
    static var displayBrightness: Double {
        get { CoreDisplay_Display_GetUserBrightness(0) }
        set { CoreDisplay_Display_SetUserBrightness(0, max(0, min(1, newValue))) }
    }
}
