extension TouchBar {
    class Application: NSView {

        let name: String

        init(width: CGFloat, name: String) {
            self.name = name

            super.init(frame: NSRect(x: 0, y: 0, width: width, height: NSTouchBar.size.height))

            print("Application \(name) has started")
        }

        required init?(coder: NSCoder) { fatalError() }

        deinit { print("Application \(name) was terminated") }


        func updateWidth(_ width: CGFloat) {
            updateContentsToMatchWidth(width)
            NotificationCenter.default.post(
                name: .touchBarApplicationDidChangeWidth,
                object: nil
            )
        }

        func updateContentsToMatchWidth(_ width: CGFloat) {}

        func applicationWillTerminate() {}
    }
}
