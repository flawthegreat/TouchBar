extension TouchBar {
    class Button: Item {

        private let button = NSButton(frame: NSRect(
            origin: .zero,
            size: CGSize(width: NSTouchBar.buttonWidth, height: NSTouchBar.size.height)
        ))

        private let leftArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: 0, y: 1),
            size: CGSize(width: NSTouchBar.buttonWidth * 0.25, height: NSTouchBar.size.height)
        ))

        private let rightArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: NSTouchBar.buttonWidth * 0.75, y: 1),
            size: CGSize(width: NSTouchBar.buttonWidth * 0.25, height: NSTouchBar.size.height)
        ))

        private var touchX: CGFloat?

        var title: String {
            get { button.title }
            set { button.title = newValue }
        }

        var image: NSImage? {
            get { button.image }
            set { button.image = newValue }
        }

        var target: Item?
        var action: Selector?
        var swipeLeftAction: Selector?
        var swipeRightAction: Selector?


        init(alignment: Alignment) {
            super.init(alignment: alignment, width: NSTouchBar.buttonWidth)

            leftArrow.textColor = .white
            leftArrow.font = .systemFont(ofSize: 18)
            leftArrow.stringValue = "􀆒"
            leftArrow.alphaValue = 0

            rightArrow.textColor = .white
            rightArrow.font = .systemFont(ofSize: 18)
            rightArrow.stringValue = "􀆓"
            rightArrow.alphaValue = 0

            button.bezelStyle = .rounded
            button.font = .systemFont(ofSize: NSTouchBar.fontSize)
            button.title = ""

            button.addSubview(leftArrow)
            button.addSubview(rightArrow)

            addSubview(button)
        }

        required init?(coder: NSCoder) { fatalError() }


        override func touchesBegan(with event: NSEvent) {
            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x
        }

        override func touchesEnded(with event: NSEvent) {
            guard
                touchX != nil,
                let x = event.touches(matching: .ended, in: self).first?.location(in: self).x
            else { return }

            if x - touchX! > Constants.swipeThreshold && swipeRightAction != nil {
                target?.perform(swipeRightAction)
                NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                    rightArrow.animator().alphaValue = 1
                }, completionHandler: {
                    NSView.animate(withDuration: Constants.animationDuration) { _ in
                        self.rightArrow.animator().alphaValue = 0
                    }
                })
            } else if touchX! - x > Constants.swipeThreshold && swipeLeftAction != nil {
                target?.perform(swipeLeftAction)
                NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                    leftArrow.animator().alphaValue = 1
                }, completionHandler: {
                    NSView.animate(withDuration: Constants.animationDuration) { _ in
                        self.leftArrow.animator().alphaValue = 0
                    }
                })
            } else if abs(touchX! - x) < Constants.swipeThreshold / 2 ||
                swipeLeftAction == nil && swipeRightAction == nil
            {
                target?.perform(action)
            }
        }
    }
}
