extension TouchBar {
    class View: NSView {

        private static let swipeLeftBound = NSTouchBar.size.width - 100

        private weak var target: TouchBar?
        private var swipeAction: Selector?
        private var touchX: CGFloat?
        private var offset = HorizontalOffset.zero

        let applicationView = ApplicationView(x: 0, width: NSTouchBar.size.width)


        init() {
            super.init(frame: NSRect(origin: .zero, size: NSTouchBar.size))

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateLayout(animated:)),
                name: .touchBarItemWillChangeWidth,
                object: nil
            )

            addSubview(applicationView)
        }

        required init?(coder: NSCoder) { fatalError() }


        private func updateApplicationViewWidth(animated: Bool = false) {
            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                applicationView.animator().frame.origin.x = offset.left + NSTouchBar.itemGap
                applicationView.animator().frame.size.width = max(
                    0,
                    NSTouchBar.size.width - offset.right - offset.left - 2 * NSTouchBar.itemGap
                )
            }

            NotificationCenter.default.post(
                name: .touchBarApplicationViewDidChangeWidth,
                object: nil
            )
        }

        @objc
        func updateLayout(animated: Bool = false) {
            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                offset = .zero

                for case let item as Item in subviews {
                    if item.alignment == .left {
                        item.animator().frame.origin.x = offset.left
                        offset.left += item.animator().frame.width + NSTouchBar.itemGap
                    } else if item.alignment == .right {
                        item.animator().frame.origin.x = NSTouchBar.size.width - item.animator().frame.width - offset.right
                        offset.right += item.animator().frame.width + NSTouchBar.itemGap
                    }
                }

                updateApplicationViewWidth(animated: animated)
            }
        }

        func replaceItems(with items: [Item]) {
            for item in subviews where item is Item { item.removeFromSuperview() }
            items.forEach { addItem($0) }
        }

        func addItem(_ item: Item) {
            guard offset.left + item.frame.width + offset.right - NSTouchBar.itemGap <= NSTouchBar.size.width
            else { return }

            if item.alignment == .left {
                item.frame.origin.x = offset.left
                offset.left += item.frame.width + NSTouchBar.itemGap
            } else if item.alignment == .right {
                item.frame.origin.x = NSTouchBar.size.width - item.frame.width - offset.right
                offset.right += item.frame.width + NSTouchBar.itemGap
            }

            addSubview(item)
            updateApplicationViewWidth()
        }

        func setSwipeAction(_ action: Selector?, target: TouchBar?) {
            self.target = target
            self.swipeAction = action
        }

        override func touchesBegan(with event: NSEvent) {
            guard target != nil && swipeAction != nil else { return }

            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x
        }

        override func touchesEnded(with event: NSEvent) {
            guard
                target != nil && swipeAction != nil && touchX != nil,
                let x = event.touches(matching: .ended, in: self).first?.location(in: self).x
            else { return }

            if touchX! > Self.swipeLeftBound && touchX! - x > Constants.swipeThreshold {
                target?.perform(swipeAction)
            }
            touchX = nil
        }
    }
}
