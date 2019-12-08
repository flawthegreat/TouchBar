import Foundation

class TouchBar: NSObject, NSTouchBarDelegate {

    static let shared = TouchBar()
    
    private let touchBar: NSTouchBar
    private var isVisible: Bool
    private let view: View
    private var frontmostApplicationBundleIdentifier: String? {
        return NSWorkspace.shared.frontmostApplication?.bundleIdentifier
    }

    public var items: [Item] { didSet { view.replaceItems(with: items) } }
    public var runningApplication: Application? { return view.applicationView.application }


    private override init() {
        touchBar = NSTouchBar()
        isVisible = false
        view = View()
        items = []

        super.init()

        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.viewItem]

        view.setSwipeAction(#selector(hide), target: self)

        NSTouchBarItem.addSystemTrayItem(ControlStripItem(
            target: self,
            action: #selector(show)
        ))

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


    public func runApplication(_ application: Application) {
        view.applicationView.runApplication(application)
    }

    public func terminateApplication() {
        view.applicationView.terminateApplication()
    }

    public func dimApplication() {
        view.applicationView.dimApplication()
    }

    @objc
    private func activeApplicationDidChange() {
        if frontmostApplicationBundleIdentifier != Bundle.main.bundleIdentifier {
            dimApplication()
        } else if !isVisible {
            reloadControlStripButton()
        }
    }

    @objc
    public func show() {
        items.forEach { $0.update() }

        touchBar.controlStripSetVisible(false)
        NSTouchBar.presentSystemModalTouchBar(
            touchBar,
            systemTrayItemIdentifier: .controlStripItem
        )

        isVisible = true
    }

    @objc
    public func hide() {
        isVisible = false

        touchBar.controlStripSetVisible(true)
        NSTouchBar.minimizeSystemModalTouchBar(touchBar)
    }

    public func reloadControlStripButton() {
        DFRElementSetControlStripPresenceForIdentifier(.controlStripItem, true)
    }

    func touchBar(
        _: NSTouchBar,
        makeItemForIdentifier identifier: NSTouchBarItem.Identifier
    ) -> NSTouchBarItem? {
        switch identifier {
        case .viewItem: return NSCustomTouchBarItem(identifier: .viewItem, view: view)
        case .controlStripItem: return ControlStripItem(target: self, action: #selector(show))
        default: return nil
        }
    }
}
