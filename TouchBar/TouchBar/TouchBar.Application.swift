import Foundation

extension TouchBar {
    class Application: NSView {

        public let name: String

        init(width: CGFloat, name: String) {
            self.name = name

            super.init(frame: NSRect(x: 0, y: 0, width: width, height: NSTouchBar.size.height))

            print("Application \(name) has started")
        }

        required init?(coder: NSCoder) { fatalError() }

        deinit {
            print("Application \(name) was terminated")
        }


        public func updateContentsToMatchWidth(_ width: CGFloat) {
            updateWidth(width)
            NotificationCenter.default.post(
                name: .touchBarApplicationDidChangeWidth,
                object: nil
            )
        }

        public func updateWidth(_ width: CGFloat) {}

        public func applicationWillTerminate() {}
    }
}
