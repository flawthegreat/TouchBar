import Foundation

extension TouchBar {
    class ApplicationView: NSScrollView {

        private let applicationContainer: NSView
        private var isDimmed: Bool

        public private(set) var application: Application?

        
        init(x: CGFloat, width: CGFloat) {
            applicationContainer = NSView(frame: NSRect(
                origin: .zero,
                size: CGSize(width: 0, height: NSTouchBar.size.height)
            ))
            isDimmed = false

            application = nil

            super.init(frame: NSRect(x: x, y: 0, width: width, height: NSTouchBar.size.height))

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationViewDidChangeWidth),
                name: Notification.touchBarApplicationViewDidChangeWidth,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidChangeWidth),
                name: Notification.touchBarApplicationDidChangeWidth,
                object: nil
            )

            addSubview(applicationContainer)
        }

        required init?(coder: NSCoder) { fatalError() }


        @objc
        private func applicationViewDidChangeWidth() {
            application?.updateContentsToMatchWidth(animator().frame.width)
        }

        @objc
        private func applicationDidChangeWidth() {
            applicationContainer.frame.size.width = application?.frame.width ?? 0.0
        }

        public func dimApplication() {
            guard application != nil else { return }
            isDimmed = true
            NSView.animate(withDuration: animationDuration) { _ in
                applicationContainer.animator().alphaValue = 0.5
            }
        }

        public func makeApplicationActive() {
            NSView.animate(withDuration: animationDuration, changes: { _ in
                applicationContainer.animator().alphaValue = 1.0
            }, completionHandler: { self.isDimmed = false })
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            if isDimmed {
                makeApplicationActive()
                return nil
            }
            return super.hitTest(point)
        }

        private func hideApplication(completionHandler callback: @escaping () -> Void = {}) {
            NSView.animate(withDuration: animationDuration, changes: { _ in
                applicationContainer.animator().alphaValue = 0.0
            }, completionHandler: callback)
        }

        private func showApplication(completionHandler callback: @escaping () -> Void = {}) {
            NSView.animate(withDuration: animationDuration, changes: { _ in
                applicationContainer.animator().alphaValue = 1.0
            }, completionHandler: callback)
        }

        public func runApplication(_ application: Application) {
            if self.application != nil {
                terminateApplication {
                    self.application = application
                    self.applicationContainer.addSubview(application)
                    self.applicationContainer.frame.size = application.frame.size
                    self.applicationViewDidChangeWidth()

                    self.showApplication()
                }
            } else {
                self.application = application
                applicationContainer.alphaValue = 0.0
                applicationContainer.addSubview(application)
                applicationContainer.frame.size = application.frame.size
                applicationViewDidChangeWidth()

                showApplication()
            }

            makeApplicationActive()
        }

        public func terminateApplication(completionHandler callback: @escaping () -> Void = {}) {
            if application == nil { return }

            hideApplication {
                self.application?.applicationWillTerminate()
                self.application?.removeFromSuperview()
                self.applicationContainer.frame.size.width = 0
                self.application = nil
                NotificationCenter.default.post(
                    name: Notification.touchBarApplicationDidTerminate,
                    object: nil
                )
                callback()
            }
        }
    }
}
