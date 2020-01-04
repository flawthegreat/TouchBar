class TouchBar: NSObject, NSTouchBarDelegate {

    static let shared = TouchBar()
    
    private let touchBar = NSTouchBar()
    private let view = View()
    private var isVisible = false
    private var frontmostApplicationBundleIdentifier: String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    var items: [Item] = [] { didSet { view.replaceItems(with: items) } }


    private override init() {
        super.init()

        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.viewItem]

        view.setSwipeAction(#selector(hide), target: self)

        NSTouchBarItem.addSystemTrayItem(ControlStripItem(target: self, action: #selector(show)))
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeApplicationDidChange),
            names: [
                NSWorkspace.didLaunchApplicationNotification,
                NSWorkspace.didTerminateApplicationNotification,
                NSWorkspace.didActivateApplicationNotification,
            ],
            object: nil
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
        if frontmostApplicationBundleIdentifier != Bundle.main.bundleIdentifier {
//            dimApplication()
        } else if !isVisible {
            reloadControlStripButton()
        }
    }

    func hideAllItems(except excludedItem: Item) {
        NSView.animate(withDuration: Constants.animationDuration) { _ in
            for item in items where item != excludedItem { item.animator().alphaValue = 0 }
            view.applicationView.animator().alphaValue = 0
        }
    }

    func showAllItems() {
        NSView.animate(withDuration: Constants.animationDuration) { _ in
            items.forEach { $0.animator().alphaValue = 1 }
            view.applicationView.animator().alphaValue = 1
        }
    }

    func touchBar(_: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .viewItem:
            return NSCustomTouchBarItem(identifier: .viewItem, view: view)
        default:
            return nil
        }
    }
}
