extension TouchBar {
    class ApplicationView: NSView {
        init(x: CGFloat, width: CGFloat) {
            super.init(frame: NSRect(x: x, y: 0, width: width, height: NSTouchBar.size.height))

            wantsLayer = true
            layer?.backgroundColor = NSColor.green.cgColor
        }

        required init?(coder: NSCoder) { fatalError() }
    }
}
