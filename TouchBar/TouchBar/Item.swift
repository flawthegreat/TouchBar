extension TouchBar {
    class Item: NSView {

        enum Alignment { case left, right }

        let alignment: Alignment


        init(alignment: Alignment, width: CGFloat) {
            self.alignment = alignment

            super.init(frame: NSRect(x: 0, y: 0, width: width, height: TouchBar.size.height))

            NSWorkspace.shared.notificationCenter.addObserver(
                self,
                selector: #selector(update),
                name: NSWorkspace.screensDidWakeNotification
            )
        }

        required init?(coder: NSCoder) { fatalError() }


        @objc
        func update() {}
    }
}
