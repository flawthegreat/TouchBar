extension TouchBar {
    final class View: NSView {

        private var touchX: CGFloat?
        private var offset = HorizontalOffset.zero

        let applicationManager = ApplicationManager()


        init() {
            super.init(frame: NSRect(origin: .zero, size: NSTouchBar.size))

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateLayout(animated:)),
                name: .touchBarItemWillChangeWidth
            )

            addSubview(applicationManager)
        }

        required init?(coder: NSCoder) { fatalError() }


        func replaceItems(with items: [Item]) {
            for item in subviews where item is Item { item.removeFromSuperview() }
            items.forEach { addItem($0) }
        }

        private func updateApplicationViewWidth(animated: Bool = false) {
            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                applicationManager.animator().frame.origin.x = offset.left
                applicationManager.animator().frame.size.width = NSTouchBar.size.width - offset.right - offset.left
            }

            applicationManager.updateContentsToMatchWidth(animated: animated)
        }

        private func alignItem(_ item: Item, animated: Bool = false) {
            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                if item.alignment == .left {
                    item.animator().frame.origin.x = offset.left
                    offset.left += item.frame.width + NSTouchBar.itemGap
                } else if item.alignment == .right {
                    item.animator().frame.origin.x = NSTouchBar.size.width - item.frame.width - offset.right
                    offset.right += item.frame.width + NSTouchBar.itemGap
                }
            }
        }

        @objc
        func updateLayout(animated: Bool = false) {
            offset = .zero
            for case let item as Item in subviews { alignItem(item, animated: animated) }
            updateApplicationViewWidth(animated: animated)
        }

        func addItem(_ item: Item) {
            alignItem(item)
            updateApplicationViewWidth()
            addSubview(item)
        }

        override func touchesBegan(with event: NSEvent) {
            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x
        }

        override func touchesEnded(with event: NSEvent) {
            guard
                let touchX = touchX,
                let x = event.touches(matching: .ended, in: self).first?.location(in: self).x
            else { return }

            if touchX > NSTouchBar.size.width - 100 && touchX - x > Constants.swipeThreshold { TouchBar.shared.hide() }
            self.touchX = nil
        }
    }
}
