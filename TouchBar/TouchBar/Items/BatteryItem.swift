import IOKit.ps

final class BatteryItem: TouchBar.Item {

    private let icon = NSImageView(frame: NSRect(
        origin: CGPoint(x: 0, y: 7),
        size: CGSize(width: 32, height: 16)
    ))

    private let indicator = NSView(frame: NSRect(
        origin: CGPoint(x: 3, y: 3),
        size: CGSize(width: 2, height: 10)
    ))


    init(alignment: Alignment) {
        super.init(alignment: alignment, width: 32)

        icon.image = NSImage(named: "BatteryIcon")

        indicator.wantsLayer = true
        indicator.layer?.cornerRadius = 1

        icon.addSubview(indicator)

        update()

        CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), IOPSNotificationCreateRunLoopSource({ context in
            guard context != nil else { return }

            Unmanaged<BatteryItem>.fromOpaque(context!).takeUnretainedValue().update()
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())).takeRetainedValue(), .defaultMode)

        addSubview(icon)
    }

    required init?(coder: NSCoder) { fatalError() }


    override func update() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        for powerSource in IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array {
            let info = IOPSGetPowerSourceDescription(
                snapshot,
                powerSource
            ).takeUnretainedValue() as! [String: AnyObject]

            guard
                let capacity = info[kIOPSCurrentCapacityKey] as? CGFloat,
                let powerSourceState = info[kIOPSPowerSourceStateKey] as? String
            else { continue }

            let isCharging = powerSourceState != "Battery Power"

            indicator.frame.size.width = max(2, 0.22 * capacity)

            if isCharging {
                indicator.layer?.backgroundColor = NSColor(red: 48, green: 209, blue: 88).cgColor
            } else if capacity > 10 {
                indicator.layer?.backgroundColor = .white
            } else {
                indicator.layer?.backgroundColor = NSColor(red: 255, green: 69, blue: 58).cgColor
            }

            break
        }
    }
}
