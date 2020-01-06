import IOBluetooth

final class AirPodsItem: TouchBar.Item {

    private let addressString = "fc-1d-43-dd-6b-3d"

    private let button = NSButton(frame: NSRect(origin: .zero, size: CGSize(width: 22, height: TouchBar.size.height)))
    private let icon = NSImageView(frame: NSRect(x: 0, y: 5.8, width: 22, height: 18))
    private var flash = NSView(frame: NSRect(origin: .zero, size: CGSize(width: 22, height: TouchBar.size.height)))

    private var airPods: IOBluetoothDevice?


    init(alignment: Alignment) {
        super.init(alignment: alignment, width: 22)

        button.target = self
        button.action = #selector(searchForAirPods)
        button.bezelStyle = .regularSquare

        flash.wantsLayer = true
        flash.layer?.cornerRadius = 6
        flash.layer?.cornerCurve = .continuous
        flash.layer?.backgroundColor = NSColor.controlColor.cgColor
        flash.alphaValue = 0

        button.addSubview(flash)

        icon.image = NSImage(named: "AirPodsIcon")
        update()

        IOBluetoothDevice.register(
            forConnectNotifications: self,
            selector: #selector(update)
        )

        searchForAirPods(updateConnection: false)

        addSubview(icon)
        addSubview(button)
    }

    required init?(coder: NSCoder) { fatalError() }


    override func update() {
        icon.alphaValue = airPods?.isConnected() ?? false ? 1 : 0.5
    }

    @objc
    private func searchForAirPods(updateConnection: Bool = true) {
        IOBluetoothPreferenceSetControllerPowerState(1)

        if airPods == nil {
            for device in IOBluetoothDevice.pairedDevices() {
                guard
                    let device = device as? IOBluetoothDevice,
                    let addressString = device.addressString,
                    addressString == self.addressString
                else { continue }

                airPods = IOBluetoothDevice(addressString: addressString)

                airPods?.register(
                    forDisconnectNotification: self,
                    selector: #selector(update)
                )

                break
            }
        }

        guard updateConnection else { return }

        _ = airPods!.isConnected() ? airPods?.closeConnection() : airPods?.openConnection()
    }

    override func touchesBegan(with event: NSEvent) {
        flash.alphaValue = 1
    }

    override func touchesEnded(with event: NSEvent) {
        NSView.animate(withDuration: TouchBar.animationDuration * 2) { _ in self.flash.animator().alphaValue = 0 }
    }
}
