extension TouchBar {
    class Button: Item {

        private let button = NSButton(frame: NSRect(origin: .zero, size: TouchBar.buttonSize))

        private let leftArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: 0, y: 1),
            size: CGSize(width: TouchBar.buttonSize.width * 0.25, height: TouchBar.size.height)
        ))

        private let rightArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: TouchBar.buttonSize.width * 0.75, y: 1),
            size: CGSize(width: TouchBar.buttonSize.width * 0.25, height: TouchBar.size.height)
        ))

        var title: String {
            get { button.title }
            set { button.title = newValue }
        }

        var image: NSImage? {
            get { button.image }
            set { button.image = newValue }
        }

        private var currentAction: (() -> Void)?
        private var actionTimer: Timer?

        var target: AnyObject?
        var middleAction: Selector?
        var leftAction: Selector?
        var rightAction: Selector?


        init(alignment: Alignment) {
            super.init(alignment: alignment, width: TouchBar.buttonSize.width)

            leftArrow.textColor = .white
            leftArrow.font = .systemFont(ofSize: 18)
            leftArrow.stringValue = "􀆒"
            leftArrow.alphaValue = 0

            rightArrow.textColor = .white
            rightArrow.font = .systemFont(ofSize: 18)
            rightArrow.stringValue = "􀆓"
            rightArrow.alphaValue = 0

            button.bezelStyle = .rounded
            button.font = .systemFont(ofSize: TouchBar.fontSize)
            button.title = ""

            button.addSubview(leftArrow)
            button.addSubview(rightArrow)

            addSubview(button)
        }

        required init?(coder: NSCoder) { fatalError() }


        override final func touchesBegan(with event: NSEvent) {
            guard let x = event.touches(matching: .began, in: self).first?.location(in: self).x
            else { return }

            if x > frame.width * 2 / 3 && x <= frame.width && rightAction != nil {
                currentAction = { [unowned self] in
                    _ = self.target?.perform(self.rightAction)
                    self.rightArrow.flash()
                }
            } else if x < frame.width / 3 && x >= 0 && leftAction != nil {
                currentAction = { [unowned self] in
                    _ = self.target?.perform(self.leftAction)
                    self.leftArrow.flash()
                }
            } else {
                currentAction = nil
                _ = target?.perform(middleAction)
                return
            }

            currentAction?()
            actionTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in self.currentAction?() }
        }

        override final func touchesMoved(with event: NSEvent) {
            guard
                currentAction != nil,
                let x = event.touches(matching: .moved, in: self).first?.location(in: self).x
            else { return }

            if x >= frame.width / 2 && rightAction != nil {
                currentAction = { [unowned self] in
                    _ = self.target?.perform(self.rightAction)
                    self.rightArrow.flash()
                }
            } else if x < frame.width / 2 && leftAction != nil {
                currentAction = { [unowned self] in
                    _ = self.target?.perform(self.leftAction)
                    self.leftArrow.flash()
                }
            }
        }

        override final func touchesEnded(with event: NSEvent) {
            actionTimer?.invalidate()
            actionTimer = nil
            currentAction = nil
        }
    }
}
