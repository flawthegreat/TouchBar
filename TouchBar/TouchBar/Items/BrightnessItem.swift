import Foundation

class BrightnessItem: TouchBar.Slider {

    override init(alignment: Alignment) {
        super.init(alignment: alignment)

        icon.image = NSImage(named: "BrightnessIcon")
        value = CGFloat(NSScreen.displayBrightness)
        target = self
        action = #selector(adjustDisplayBrightness)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func adjustDisplayBrightness() {
        NSScreen.displayBrightness = Double(value)
    }
}
