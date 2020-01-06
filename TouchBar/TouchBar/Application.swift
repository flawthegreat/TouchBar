extension TouchBar {
    class Application {

        final class Icon: NSButton {

            private(set) unowned var application: Application


            init(color: NSColor, application: Application) {
                self.application = application

                super.init(frame: NSRect(origin: .zero, size: TouchBar.applicationIconSize))

                bezelStyle = .rounded
                bezelColor = color
                font = .systemFont(ofSize: 17)
            }

            required init?(coder: NSCoder) { fatalError() }
        }

        private(set) var icon: Icon!
        private(set) var view: NSView?


        init(iconColor: NSColor) { icon = Icon(color: iconColor, application: self) }

        required init?(coder: NSCoder) { fatalError() }


        final func createInstance(width: CGFloat) {
            view = createView(width: width)
        }

        final func removeInstance() {
            view?.removeFromSuperview()
            view = nil
        }

        func createView(width: CGFloat) -> NSView { return NSView(x: 0, width: width) }
        func applicationWillTerminate() {}
        func updateWidth() {}
    }
}
