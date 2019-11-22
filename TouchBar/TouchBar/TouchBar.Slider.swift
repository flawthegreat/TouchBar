import Foundation

extension TouchBar {
    class Slider: Item {

        private let widthDifference: CGFloat
        private var touchX: CGFloat?
        private var knobX: CGFloat?
        private var previousValue: CGFloat?

        private let indicatorBackground: NSView
        private let indicator: NSView


        public let background: NSButton
        public let icon: NSImageView
        public let knob: NSView

        public var target: Slider?
        public var action: Selector?
        public var value: CGFloat

        
        init(alignment: Alignment) {
            widthDifference = (NSTouchBar.buttonWidth - NSTouchBar.size.height) / 2.0
            value = 0.0
            touchX = nil
            knobX = nil
            previousValue = nil

            indicatorBackground = NSView(frame: NSRect(
                x: -NSTouchBar.sliderWidth,
                y: 13,
                width: NSTouchBar.sliderWidth - NSTouchBar.size.height / 2.0,
                height: 4
            ))
            indicator = NSView(frame: NSRect(
                x: 0,
                y: 0,
                width: 0,
                height: 4
            ))

            background = NSButton(frame: NSRect(
                x: 0,
                y: 0,
                width: NSTouchBar.buttonWidth,
                height: NSTouchBar.size.height
            ))
            icon = NSImageView(frame: background.frame)

            knob = NSView(frame: NSRect(
                x: -NSTouchBar.buttonWidth,
                y: 0,
                width: NSTouchBar.size.height,
                height: NSTouchBar.size.height
            ))

            target = nil
            action = nil

            super.init(alignment: alignment, width: NSTouchBar.buttonWidth)

            background.bezelStyle = .rounded
            background.title = ""

            indicatorBackground.wantsLayer = true
            indicatorBackground.layer?.backgroundColor = NSColor.gray.cgColor
            indicatorBackground.layer?.cornerRadius = 2.0

            indicator.wantsLayer = true
            indicator.layer?.backgroundColor = NSColor.systemBlue.cgColor
            indicatorBackground.addSubview(indicator)

            knob.wantsLayer = true
            knob.layer?.backgroundColor = .white
            knob.layer?.cornerRadius = 5.0
            knob.layer?.borderWidth = 1.0

            addSubview(background)
            addSubview(indicatorBackground)
            addSubview(knob)
            addSubview(icon)
        }

        required init?(coder: NSCoder) { fatalError() }


        override func touchesBegan(with event: NSEvent) {
            super.touchesBegan(with: event)

            touchX = event.touches(matching: .began, in: self).first?.location(in: self).x

            let width = NSTouchBar.sliderWidth + NSTouchBar.buttonWidth + widthDifference
            set(width: width, animated: true)
            NSView.animate(withDuration: animationDuration) { _ in
                background.animator().frame.size.width = width

                indicatorBackground.animator().frame.origin.x = NSTouchBar.buttonWidth / 2.0 - NSTouchBar.size.height / 4.0
                indicatorBackground.animator().frame.size.width = NSTouchBar.sliderWidth - NSTouchBar.size.height / 2.0

                indicator.frame.size.width = value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)

                icon.animator().frame.origin.x = background.animator().frame.width - NSTouchBar.buttonWidth

                knobX = widthDifference + value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)
                knob.animator().frame.origin.x = knobX!
                knobX! -= widthDifference

                previousValue = value
            }
        }

        override func touchesMoved(with event: NSEvent) {
            super.touchesMoved(with: event)

            guard touchX != nil && knobX != nil && previousValue != nil else { return }

            if let x = event.touches(matching: .moved, in: self).first?.location(in: self).x {
                let offset = max(0.0, min(
                    NSTouchBar.sliderWidth - NSTouchBar.size.height,
                    x - (NSTouchBar.size.height - NSTouchBar.buttonWidth) / 2.0 - widthDifference - touchX! + knobX!
                ))
                value = offset / (NSTouchBar.sliderWidth - NSTouchBar.size.height)

                indicator.frame.size.width = value * (NSTouchBar.sliderWidth - NSTouchBar.size.height)

                knob.frame.origin.x = offset + widthDifference

                if abs(previousValue! - value) > 0.001 ||
                   previousValue != value && (value == 0.0 || value == 1.0)
                {
                    target?.perform(action)
                }

                previousValue = value
            }
        }

        override func touchesEnded(with event: NSEvent) {
            super.touchesEnded(with: event)

            touchX = nil
            knobX = nil

            set(width: NSTouchBar.buttonWidth, animated: true)
            NSView.animate(withDuration: animationDuration) { _ in
                background.animator().frame.size.width = NSTouchBar.buttonWidth

                indicatorBackground.animator().frame.origin.x = -NSTouchBar.sliderWidth
                indicatorBackground.animator().frame.size.width = NSTouchBar.sliderWidth - NSTouchBar.size.height / 2.0

                icon.animator().frame.origin.x = 0
                knob.animator().frame.origin.x = -NSTouchBar.buttonWidth
            }
        }
    }
}
