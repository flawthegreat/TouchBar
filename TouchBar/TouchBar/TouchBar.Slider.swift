extension TouchBar {
    class Slider: Item {

        private let background = NSButton(frame: NSRect(
            origin: .zero,
            size: CGSize(width: NSTouchBar.buttonWidth, height: NSTouchBar.size.height)
        ))

        private let progressBarBackground = NSView(frame: NSRect(
            x: -NSTouchBar.sliderWidth,
            y: 13,
            width: NSTouchBar.sliderWidth - NSTouchBar.size.height / 2,
            height: 4
        ))

        private let progressBar = NSView(frame: NSRect(
            origin: .zero,
            size: CGSize(width: 0, height: 4)
        ))

        private let knob = NSView(frame: NSRect(
            x: -NSTouchBar.buttonWidth,
            y: 0,
            width: NSTouchBar.size.height,
            height: NSTouchBar.size.height
        ))

        private let widthDifference: CGFloat = (NSTouchBar.buttonWidth - NSTouchBar.size.height) / 2
        private var touchX: CGFloat?
        private var knobX: CGFloat?
        private var previousValue: CGFloat?


        let icon = NSImageView(frame: NSRect(
            origin: .zero,
            size: CGSize(width: NSTouchBar.buttonWidth, height: NSTouchBar.size.height)
        ))

        var value: CGFloat = 0
        var target: Slider?
        var action: Selector?

        
        init(alignment: Alignment) {
            super.init(alignment: alignment, width: NSTouchBar.buttonWidth)

            background.bezelStyle = .rounded
            background.title = ""

            progressBarBackground.wantsLayer = true
            progressBarBackground.layer?.backgroundColor = NSColor.gray.cgColor
            progressBarBackground.layer?.cornerRadius = 2

            progressBar.wantsLayer = true
            progressBar.layer?.backgroundColor = NSColor.systemBlue.cgColor
            progressBarBackground.addSubview(progressBar)

            knob.wantsLayer = true
            knob.layer?.backgroundColor = .white
            knob.layer?.cornerRadius = 5
            knob.layer?.borderWidth = 1

            addSubview(background)
            addSubview(progressBarBackground)
            addSubview(knob)
            addSubview(icon)
        }

        required init?(coder: NSCoder) { fatalError() }


        override func touchesBegan(with event: NSEvent) {
            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x

            let width = NSTouchBar.sliderWidth + NSTouchBar.buttonWidth + widthDifference
            setWidth(width, animated: true)
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                background.animator().frame.size.width = width

                progressBarBackground.animator().frame.origin.x = NSTouchBar.buttonWidth / 2 - NSTouchBar.size.height / 4
                progressBarBackground.animator().frame.size.width = NSTouchBar.sliderWidth - NSTouchBar.size.height / 2

                progressBar.frame.size.width = value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)

                icon.animator().frame.origin.x = background.animator().frame.width - NSTouchBar.buttonWidth

                knobX = widthDifference + value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)
                knob.animator().frame.origin.x = knobX!
                knobX! -= widthDifference

                previousValue = value
            }
        }

        override func touchesMoved(with event: NSEvent) {
            guard
                touchX != nil && knobX != nil && previousValue != nil,
                let x = event.touches(matching: .moved, in: self).first?.location(in: self).x
            else { return }

            let offset = max(0, min(
                NSTouchBar.sliderWidth - NSTouchBar.size.height,
                x - (NSTouchBar.size.height - NSTouchBar.buttonWidth) / 2 - widthDifference - touchX! + knobX!
            ))
            value = offset / (NSTouchBar.sliderWidth - NSTouchBar.size.height)

            progressBar.frame.size.width = value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)

            knob.frame.origin.x = offset + widthDifference

            if abs(previousValue! - value) > 0.01 ||
               previousValue != value && (value == 0 || value == 1)
            {
                target?.perform(action)
            }

            previousValue = value
        }

        override func touchesEnded(with event: NSEvent) {
            touchX = nil
            knobX = nil

            setWidth(NSTouchBar.buttonWidth, animated: true)
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                background.animator().frame.size.width = NSTouchBar.buttonWidth

                progressBarBackground.animator().frame.origin.x = -NSTouchBar.sliderWidth
                progressBarBackground.animator().frame.size.width = NSTouchBar.sliderWidth - NSTouchBar.size.height / 2

                icon.animator().frame.origin.x = 0
                knob.animator().frame.origin.x = -NSTouchBar.buttonWidth
            }
        }
    }
}
