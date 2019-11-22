import Foundation

class BrightnessItem: TouchBar.Slider {

    override init(alignment: Alignment) {
        super.init(alignment: alignment)

        icon.image = NSImage(named: "BrightnessIcon")
        value = NSScreen.displayBrightness
        target = self
        action = #selector(adjustDisplayBrightness)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func adjustDisplayBrightness() {
        NSScreen.setDisplayBrightness(to: min(1.0, max(0.0, value)))
    }
}
