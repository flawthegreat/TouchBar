extension NSTouchBarItem.Identifier {
    static let controlStripItem = Self("com.flaw.controlStripItem")
    static let viewItem = Self("com.flaw.viewItem")
}

extension NSTouchBar {
    static let size = NSSize(width: 1085, height: 30)
    static let buttonSize = NSSize(width: 72, height: 30)
    static let cardSize = NSSize(width: 100, height: 30)
    static let itemGap: CGFloat = 10
    static let fontSize: CGFloat = 15
    static let sliderWidth: CGFloat = 200

    func controlStripSetVisible(_ visible: Bool) {
        NSTouchBar.minimizeSystemModalTouchBar(self)
        NSTouchBar.presentSystemModalTouchBar(
            self,
            placement: visible ? 0 : 1,
            systemTrayItemIdentifier: .controlStripItem
        )
    }
}

extension NSCustomTouchBarItem {
    convenience init(identifier: Identifier, view: NSView) {
        self.init(identifier: identifier)
        self.view = view
    }
}
