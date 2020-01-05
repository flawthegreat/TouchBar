extension TouchBar {
    class Button: Item {

        private let button = NSButton(frame: NSRect(origin: .zero, size: NSTouchBar.buttonSize))

        private let leftArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: 0, y: 1),
            size: CGSize(width: NSTouchBar.buttonSize.width * 0.25, height: NSTouchBar.size.height)
        ))

        private let rightArrow = NSTextField(frame: NSRect(
            origin: CGPoint(x: NSTouchBar.buttonSize.width * 0.75, y: 1),
            size: CGSize(width: NSTouchBar.buttonSize.width * 0.25, height: NSTouchBar.size.height)
        ))

        private var touchAction: (() -> Void)?
        private var timer: Timer?

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
        var leftAction: Selector?
        var rightAction: Selector?


        init(alignment: Alignment) {
            super.init(alignment: alignment, width: NSTouchBar.buttonSize.width)

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


        override final func touchesBegan(with event: NSEvent) {
            guard let x = event.touches(matching: .began, in: self).first?.location(in: self).x
            else { return }

            if x > NSTouchBar.buttonSize.width / 3 * 2 && x <= NSTouchBar.buttonSize.width && rightAction != nil {
                touchAction = { [unowned self] in
                    self.target?.perform(self.rightAction)
                    self.rightArrow.flash()
                }
            } else if x < NSTouchBar.buttonSize.width / 3 && x >= 0 && leftAction != nil {
                touchAction = { [unowned self] in
                    self.target?.perform(self.leftAction)
                    self.leftArrow.flash()
                }
            } else {
                target?.perform(action)
                return
            }

            touchAction?()

            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { _ in
                self.touchAction?()
            })
        }

        override final func touchesMoved(with event: NSEvent) {
            guard let x = event.touches(matching: .moved, in: self).first?.location(in: self).x
            else { return }

            if x >= NSTouchBar.buttonSize.width / 2 && x <= NSTouchBar.buttonSize.width && rightAction != nil {
                touchAction = { [unowned self] in
                    self.target?.perform(self.rightAction)
                    self.rightArrow.flash()
                }
            } else if x < NSTouchBar.buttonSize.width / 2 && x >= 0 && leftAction != nil {
                touchAction = { [unowned self] in
                    self.target?.perform(self.leftAction)
                    self.leftArrow.flash()
                }
            }
        }

        override final func touchesEnded(with event: NSEvent) {
            timer?.invalidate()
        }
    }
}
