import Foundation

class DateItem: TouchBar.Item {

    private let horizontalPadding: CGFloat
    private let verticalOffset: CGFloat

    private let label: NSTextField
    private var timer: Timer?


    init(alignment: Alignment) {
        horizontalPadding = -3.5
        verticalOffset = -3

        label = NSTextField(frame: NSRect(
            x: horizontalPadding,
            y: verticalOffset,
            width: 0,
            height: NSTouchBar.size.height
        ))

        super.init(alignment: alignment, width: 10)

        label.textColor = .white
        label.font = .systemFont(ofSize: NSTouchBar.fontSize)

        resetTimer()
        updateLabel(animated: false)

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func resetTimer() {
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
    private func updateLabel(animated: Bool = true) {
        label.stringValue = Date().string(withFormat: "E d MMM H:mm")
        label.sizeToFit()
        label.frame.size.height = NSTouchBar.size.height
        setWidth(label.frame.width + horizontalPadding * 2, animated: animated)
    }
}
