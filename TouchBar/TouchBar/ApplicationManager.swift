extension TouchBar {
    final class ApplicationManager: NSView {

        private let applicationSwitcher = NSScrollView(
            x: TouchBar.buttonSize.width + TouchBar.itemGap,
            width: TouchBar.size.width - (TouchBar.buttonSize.width + TouchBar.itemGap)
        )

        private let applicationView = NSView(
            x: TouchBar.buttonSize.width + TouchBar.itemGap,
            width: TouchBar.size.width - (TouchBar.buttonSize.width + TouchBar.itemGap)
        )

        override var frame: NSRect {
            didSet {
                applicationSwitcher.frame.size.width = frame.width - (TouchBar.buttonSize.width + TouchBar.itemGap)
                applicationView.frame.size.width = frame.width - (TouchBar.buttonSize.width + TouchBar.itemGap)
                activeApplication?.updateWidth()
            }
        }

        private let applicationSwitcherButton = NSButton(frame: NSRect(origin: .zero, size: TouchBar.buttonSize))
        private let terminateApplicationButton = NSButton(frame: NSRect(origin: .zero, size: TouchBar.buttonSize))

        private var isInApplicationSwitcher = false
        private(set) var isDimmed = false

        var applications = [Application]() {
            didSet {
                terminateApplication()
                closeApplicationSwitcher()

                for icon in applicationSwitcher.subviews where icon is Application.Icon { icon.removeFromSuperview() }

                applicationSwitcher.documentView?.frame.size.width = (TouchBar.applicationIconSize.width + TouchBar.itemGap) * CGFloat(applications.count) + terminateApplicationButton.frame.size.width

                for application in applications.reversed() {
                    applicationSwitcher.documentView?.addSubview(application.icon)
                    application.icon.target = self
                    application.icon.action = #selector(runApplication(_:))
                }
            }
        }

        var activeApplication: Application?


        init() {
            super.init(frame: NSRect(origin: .zero, size: CGSize(width: 0, height: TouchBar.size.height)))

            applicationSwitcher.documentView = NSView(frame: terminateApplicationButton.frame)
            applicationSwitcher.contentView.wantsLayer = true
            applicationSwitcher.contentView.layer?.cornerRadius = 6
            applicationSwitcher.contentView.layer?.cornerCurve = .continuous
            applicationSwitcher.wantsLayer = true
            applicationSwitcher.layer?.backgroundColor = .black
            applicationSwitcher.alphaValue = 0

            applicationSwitcherButton.bezelStyle = .rounded
            applicationSwitcherButton.font = .systemFont(ofSize: TouchBar.fontSize)
            applicationSwitcherButton.image = NSImage(named: "ApplicationSwitcherIcon")
            applicationSwitcherButton.target = self
            applicationSwitcherButton.action = #selector(toggleApplicationSwitcher)

            terminateApplicationButton.bezelStyle = .rounded
            terminateApplicationButton.font = .systemFont(ofSize: TouchBar.fontSize)
            terminateApplicationButton.title = "􀆄"
            terminateApplicationButton.target = self
            terminateApplicationButton.action = #selector(terminateApplicationButtonPressed)

            applicationSwitcher.documentView?.addSubview(terminateApplicationButton)

            addSubview(applicationView)
            addSubview(applicationSwitcher)
            addSubview(applicationSwitcherButton)
        }

        required init?(coder: NSCoder) { fatalError() }


        private func openApplicationSwitcher() {
            isInApplicationSwitcher = true

            applicationSwitcher.frame.origin.y = 0
            applicationSwitcher.documentView?.scroll(.zero)

            removeTint()

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                applicationSwitcher.animator().alphaValue = 1
                applicationView.animator().alphaValue = 0
                applicationView.animator().frame.origin.x = frame.width

                var applicationCount: CGFloat = 0
                for application in applications {
                    application.icon.animator().frame.origin.x = (TouchBar.applicationIconSize.width + TouchBar.itemGap) * applicationCount + terminateApplicationButton.frame.width + TouchBar.itemGap
                    applicationCount += 1
                }
            }
        }

        private func closeApplicationSwitcher() {
            isInApplicationSwitcher = false

            NSView.animate(withDuration: TouchBar.animationDuration, changes: { _ in
                applicationSwitcher.animator().alphaValue = 0
                applicationView.animator().alphaValue = isDimmed ? 0.5 : 1
                applicationView.animator().frame.origin.x = TouchBar.buttonSize.width + TouchBar.itemGap
                
                applications.forEach { $0.icon.animator().frame.origin.x = 0 }
            }, completionHandler: { [unowned self] in
                if !self.isInApplicationSwitcher { self.applicationSwitcher.frame.origin.y = -TouchBar.size.height }
            })
        }

        @objc
        private func toggleApplicationSwitcher() {
            if isInApplicationSwitcher { closeApplicationSwitcher() }
            else { openApplicationSwitcher() }
        }

        @objc
        private func runApplication(_ sender: Application.Icon) {
            terminateApplication()

            sender.application.createInstance(width: applicationView.frame.width)
            applicationView.addSubview(sender.application.view!)
            activeApplication = sender.application

            removeTint()

            NSView.animate(withDuration: 0, changes: { _ in
                applicationView.frame.origin.y = 0
            }, completionHandler: { [unowned self] in
                self.closeApplicationSwitcher()
            })
        }

        private func terminateApplication() {
            applicationView.frame.origin.y = -TouchBar.size.height

            activeApplication?.applicationWillTerminate()
            activeApplication?.removeInstance()
            activeApplication = nil
        }

        @objc
        private func terminateApplicationButtonPressed() {
            terminateApplication()
            closeApplicationSwitcher()
        }

        func addTint() {
            guard activeApplication != nil else { return }

            isDimmed = true

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                applicationView.animator().alphaValue = 0.5
            }
        }

        func removeTint() {
            NSApplication.shared.activate(ignoringOtherApps: true)
            isDimmed = false

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                applicationView.animator().alphaValue = 1
            }
        }

        override func hitTest(_ point: NSPoint) -> NSView? {
            guard
                isDimmed &&
                !isInApplicationSwitcher &&
                point.x >= applicationView.frame.origin.x + frame.origin.x
            else { return super.hitTest(point) }

            removeTint()

            return nil
        }
    }
}
