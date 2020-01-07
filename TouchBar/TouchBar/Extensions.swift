extension NSTouchBarItem.Identifier {
    static let controlStripItem = Self("com.flaw.controlStripItem")
    static let viewItem = Self("com.flaw.viewItem")
}

extension Notification.Name {
    static let defaultAudioOutputDeviceHasChanged = Self("defaultAudioOutputDeviceHasChanged")
    static let volumeLevelHasChanged = Self("volumeLevelHasChanged")
}

extension NSTouchBar {
    func controlStripSetVisible(_ visible: Bool) {
        NSTouchBar.minimizeSystemModalTouchBar(self)
        NSTouchBar.presentSystemModalTouchBar(
            self,
            placement: visible ? 0 : 1,
            systemTrayItemIdentifier: .controlStripItem
        )
    }
}

extension TouchBar {
    static let swipeThreshold: CGFloat = 20

    static let animationDuration: TimeInterval = 0.2// * 10

    static let size = NSSize(width: 1085, height: 30)
    static let buttonSize = NSSize(width: 72, height: 30)
    static let applicationIconSize = NSSize(width: 90, height: 30)
    static let itemGap: CGFloat = 10

    static let fontSize: CGFloat = 15
}

extension NSCustomTouchBarItem {
    convenience init(identifier: Identifier, view: NSView) {
        self.init(identifier: identifier)
        self.view = view
    }
}
