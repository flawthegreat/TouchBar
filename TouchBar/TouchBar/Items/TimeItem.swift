final class TimeItem: TouchBar.Item {

    private let label = NSTextField(frame: NSRect(
        x: -5,
        y: -3,
        width: 52,
        height: TouchBar.size.height
    ))

    private var timer: Timer?


    init(alignment: Alignment) {
        super.init(alignment: alignment, width: 42)

        label.textColor = .white
        label.font = .systemFont(ofSize: TouchBar.fontSize)
        label.alignment = .center

        update()

        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError() }


    override func update() {
        updateLabel()

        let currentDate = Date()
        let delay = TimeInterval(60 - Calendar.current.component(.second, from: currentDate))

        timer?.invalidate()
        timer = Timer(
            fireAt: currentDate.addingTimeInterval(delay),
            interval: 60,
            target: self,
            selector: #selector(updateLabel),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(timer!, forMode: .default)
    }

    @objc
    private func updateLabel() {
        label.stringValue = Date().string(withFormat: "H:mm")
        label.sizeToFit()
        label.frame.size.height = TouchBar.size.height
    }
}

extension Date {
    func string(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
