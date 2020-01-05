extension TouchBar {
    class Application {

        final class Card: NSButton {

            private unowned var application: Application
            private unowned var applicationManager: ApplicationManager


            init(accentColor: NSColor, application: Application, applicationManager: ApplicationManager) {
                self.application = application
                self.applicationManager = applicationManager

                super.init(frame: NSRect(
                    origin: CGPoint(x: -NSTouchBar.cardSize.width, y: 0),
                    size: NSTouchBar.cardSize
                ))

                bezelStyle = .rounded
                bezelColor = accentColor
                font = .systemFont(ofSize: 17)

                target = self
                action = #selector(runApplication)
            }

            required init?(coder: NSCoder) { fatalError() }


            @objc
            func runApplication() {
                applicationManager.runApplication(application)
            }
        }

        let name: String
        private(set) var card: Card!
        private(set) var view: NSView?

        
        init(name: String, accentColor: NSColor) {
            self.name = name
            card = Card(
                accentColor: accentColor,
                application: self,
                applicationManager: TouchBar.shared.applicationManager
            )
        }

        required init?(coder: NSCoder) { fatalError() }


        final func createView(frame: NSRect) {
            view = NSView(frame: frame)
            initView()
        }

        private func initView() {
            view?.wantsLayer = true
            view?.layer?.backgroundColor = NSColor.green.cgColor
        }

        final func removeView() {
            view?.removeFromSuperview()
            view = nil
        }

        func updateWidth() {}
        func applicationWillTerminate() {}
    }
}
