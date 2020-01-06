extension TouchBar {
    final class View: NSView {

        private var touchX: CGFloat?

        private(set) var applicationManager = ApplicationManager()

        var items = [Item]() {
            didSet {
                for subview in subviews where subview != applicationManager { subview.removeFromSuperview() }

                var offset = HorizontalOffset.zero
                for item in items {
                    if item.alignment == .left {
                        item.animator().frame.origin.x = offset.left
                        offset.left += item.frame.width + TouchBar.itemGap
                    } else if item.alignment == .right {
                        item.animator().frame.origin.x = TouchBar.size.width - item.frame.width - offset.right
                        offset.right += item.frame.width + TouchBar.itemGap
                    }

                    addSubview(item)
                }

                applicationManager.frame.origin.x = offset.left
                applicationManager.frame.size.width = TouchBar.size.width - offset.left - offset.right
            }
        }


        init() {
            super.init(frame: NSRect(origin: .zero, size: TouchBar.size))

            addSubview(applicationManager)
        }

        required init?(coder: NSCoder) { fatalError() }


        override func touchesBegan(with event: NSEvent) {
            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x
        }

        override func touchesEnded(with event: NSEvent) {
            guard
                let touchX = touchX,
                let x = event.touches(matching: .ended, in: self).first?.location(in: self).x
            else { return }

            if touchX > TouchBar.size.width - 100 && touchX - x > TouchBar.swipeThreshold { TouchBar.shared.hide() }
            self.touchX = nil
        }
    }
}
