final class CalculatorApplication: TouchBar.Application {

    init() {
        super.init(name: "Calculator", accentColor: .systemOrange)

        card.image = NSImage(named: "CalculatorIcon")!
    }

    required init?(coder: NSCoder) { fatalError() }


    override func initView() -> NSView { CalculatorView() }

    override func applicationWillTerminate() {
        guard let view = view as? CalculatorView, let monitor = view.keyDownMonitor else { return }

        NSEvent.removeMonitor(monitor)
        view.keyDownMonitor = nil
    }

    override func updateWidth(_ newWidth: CGFloat, animated: Bool = false) {
        guard let view = view as? CalculatorView else { return }

        view.update(newWidth, animated: animated)
    }
}

extension CalculatorApplication {
    private class CalculatorView: NSView {

        struct Operation {
            var name: String
            var perform: (Decimal, Decimal) -> Decimal
        }

        class OperationButton: NSButton {

            let operation: Operation
            var isSelected: Bool { layer?.borderWidth != 0 }
            unowned var view: CalculatorView!


            init(operation: Operation, view: CalculatorView) {
                self.operation = operation
                self.view = view

                super.init(frame: NSRect(origin: .zero, size: NSTouchBar.buttonSize))

                bezelColor = .systemOrange
                bezelStyle = .rounded

                wantsLayer = true
                layer?.borderWidth = 0
                layer?.borderColor = .white
                layer?.cornerRadius = 6
                layer?.cornerCurve = .continuous

                font = .systemFont(ofSize: 17)
                self.title = operation.name
            }

            required init?(coder: NSCoder) { fatalError() }


            func select() {
                view.chooseOperation(operation, sender: self)
                layer?.borderWidth = 2
            }

            func deselect() {
                view.operation = nil
                layer?.borderWidth = 0
            }

            override func touchesEnded(with event: NSEvent) {
                super.touchesEnded(with: event)
                select()
            }
        }

        class Button: NSButton {

            let flashBackground = NSView(frame: NSRect(origin: .zero, size: CGSize(
                width: 64,
                height: NSTouchBar.size.height
            )))


            init(title: String, target: NSObject? = nil, action: Selector? = nil) {
                super.init(frame: NSRect(origin: .zero, size: CGSize(width: 64, height: NSTouchBar.size.height)))

                bezelStyle = .rounded

                font = .systemFont(ofSize: 17)
                self.title = title

                self.target = target
                self.action = action

                flashBackground.wantsLayer = true
                flashBackground.layer?.backgroundColor = NSColor.systemGreen.cgColor
                flashBackground.layer?.cornerRadius = 6
                flashBackground.layer?.cornerCurve = .continuous
                flashBackground.alphaValue = 0

                addSubview(flashBackground)
            }

            required init?(coder: NSCoder) { fatalError() }


            override func flash() {
                NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
                    flashBackground.animator().alphaValue = 0.75
                }, completionHandler: {
                    NSView.animate(withDuration: Constants.animationDuration) { _ in
                        self.flashBackground.animator().alphaValue = 0
                    }
                })
            }
        }

        let previousValueLabel = NSTextField(frame: NSRect(origin: .zero, size: CGSize(width: 0, height: 24)))
        let currentValueLabel = NSTextField(frame: NSRect(origin: .zero, size: CGSize(width: 0, height: 24)))

        let pasteButton = Button(title: "􀉄")

        var keyDownMonitor: Any?

        var previousValue = "0"
        var currentValue = "0"

        var isFillingFractionalPlaces = false
        var fractionalPlaces = 0

        var operation: Operation?
        var isChoosingOperation = false


        init() {
            super.init(frame: .zero)

            previousValueLabel.font = .systemFont(ofSize: 19)
            previousValueLabel.textColor = NSColor(white: 0.7, alpha: 1)
            previousValueLabel.alignment = .right
            previousValueLabel.frame.origin.y = 14

            currentValueLabel.font = .systemFont(ofSize: 19)
            currentValueLabel.textColor = .white
            currentValueLabel.alignment = .right
            currentValueLabel.frame.origin.y = -2.5

            addSubview(previousValueLabel)
            addSubview(currentValueLabel)

            pasteButton.target = self
            pasteButton.action = #selector(pasteNumber)

            addSubview(pasteButton)

            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyDown(with:))

            let divide = OperationButton(operation: Operation(name: "􀅿", perform: { $0 / $1 }), view: self)
            divide.frame.origin.x = 0
            addSubview(divide)

            let multiply = OperationButton(operation: Operation(name: "􀅾", perform: { $0 * $1 }), view: self)
            multiply.frame.origin.x = NSTouchBar.buttonSize.width + NSTouchBar.itemGap
            addSubview(multiply)

            let subtract = OperationButton(operation: Operation(name: "􀅽", perform: { $0 - $1 }), view: self)
            subtract.frame.origin.x = (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) * 2
            addSubview(subtract)

            let sum = OperationButton(operation: Operation(name: "􀅼", perform: { $0 + $1 }), view: self)
            sum.frame.origin.x = (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) * 3
            addSubview(sum)

            update()
        }

        required init?(coder: NSCoder) { fatalError() }


        func reset() {
            previousValue = "0"
            currentValue = "0"

            isFillingFractionalPlaces = false
            fractionalPlaces = 0

            operation = nil
            isChoosingOperation = false
        }

        @objc
        func pasteNumber() {
            if let string = NSPasteboard.general.string(forType: .string), let decimal = Decimal(string: string) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                formatter.roundingMode = .halfUp
                formatter.maximumFractionDigits = 15
                formatter.decimalSeparator = "."

                if var newValue = formatter.string(for: decimal) {
                    if newValue.count > 17 { newValue.removeLast(newValue.count - 17) }

                    fractionalPlaces = 0
                    isFillingFractionalPlaces = false
                    for character in newValue.reversed() {
                        if character == "." {
                            isFillingFractionalPlaces = true
                            break
                        }
                    }
                    fractionalPlaces += 1
                    if !isFillingFractionalPlaces { fractionalPlaces = 0 }

                    currentValue = newValue
                }
            }

            update()
        }

        func copyResult() {
            pasteButton.flash()
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(currentValue, forType: .string)
        }

        override func touchesBegan(with event: NSEvent) {
            super.touchesBegan(with: event)

            guard let x = event.touches(matching: .began, in: self).first?.location(in: self).x else { return }

            let bound = (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) * 4
            if x > bound && x < bound + currentValueLabel.frame.width { copyResult() }
        }

        func update(_ newWidth: CGFloat = TouchBar.shared.applicationManager.frame.width, animated: Bool = false) {
            previousValueLabel.stringValue = previousValue
            currentValueLabel.stringValue = currentValue

            NSView.animate(withDuration: animated ? Constants.animationDuration : 0) { _ in
                pasteButton.animator().frame.origin.x = newWidth - pasteButton.frame.width - 2

                let width = newWidth - (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) * 4 - (pasteButton.frame.size.width + NSTouchBar.itemGap)
                let x = (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) * 4

                previousValueLabel.animator().frame.size.width = width
                previousValueLabel.animator().frame.origin.x = x

                currentValueLabel.animator().frame.size.width = width
                currentValueLabel.animator().frame.origin.x = x
            }
        }

        func chooseOperation(_ operation: Operation, sender: OperationButton) {
            if !isChoosingOperation {
                previousValue = currentValue
                currentValue = "0"

                isFillingFractionalPlaces = false
                fractionalPlaces = 0
            }

            isChoosingOperation = true

            for case let operationButton as OperationButton in subviews {
                if operationButton != sender { operationButton.deselect() }
            }
            self.operation = operation
        }

        func digitForKeyCode(_ keyCode: UInt16) -> String? {
            switch keyCode {
            case 29: return "0"
            case 18: return "1"
            case 19: return "2"
            case 20: return "3"
            case 21: return "4"
            case 23: return "5"
            case 22: return "6"
            case 26: return "7"
            case 28: return "8"
            case 25: return "9"
            default: return nil
            }
        }

        @discardableResult
        func appendDigit(_ digit: String) -> Bool {
            if !isFillingFractionalPlaces {
                if currentValue == "0" && digit == "0" {
                    return false
                } else if currentValue == "0" {
                    currentValue = digit

                    return true
                }

                let newValue = currentValue + digit
                if newValue.count < 18 {
                    currentValue = newValue

                    return true
                }

                return false
            }

            guard fractionalPlaces + 1 <= 15 else { return false }

            let newValue = currentValue + digit
            if newValue.count < 18 {
                currentValue = newValue
                fractionalPlaces += 1

                return true
            }

            return false
        }

        func keyDown(with event: NSEvent) -> NSEvent? {
            let keyCode = event.keyCode

            defer { update() }

            if let digit = digitForKeyCode(keyCode) {
                appendDigit(digit)

                return nil
            }

            if keyCode == 47 {
                isFillingFractionalPlaces = true
                currentValue += "."

                return nil
            }

            if keyCode == 27 {
                guard currentValue != "0" else { return nil }

                if currentValue.first == "-" { currentValue.removeFirst() }
                else { currentValue = "-" + currentValue }

                return nil
            }

            if keyCode == 51 {
                if currentValue.last == "." { isFillingFractionalPlaces = false }

                currentValue.removeLast()
                if isFillingFractionalPlaces { fractionalPlaces -= 1 }
                if currentValue.count == 0 { currentValue = "0" }

                return nil
            }

            if keyCode == 36 && operation != nil {
                let result = operation!.perform(Decimal(string: previousValue)!, Decimal(string: currentValue)!)

                guard result < 1e18 && !result.isNaN else {
                    reset()
                    return nil
                }

                let formatter = NumberFormatter()
                formatter.numberStyle = .none
                formatter.roundingMode = .halfUp
                formatter.maximumFractionDigits = 15
                formatter.decimalSeparator = "."

                var string = formatter.string(for: result)!
                if string.count > 17 { string.removeLast(string.count - 17) }

                fractionalPlaces = 0
                isFillingFractionalPlaces = false
                for character in string.reversed() {
                    if character == "." {
                        isFillingFractionalPlaces = true
                        break
                    }
                }
                fractionalPlaces += 1
                if !isFillingFractionalPlaces { fractionalPlaces = 0 }

                previousValue = currentValue
                currentValue = string

                for case let operationButton as OperationButton in subviews { operationButton.deselect() }
                isChoosingOperation = false

                return nil
            }

            return nil
        }
    }
}

extension String {
    init(_ decimal: Decimal) {
        self.init("\(decimal)")
    }
}
