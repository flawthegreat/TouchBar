import Foundation

extension TouchBar {
    public class View: NSView {

        private let swipeLeftBound: CGFloat

        private var target: TouchBar?
        private var action: Selector?
        private var touchX: CGFloat?

        private var offset: Offset

        public let applicationView: ApplicationView


        init() {
            swipeLeftBound = NSTouchBar.size.width - 100.0

            applicationView = ApplicationView(x: 0, width: NSTouchBar.size.width)

            target = nil
            action = nil
            touchX = nil

            offset = Offset()

            super.init(frame: NSRect(origin: .zero, size: NSTouchBar.size))

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateLayout(animated:)),
                name: Notification.touchBarItemWidthDidChange,
                object: nil
            )

            addSubview(applicationView)
        }

        required init?(coder: NSCoder) { fatalError() }


        private func updateApplicationViewWidth(animated: Bool = false) {
            NSView.animate(withDuration: animated ? animationDuration : 0) { _ in
                applicationView.animator().frame.origin.x = offset.left + NSTouchBar.itemGap
                applicationView.animator().frame.size.width = max(
                    0.0,
                    NSTouchBar.size.width - offset.right - offset.left - 2 * NSTouchBar.itemGap
                )
            }

            NotificationCenter.default.post(
                name: Notification.touchBarApplicationViewDidChangeWidth,
                object: nil
            )
        }

        @objc
        public func updateLayout(animated: Bool = false) {
            NSView.animate(withDuration: animated ? animationDuration : 0) { _ in
                offset = Offset()

                for case let item as Item in subviews{
                    if item.alignment == .left {
                        item.animator().frame.origin.x = offset.left
                        offset.left += item.animator().frame.width + NSTouchBar.itemGap
                    } else {
                        item.animator().frame.origin.x = NSTouchBar.size.width - item.animator().frame.width - offset.right
                        offset.right += item.animator().frame.width + NSTouchBar.itemGap
                    }
                }

                updateApplicationViewWidth(animated: animated)
            }
        }

        public func replaceItems(with items: [Item]) {
            for item in subviews where item is Item { item.removeFromSuperview() }
            for item in items { addItem(item) }
        }

        public func addItem(_ item: Item) {
            guard offset.left + item.frame.width + offset.right - NSTouchBar.itemGap <=
                  NSTouchBar.size.width
            else { return }

            if item.alignment == .left {
                item.frame.origin.x = offset.left
                offset.left += item.frame.width + NSTouchBar.itemGap
            } else {
                item.frame.origin.x = NSTouchBar.size.width - item.frame.width - offset.right
                offset.right += item.frame.width + NSTouchBar.itemGap
            }

            addSubview(item)
            updateApplicationViewWidth()
        }

        public func setSwipeAction(target: TouchBar?, action: Selector?) {
            self.target = target
            self.action = action
        }

        override func touchesBegan(with event: NSEvent) {
            guard target != nil && action != nil else { return }

            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x
        }

        override func touchesEnded(with event: NSEvent) {
            guard target != nil && action != nil && touchX != nil else { return }

            guard let x = event.touches(matching: .ended, in: self).first?.location(in: self).x
            else { return }

            if touchX! > swipeLeftBound && touchX! - x > swipeThreshold { target?.perform(action) }
            touchX = nil
        }
    }
}
