final class ControlStripItem: NSCustomTouchBarItem {

    private class ButtonBackground: NSView {

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)

            wantsLayer = true
            layer?.backgroundColor = NSColor.controlAlternatingRowBackgroundColors[1].cgColor
        }

        required init?(coder: NSCoder) { fatalError() }


        override func touchesBegan(with event: NSEvent) {
            super.touchesBegan(with: event)
            layer?.backgroundColor = NSColor.controlColor.cgColor
        }

        override func touchesEnded(with event: NSEvent) {
            super.touchesEnded(with: event)
            layer?.backgroundColor = NSColor.controlAlternatingRowBackgroundColors[1].cgColor
        }
    }


    init(target: AnyObject?, action: Selector?) {
        super.init(identifier: .controlStripItem)

        view = NSButton(title: "􀏪", target: target, action: action)
        if view.subviews.count > 0 {
            view.subviews[0] = ButtonBackground(frame: NSRect(origin: .zero, size: TouchBar.buttonSize))
        }
    }

    required init?(coder: NSCoder) { fatalError() }
}
