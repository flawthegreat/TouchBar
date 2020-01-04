class CalculatorApplication: TouchBar.Application {

    private class CopyTextField: NSTextField {

        override func touchesBegan(with event: NSEvent) {
            _ = target?.perform(action)
        }
    }

    private class OperationButton: NSButton {

        private(set) var isChecked: Bool = false

        weak var parentTarget: NSView?
        var parentAction: Selector?

        init(x: CGFloat, title: String) {
            super.init(frame: NSRect(origin: CGPoint(x: x, y: 0), size: NSTouchBar.buttonSize))

            wantsLayer = true
            layer?.borderWidth = 0
            layer?.cornerRadius = 5
            layer?.borderColor = .white

            bezelStyle = .rounded
            bezelColor = NSColor.systemOrange
            font = .systemFont(ofSize: 17)

            self.title = title

            target = self
            action = #selector(toggle)
        }

        required init?(coder: NSCoder) { fatalError() }


        func uncheck() {
            isChecked = false
            borderSetVisible(false)
        }

        @objc
        private func toggle() {
            isChecked = !isChecked
            borderSetVisible(isChecked)
            parentTarget?.perform(parentAction, with: self)
        }

        private func borderSetVisible(_ visible: Bool) {
            layer?.borderWidth = visible ? 2 : 0
        }
    }

    private let minNumberWidth: CGFloat = 150
    private let pasteButtonWidth: CGFloat = 55
    private let width: CGFloat

    private let divideButton = OperationButton(
        x: 0,
        title: "􀅿"
    )

    private let multiplyButton = OperationButton(
        x: NSTouchBar.buttonSize.width + NSTouchBar.itemGap,
        title: "􀅾"
    )

    private let subtractButton = OperationButton(
        x: 2 * (NSTouchBar.buttonSize.width + NSTouchBar.itemGap),
        title: "􀅽"
    )

    private let addButton = OperationButton(
        x: 3 * (NSTouchBar.buttonSize.width + NSTouchBar.itemGap),
        title: "􀅼"
    )

    private let currentNumberLabel: NSTextField
    private var previousNumberLabel: NSTextField
    private let pasteButton: NSButton

    private var fillingDecimalPlaces = false
    private var integerPlaces = 1
    private var decimalPlaces = 0
    private var powerOfTen = 1.0

    private var operationIsChecked = false

    private var successfulCopyBackground: NSView

    private var eventMonitor: Any?


    init() {
        width = 4 * (NSTouchBar.buttonSize.width + NSTouchBar.itemGap) + minNumberWidth +
            NSTouchBar.itemGap + pasteButtonWidth + 20

        currentNumberLabel = NSTextField(frame: NSRect(
            x: 4 * (NSTouchBar.buttonSize.width + NSTouchBar.itemGap),
            y: -9,
            width: minNumberWidth,
            height: NSTouchBar.size.height
        ))
        previousNumberLabel = NSTextField(frame: NSRect(
            x: 4 * (NSTouchBar.buttonSize.width + NSTouchBar.itemGap),
            y: NSTouchBar.size.height / 2 - 8,
            width: minNumberWidth,
            height: NSTouchBar.size.height
        ))

        pasteButton = NSButton(frame: NSRect(
            origin: CGPoint(x: width - pasteButtonWidth, y: 0),
            size: CGSize(width: pasteButtonWidth, height: NSTouchBar.size.height)
        ))

        successfulCopyBackground = NSView(frame: pasteButton.bounds)

        super.init(width: width, name: "com.flaw.touchBarApp.calculator")

        divideButton.parentTarget = self
        divideButton.parentAction = #selector(updateCheckedOperation)

        multiplyButton.parentTarget = self
        multiplyButton.parentAction = #selector(updateCheckedOperation)

        subtractButton.parentTarget = self
        subtractButton.parentAction = #selector(updateCheckedOperation)

        addButton.parentTarget = self
        addButton.parentAction = #selector(updateCheckedOperation)

        currentNumberLabel.textColor = .white
        currentNumberLabel.font = .systemFont(ofSize: 18)
        currentNumberLabel.alignment = .right
        currentNumberLabel.stringValue = "0"
        currentNumberLabel.target = self
        currentNumberLabel.action = #selector(copyNumber)

        previousNumberLabel.textColor = NSColor(white: 1, alpha: 0.7)
        previousNumberLabel.font = .systemFont(ofSize: 18)
        previousNumberLabel.alignment = .right
        previousNumberLabel.stringValue = "0"
        previousNumberLabel.target = self
        previousNumberLabel.action = #selector(copyNumber)

        pasteButton.bezelStyle = .rounded
        pasteButton.font = .systemFont(ofSize: NSTouchBar.fontSize)
        pasteButton.title = "􀉄"
        pasteButton.bezelColor = NSColor.controlColor
        pasteButton.target = self
        pasteButton.action = #selector(pasteNumber)

        successfulCopyBackground.wantsLayer = true
        successfulCopyBackground.layer?.cornerRadius = 5
        successfulCopyBackground.layer?.backgroundColor = NSColor.systemGreen.cgColor
        successfulCopyBackground.alphaValue = 0
        pasteButton.addSubview(successfulCopyBackground)

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyDown(with:))

        addSubview(divideButton)
        addSubview(multiplyButton)
        addSubview(subtractButton)
        addSubview(addButton)
        addSubview(currentNumberLabel)
        addSubview(previousNumberLabel)
        addSubview(pasteButton)
    }

    required init?(coder: NSCoder) { fatalError() }


    private func updatePlacesForValue(_ value: String) -> String {
        var newValueString = "\(value)"
        if newValueString.contains(".") {
            while newValueString.last == "0" {
                newValueString = String(newValueString.dropLast())
            }
            if newValueString.last == "." {
                newValueString = String(newValueString.dropLast())
            }
        }

        integerPlaces = 0
        decimalPlaces = 0
        powerOfTen = 1

        for char in newValueString {
            if char == "." { break }
            if char == "-" { continue } 
            integerPlaces += 1
            if integerPlaces == 16 {
                return "0"
            }
        }

        if newValueString.contains(".") {
            for char in newValueString.reversed() {
                if char == "." { break }
                decimalPlaces += 1
                powerOfTen *= 10
                if integerPlaces + decimalPlaces == 16 {
                    fillingDecimalPlaces = decimalPlaces > 0
                    while newValueString.count > 17 {
                        newValueString = String(newValueString.dropLast())
                    }
                    return newValueString
                }
            }
        }

        fillingDecimalPlaces = decimalPlaces > 0

        return newValueString
    }

    private func performOperation() {
        let currentNumber = getCurrentNumber()
        let previousNumber = getPreviousNumber()

        func apply(newValue: Double) {
            previousNumberLabel.stringValue = currentNumberLabel.stringValue
            currentNumberLabel.stringValue = updatePlacesForValue("\(newValue)")
            operationIsChecked = false
            divideButton.uncheck()
            multiplyButton.uncheck()
            subtractButton.uncheck()
            addButton.uncheck()
        }

        if divideButton.isChecked {
            guard currentNumber != 0 else { return }
            apply(newValue: previousNumber / currentNumber)
        } else if multiplyButton.isChecked {
            apply(newValue: previousNumber * currentNumber)
        } else if subtractButton.isChecked {
            apply(newValue: previousNumber - currentNumber)
        } else if addButton.isChecked {
            apply(newValue: previousNumber + currentNumber)
        }
    }

    private func digitForKeyCode(_ keyCode: UInt16) -> Double? {
        switch keyCode {
        case 29: return 0
        case 18: return 1
        case 19: return 2
        case 20: return 3
        case 21: return 4
        case 23: return 5
        case 22: return 6
        case 26: return 7
        case 28: return 8
        case 25: return 9
        default: return nil
        }
    }

    private func keyDown(with event: NSEvent) -> NSEvent? {
        let keyCode = event.keyCode
        var currentNumber = getCurrentNumber()

        if keyCode == 36 {
            if operationIsChecked {
                performOperation()
            }

            return nil
        }

        if keyCode == 51 {
            currentNumberLabel.stringValue = String(currentNumberLabel.stringValue.dropLast())

            if fillingDecimalPlaces {
                if decimalPlaces == 0 {
                    fillingDecimalPlaces = false
                } else {
                    decimalPlaces -= 1
                    powerOfTen /= 10
                }
            } else {
                integerPlaces -= 1
            }

            if currentNumberLabel.stringValue == "" { resetNumber() }
            if currentNumberLabel.stringValue.last == "." {
                currentNumberLabel.stringValue = String(currentNumberLabel.stringValue.dropLast())
                fillingDecimalPlaces = false
            }
            if currentNumberLabel.stringValue == "" { resetNumber() }

            return nil
        }

        if keyCode == 47 && !fillingDecimalPlaces {
            fillingDecimalPlaces = true
            return nil
        }

        if keyCode == 27 {
            if currentNumber != 0 {
                currentNumberLabel.stringValue = formattedString(from: -currentNumber)
            }

            return nil
        }

        if currentNumberLabel.stringValue.count >= 16 +
           (fillingDecimalPlaces && decimalPlaces > 0 ? 1 : 0)
        {
            return nil
        }

        guard let digit = digitForKeyCode(keyCode) else { return nil }

        let sign: Double = currentNumber < 0 ? -1 : 1
        currentNumber = abs(currentNumber)

        if !fillingDecimalPlaces {
            if currentNumber != 0 && digit != 0 { integerPlaces += 1 }
            currentNumber *= 10
            currentNumber += digit
        } else {
            if decimalPlaces == 15 { return nil }
            decimalPlaces += 1
            powerOfTen *= 10
            currentNumber += digit / powerOfTen
        }

        currentNumberLabel.stringValue = formattedString(from: sign * currentNumber)

        return nil
    }

    private func formattedString(from number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.minimumIntegerDigits = integerPlaces
        formatter.minimumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(floatLiteral: number)) ?? "0.0"
    }

    private func getCurrentNumber() -> Double {
        return Double(currentNumberLabel.stringValue) ?? 0
    }

    private func getPreviousNumber() -> Double {
        return Double(previousNumberLabel.stringValue) ?? 0
    }

    @objc
    private func updateCheckedOperation(_ sender: OperationButton?) {
        if sender != divideButton { divideButton.uncheck() }
        if sender != multiplyButton { multiplyButton.uncheck() }
        if sender != subtractButton { subtractButton.uncheck() }
        if sender != addButton { addButton.uncheck() }
        if !operationIsChecked {
            operationIsChecked = true
            previousNumberLabel.stringValue = currentNumberLabel.stringValue
            resetNumber()
        }
    }

    private func resetNumber() {
        currentNumberLabel.stringValue = "0"
        integerPlaces = 1
        decimalPlaces = 0
        fillingDecimalPlaces = false
        powerOfTen = 1
    }

    @objc
    private func copyNumber() {
        NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
            successfulCopyBackground.animator().alphaValue = 0.8
        }, completionHandler: {
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                self.successfulCopyBackground.animator().alphaValue = 0
            }
        })
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(currentNumberLabel.stringValue, forType: .string)
    }

    @objc
    private func pasteNumber() {
        let string: String? = NSPasteboard.general.string(forType: .string)
        if let value = Double(string ?? "") {
            currentNumberLabel.stringValue = updatePlacesForValue("\(value)")
        }
    }

    override func updateContentsToMatchWidth(_ width: CGFloat) {
        if self.width > width {
            pasteButton.frame.origin.x = self.width - pasteButtonWidth
            currentNumberLabel.frame.size.width = minNumberWidth
            previousNumberLabel.frame.size = currentNumberLabel.animator().frame.size
        } else {
            pasteButton.frame.origin = CGPoint(x: width - pasteButtonWidth, y: 0)
            currentNumberLabel.frame.size.width = width - pasteButtonWidth - currentNumberLabel.frame.origin.x - NSTouchBar.itemGap
            previousNumberLabel.frame.size = currentNumberLabel.animator().frame.size
        }
        frame.size.width = max(width, self.width)
    }

    override func applicationWillTerminate() {
        guard eventMonitor != nil else { return }

        NSEvent.removeMonitor(eventMonitor!)
        eventMonitor = nil
    }
}
