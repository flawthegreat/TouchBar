extension TouchBar {
    class ApplicationView: NSView {

        private var isDimmed = false

        private(set) var application: Application?

        
        init(x: CGFloat, width: CGFloat) {
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
            application?.updateWidth(frame.width)
        }

        func dimApplication() {
            guard application != nil else { return }

            isDimmed = true
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                application?.animator().alphaValue = 0.5
            }
        }

        func makeApplicationActive() {
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

        func runApplication(_ application: Application) {
            application.alphaValue = 0

            let runApplication = {
                self.application = application
                self.application?.frame.size = self.frame.size
                self.applicationViewDidChangeWidth()

                self.addSubview(self.application!)

                self.showApplication()
            }

            if self.application != nil { terminateApplication(completionHandler: runApplication) }
            else { runApplication() }

            makeApplicationActive()
        }

        func terminateApplication(completionHandler callback: @escaping () -> Void = {}) {
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
