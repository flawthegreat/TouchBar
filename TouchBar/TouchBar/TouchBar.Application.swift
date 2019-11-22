import Foundation

extension Notification {
    static let touchBarApplicationDidTerminate = Notification.Name(
        "touchBarApplicatioDidTerminate"
    )
    static let touchBarApplicationWillTerminate = Notification.Name(
        "touchBarApplicatioWillTerminate"
    )
}

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
            print("Application \(name) was successfully terminated")
        }


        public func updateContentsToMatchWidth(_ width: CGFloat) {
            NotificationCenter.default.post(
                name: Notification.touchBarApplicationDidChangeWidth,
                object: nil
            )
        }

        public func applicationWillTerminate() {}
    }
}
