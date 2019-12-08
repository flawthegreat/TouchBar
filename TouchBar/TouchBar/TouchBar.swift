class TouchBar: NSObject, NSTouchBarDelegate {

    static let shared = TouchBar()
    
    private let touchBar = NSTouchBar()
    private let view = View()
    private var isVisible = false
    private var frontmostApplicationBundleIdentifier: String? {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    var items: [Item] = [] { didSet { view.replaceItems(with: items) } }
    var runningApplication: Application? { view.applicationView.application }


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


    func runApplication(_ application: Application) {
        view.applicationView.runApplication(application)
    }

    func terminateApplication() {
        view.applicationView.terminateApplication()
    }

    func dimApplication() {
        view.applicationView.dimApplication()
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
            dimApplication()
        } else if !isVisible {
            reloadControlStripButton()
        }
    }

    func touchBar(
        _: NSTouchBar,
        makeItemForIdentifier identifier: NSTouchBarItem.Identifier
    ) -> NSTouchBarItem? {
        switch identifier {
        case .viewItem:
            return NSCustomTouchBarItem(identifier: .viewItem, view: view)
        default:
            return nil
        }
    }
}
