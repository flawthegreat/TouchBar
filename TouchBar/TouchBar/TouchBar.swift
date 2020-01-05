final class TouchBar: NSObject, NSTouchBarDelegate {

    static let shared = TouchBar()
    
    private let touchBar = NSTouchBar()
    private let view = View()
    private var isVisible = false

    var items = [Item]() { didSet { view.replaceItems(with: items) } }
    var applicationManager: ApplicationManager { view.applicationManager }
    var applications = [Application]() { didSet { view.applicationManager.applications = applications } }
    var activeApplication: Application? { view.applicationManager.activeApplication }


    private override init() {
        super.init()

        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.viewItem]

        NSTouchBarItem.addSystemTrayItem(ControlStripItem(target: self, action: #selector(show)))
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeApplicationDidChange),
            names: [
                NSWorkspace.didLaunchApplicationNotification,
                NSWorkspace.didTerminateApplicationNotification,
                NSWorkspace.didActivateApplicationNotification,
            ]
        )
    }


    @objc
    func show() {
        items.forEach { $0.update() }

        touchBar.controlStripSetVisible(false)
        NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: .controlStripItem)

        isVisible = true
    }

    @objc
    func hide() {
        isVisible = false

        touchBar.controlStripSetVisible(true)
        NSTouchBar.minimizeSystemModalTouchBar(touchBar)
    }

    func reloadControlStripButton() {
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)
    }

    @objc
    private func activeApplicationDidChange() {
        if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != Bundle.main.bundleIdentifier {
            view.applicationManager.addTint()
        } else if !isVisible {
            reloadControlStripButton()
        }
    }

    func hideAllItems(except visibleItem: Item? = nil) {
        NSView.animate(withDuration: Constants.animationDuration) { _ in
            for item in items where item != visibleItem { item.animator().alphaValue = 0 }
            view.applicationManager.animator().alphaValue = 0
        }
    }

    func showAllItems() {
        NSView.animate(withDuration: Constants.animationDuration) { _ in
            items.forEach { $0.animator().alphaValue = 1 }
            view.applicationManager.animator().alphaValue = 1
        }
    }

    func touchBar(_: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .viewItem: return NSCustomTouchBarItem(identifier: .viewItem, view: view)
        default: return nil
        }
    }
}
