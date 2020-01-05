extension TouchBar {
    final class ApplicationManager: NSView {

        private let appSwitcher = NSScrollView(frame: NSRect(origin: CGPoint(x: -NSTouchBar.size.width, y: 0), size: NSTouchBar.size))
        private let closeAppButton = NSButton(frame: NSRect(origin: .zero, size: NSTouchBar.buttonSize))
        private let appView = NSView(frame: NSRect(origin: .zero, size: NSTouchBar.size))
        private let defaultApplication = 0

        private(set) var isDimmed = false

        var applications = [Application]() {
            didSet {
                for card in appSwitcher.subviews where card is Application.Card { card.removeFromSuperview() }

                appSwitcher.documentView?.frame.size.width = (NSTouchBar.cardSize.width + NSTouchBar.itemGap) * CGFloat(applications.count) + closeAppButton.frame.size.width

                for application in applications.reversed() {
                    appSwitcher.documentView?.addSubview(application.card)
                }
            }
        }

        var activeApplication: Application?


        init() {
            super.init(frame: NSRect(origin: .zero, size: NSTouchBar.size))

            appSwitcher.documentView = NSView(frame: closeAppButton.frame)
            appSwitcher.contentView.wantsLayer = true
            appSwitcher.contentView.layer?.cornerRadius = 6
            appSwitcher.contentView.layer?.cornerCurve = .continuous
            appSwitcher.wantsLayer = true
            appSwitcher.layer?.backgroundColor = .black
            appSwitcher.alphaValue = 0

            closeAppButton.bezelStyle = .rounded
            closeAppButton.font = .systemFont(ofSize: NSTouchBar.fontSize)
            closeAppButton.title = "􀆄"
            closeAppButton.target = self
            closeAppButton.action = #selector(closeAppButtonPressed)

            appSwitcher.documentView?.addSubview(closeAppButton)

            addSubview(appView)
            addSubview(appSwitcher)
        }

        required init?(coder: NSCoder) { fatalError() }


        func openAppSwitcher() {
            appSwitcher.documentView?.scroll(.zero)

            removeTint()

            appSwitcher.frame.origin.x = 0

            NSView.animate(withDuration: Constants.animationDuration) { _ in
                appSwitcher.animator().alphaValue = 1

                var appCount: CGFloat = 0
                for application in applications {
                    application.card.animator().frame.origin.x = (NSTouchBar.cardSize.width + NSTouchBar.itemGap) * appCount + closeAppButton.frame.width + NSTouchBar.itemGap
                    appCount += 1
                }
            }
        }

        func hideAppSwitcher() {
            NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                appSwitcher.animator().alphaValue = 0
                applications.forEach { $0.card.animator().frame.origin.x = 0 }
            }, completionHandler: {
                self.appSwitcher.animator().frame.origin.x = -self.appSwitcher.animator().frame.width
            })
        }

        func toggleAppSwitcher() {
            if appSwitcher.frame.origin.x == 0 { hideAppSwitcher() }
            else { openAppSwitcher() }
        }

        func runApplication(_ application: Application) {
            terminateApplication()

            application.createView(frame: appView.bounds)
            appView.addSubview(application.view!)
            activeApplication = application

            removeTint()

            hideAppSwitcher()
        }

        private func terminateApplication() {
            guard activeApplication != nil else { return }

            activeApplication?.applicationWillTerminate()
            activeApplication?.removeView()
            activeApplication = nil
        }

        @objc
        private func closeAppButtonPressed() {
            terminateApplication()
            hideAppSwitcher()
        }

        func updateContentsToMatchWidth(animated: Bool = false) {
            if appSwitcher.frame.origin.x != 0 { appSwitcher.frame.origin.x = -frame.width }

            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                appSwitcher.animator().frame.size = frame.size
                appView.animator().frame.size = frame.size
            }
            
            activeApplication?.updateWidth(frame.size.width, animated: animated)
        }

        func addTint() {
            guard activeApplication != nil else { return }

            isDimmed = true

            NSView.animate(withDuration: Constants.animationDuration) { _ in
                appView.animator().alphaValue = 0.5
            }
        }

        func removeTint() {
            NSApplication.shared.activate(ignoringOtherApps: true)
            isDimmed = false

            NSView.animate(withDuration: Constants.animationDuration) { _ in
                appView.animator().alphaValue = 1
            }
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            guard isDimmed && appSwitcher.frame.origin.x != 0 else { return super.hitTest(point) }

            removeTint()

            return nil
        }
    }
}
