import Foundation

extension TouchBar {
    class ApplicationView: NSView {

        private var isDimmed: Bool

        public private(set) var application: Application?

        
        init(x: CGFloat, width: CGFloat) {
            isDimmed = false

            application = nil

            super.init(frame: NSRect(x: x, y: 0, width: width, height: NSTouchBar.size.height))

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationViewDidChangeWidth),
                name: .touchBarApplicationViewDidChangeWidth,
                object: nil
            )
        }

        required init?(coder: NSCoder) { fatalError() }


        @objc
        private func applicationViewDidChangeWidth() {
            application?.updateContentsToMatchWidth(animator().frame.width)
        }

        public func dimApplication() {
            guard application != nil else { return }

            isDimmed = true
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                application?.animator().alphaValue = 0.5
            }
        }

        public func makeApplicationActive() {
            NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                application?.animator().alphaValue = 1
            }, completionHandler: {
                self.isDimmed = false
            })
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
            NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                application?.animator().alphaValue = 0
            }, completionHandler: callback)
        }

        private func showApplication(completionHandler callback: @escaping () -> Void = {}) {
            NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                application?.animator().alphaValue = 1
            }, completionHandler: callback)
        }

        public func runApplication(_ application: Application) {
            application.alphaValue = 0

            if self.application != nil {
                terminateApplication {
                    self.application = application
                    self.application?.frame.size = self.frame.size
                    self.applicationViewDidChangeWidth()

                    self.addSubview(self.application!)

                    self.showApplication()
                }
            } else {
                self.application = application
                self.application?.frame.size = self.frame.size
                applicationViewDidChangeWidth()

                addSubview(self.application!)

                showApplication()
            }

            makeApplicationActive()
        }

        public func terminateApplication(completionHandler callback: @escaping () -> Void = {}) {
            guard application != nil else { return }

            hideApplication {
                self.application?.applicationWillTerminate()
                NotificationCenter.default.post(
                    name: .touchBarApplicationWillTerminate,
                    object: nil
                )

                self.application?.removeFromSuperview()
                self.application = nil
                NotificationCenter.default.post(
                    name: .touchBarApplicationDidTerminate,
                    object: nil
                )
                callback()
            }
        }
    }
}
