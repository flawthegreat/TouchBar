extension TouchBar {
    class Slider: Item {

        private let background: NSButton

        private let progressBarBackground = NSView(frame: NSRect(
            x: (TouchBar.buttonSize.width - TouchBar.size.height / 2) / 2,
            y: 13,
            width: 0,
            height: 4
        ))

        private let progressBar = NSView(frame: NSRect(origin: .zero, size: CGSize(width: 0, height: 4)))

        private let knob = NSView(frame: NSRect(
            x: (TouchBar.buttonSize.width - TouchBar.size.height) / 2,
            y: 0,
            width: TouchBar.size.height,
            height: TouchBar.size.height
        ))

        let icon = NSImageView(frame: NSRect(origin: .zero, size: TouchBar.buttonSize))

        private var touchX: CGFloat?
        private var knobX: CGFloat?

        private let knobTravelWidth: CGFloat = 200
        private let width: CGFloat
        private let timeDelta: Double

        private var timer: Timer?

        var value: Double
        private var previousValue: Double?

        var target: Slider?
        var action: Selector?


        init(alignment: Alignment, value: Double = 0) {
            self.value = value

            width = knobTravelWidth + TouchBar.buttonSize.width * 1.5 + TouchBar.size.height / 2
            timeDelta = Double(TouchBar.buttonSize.width / width)

            background = NSButton(frame: NSRect(origin: .zero, size: CGSize(width: width, height: TouchBar.size.height)))

            super.init(alignment: alignment, width: TouchBar.buttonSize.width)

            wantsLayer = true
            layer?.cornerRadius = 6
            layer?.cornerCurve = .continuous

            background.bezelStyle = .rounded
            background.title = ""

            progressBarBackground.wantsLayer = true
            progressBarBackground.layer?.backgroundColor = NSColor.gray.cgColor
            progressBarBackground.layer?.cornerRadius = 2
            progressBarBackground.alphaValue = 0

            progressBar.wantsLayer = true
            progressBar.layer?.backgroundColor = NSColor.systemBlue.cgColor

            progressBarBackground.addSubview(progressBar)

            knob.wantsLayer = true
            knob.layer?.backgroundColor = .white
            knob.layer?.cornerRadius = 6
            knob.layer?.cornerCurve = .continuous
            knob.layer?.borderWidth = 1
            knob.alphaValue = 0

            addSubview(background)
            addSubview(progressBarBackground)
            addSubview(knob)
            addSubview(icon)
        }

        required init?(coder: NSCoder) { fatalError() }


        override final func touchesBegan(with event: NSEvent) {
            guard let superview = self.superview else { return }

            removeFromSuperview()

            NSView.animate(withDuration: TouchBar.animationDuration * 0.75) { _ in
                superview.subviews.forEach { $0.animator().alphaValue = 0 }
            }

            superview.addSubview(self)

            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x

            timer?.invalidate()
            timer = nil

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                animator().frame.size.width = width
                icon.animator().frame.origin.x = width - TouchBar.buttonSize.width

                progressBarBackground.animator().alphaValue = 1
                progressBarBackground.animator().frame.size.width = knobTravelWidth + TouchBar.size.height / 2

                let offset = CGFloat(value) * (knobTravelWidth + TouchBar.size.height / 2)
                progressBar.frame.size.width = offset

                knob.animator().alphaValue = 1
                knobX = (TouchBar.buttonSize.width - TouchBar.size.height) / 2 + CGFloat(value) * knobTravelWidth
                knob.animator().frame.origin.x = knobX!
            }

            previousValue = value
        }

        override final func touchesMoved(with event: NSEvent) {
            guard
                previousValue != nil,
                let touchX = touchX,
                let knobX = knobX,
                let x = event.touches(matching: .moved, in: self).first?.location(in: self).x
            else { return }

            let offset = x - touchX
            knob.frame.origin.x = min(
                (TouchBar.buttonSize.width - TouchBar.size.height) / 2 + knobTravelWidth,
                max((TouchBar.buttonSize.width - TouchBar.size.height) / 2, offset + knobX)
            )

            let path = Double((knob.frame.origin.x - (TouchBar.buttonSize.width - TouchBar.size.height) / 2))
            value = path / Double(knobTravelWidth)

            progressBar.frame.size.width = CGFloat(value) * (knobTravelWidth + TouchBar.size.height / 2)

            if previousValue != value { target?.perform(action) }
            previousValue = value
        }

        func hide() {
            guard let superview = self.superview else { return }

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                superview.subviews.forEach { $0.animator().alphaValue = 1 }
            }

            touchX = nil
            knobX = nil
            previousValue = nil

            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                animator().frame.size.width = TouchBar.buttonSize.width
                icon.animator().frame.origin.x = 0
            }

            NSView.animate(withDuration: TouchBar.animationDuration - timeDelta) { _ in
                progressBarBackground.animator().alphaValue = 0
                progressBarBackground.animator().frame.size.width = 0

                progressBar.animator().frame.size.width = 0

                knob.animator().alphaValue = 0
                knob.animator().frame.origin.x = (TouchBar.buttonSize.width - TouchBar.size.height) / 2
            }
        }

        override func touchesEnded(with event: NSEvent) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] _ in
                self.hide()
            })
        }
    }
}
