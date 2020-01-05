import IOKit.ps

final class BatteryItem: TouchBar.Item {

    private let horizontalPadding: CGFloat = -3.5
    private let verticalOffset: CGFloat = -3
    private let percentage: NSTextField

    private let icon = NSImageView(frame: NSRect(
        origin: CGPoint(x: 0, y: 7),
        size: CGSize(width: 32, height: 16)
    ))

    private let indicator = NSView(frame: NSRect(
        origin: CGPoint(x: 3, y: 3),
        size: CGSize(width: 2, height: 10)
    ))


    init(alignment: Alignment) {
        percentage = NSTextField(frame: NSRect(
            x: horizontalPadding,
            y: verticalOffset,
            width: 0,
            height: NSTouchBar.size.height
        ))

        super.init(alignment: alignment, width: 0)

        percentage.font = .systemFont(ofSize: NSTouchBar.fontSize)
        percentage.textColor = .white

        icon.image = NSImage(named: "BatteryIcon")

        indicator.wantsLayer = true
        indicator.layer?.cornerRadius = 1
        icon.addSubview(indicator)

        update()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(update),
            name: NSWorkspace.screensDidWakeNotification
        )

        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let source = IOPSNotificationCreateRunLoopSource({ context in
            guard context != nil else { return }

            Unmanaged<BatteryItem>.fromOpaque(context!).takeUnretainedValue().update()
        }, context).takeRetainedValue()
        CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), source, .defaultMode)

        addSubview(percentage)
        addSubview(icon)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    override func update() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        for powerSource in IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array {
            let info = IOPSGetPowerSourceDescription(
                snapshot,
                powerSource
            ).takeUnretainedValue() as! [String: AnyObject]

            guard
                let capacity = info[kIOPSCurrentCapacityKey] as? Int,
                let powerSourceState = info[kIOPSPowerSourceStateKey] as? String
            else { continue }

            let isCharging = powerSourceState != "Battery Power"

            percentage.stringValue = "\(capacity)%"
            percentage.sizeToFit()
            percentage.frame.size.height = NSTouchBar.size.height

            icon.frame.origin.x = percentage.frame.width - 6

            setWidth(percentage.frame.width + icon.frame.width - 5)

            indicator.frame.size.width = max(2, 0.22 * CGFloat(capacity))

            if isCharging {
                indicator.layer?.backgroundColor = NSColor(
                    red: 48.0 / 255.0,
                    green: 209.0 / 255.0,
                    blue: 88.0 / 255.0,
                    alpha: 1
                ).cgColor
            } else if capacity > 10 {
                indicator.layer?.backgroundColor = .white
            } else {
                indicator.layer?.backgroundColor = NSColor(
                    red: 255.0 / 255.0,
                    green: 69.0 / 255.0,
                    blue: 58.0 / 255.0,
                    alpha: 1
                ).cgColor
            }
        }
    }
}
