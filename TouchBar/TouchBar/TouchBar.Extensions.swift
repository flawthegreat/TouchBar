import Foundation

extension NSTouchBarItem.Identifier {
    static let controlStripItem = NSTouchBarItem.Identifier("com.flaw.controlStripItem")
    static let viewItem = NSTouchBarItem.Identifier("com.flaw.viewItem")
}

public extension NSTouchBar {
    static let size: NSSize = NSSize(width: 1085.0, height: 30.0)
    static let itemGap: CGFloat = 10.0
    static let fontSize: CGFloat = 15.0
    static let buttonWidth: CGFloat = 72.0
    static let sliderWidth: CGFloat = 200.0

    func controlStripSetVisible(_ visible: Bool) {
        NSTouchBar.minimizeSystemModalTouchBar(self)
        NSTouchBar.presentSystemModalTouchBar(
            self,
            placement: visible ? 0 : 1,
            systemTrayItemIdentifier: .controlStripItem
        )
    }
}

public extension NSCustomTouchBarItem {
    convenience init(identifier: Identifier, view: NSView) {
        self.init(identifier: identifier)
        self.view = view
    }
}

public extension Notification {
    static let touchBarItemWidthDidChange = Notification.Name("touchBarItemWidthDidChange")
    static let touchBarApplicationViewDidChangeWidth = Notification.Name(
        "touchBarApplicationViewDidChangeWidth"
    )
    static let touchBarApplicationDidChangeWidth = Notification.Name(
        "touchBarApplicationDidChangeWidth"
    )
}
