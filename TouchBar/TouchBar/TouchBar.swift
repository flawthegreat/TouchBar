final class TouchBar: NSObject, NSTouchBarDelegate {

    static let shared = TouchBar()
    
    private let touchBar = NSTouchBar()
    private let view = View()
    private var isVisible = false

    var items = [Item]() { didSet { view.items = items } }
    var applications = [Application]() { didSet { view.applicationManager.applications = applications } }


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
                NSWorkspace.didHideApplicationNotification,
                NSWorkspace.didUnhideApplicationNotification,
                NSWorkspace.didDeactivateApplicationNotification,
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
        touchBar.controlStripSetVisible(true)
        NSTouchBar.minimizeSystemModalTouchBar(touchBar)

        isVisible = false
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

    func touchBar(_: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .viewItem: return NSCustomTouchBarItem(identifier: .viewItem, view: view)
        default: return nil
        }
    }
}
