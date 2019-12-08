import Foundation
import IOBluetooth

class AirPodsItem: TouchBar.Item {

    private let addressString: String = "fc-1d-43-dd-6b-3d"
    private let width: CGFloat = 22

    private let button: NSButton
    private let icon: NSImageView

    private var flash: NSView

    private var airPods: IOBluetoothDevice?


    init(alignment: Alignment) {
        button = NSButton(frame: NSRect(
            x: 0,
            y: 0,
            width: width,
            height: NSTouchBar.size.height
        ))
        icon = NSImageView(frame: NSRect(x: 0, y: 5.8, width: width, height: 18))
        flash = NSView(frame: button.bounds)

        super.init(alignment: alignment, width: width)

        button.target = self
        button.action = #selector(searchForAirPods)
        button.bezelStyle = .regularSquare

        flash.wantsLayer = true
        flash.layer?.cornerRadius = 5
        flash.layer?.backgroundColor = NSColor.controlColor.cgColor
        flash.alphaValue = 0
        button.addSubview(flash)

        icon.image = NSImage(named: "AirPodsIcon")

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(updateIcon),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

        searchForAirPods(updateConnection: false)
        updateIcon()

        addSubview(icon)
        addSubview(button)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func updateIcon() {
        icon.alphaValue = airPods?.isConnected() ?? false ? 1 : 0.5
    }

    @objc
    private func searchForAirPods(updateConnection: Bool = true) {
        IOBluetoothPreferenceSetControllerPowerState(1)

        if airPods == nil {
            IOBluetoothDevice.pairedDevices().forEach { device in
                if let device = device as? IOBluetoothDevice,
                   let addressString = device.addressString,
                   addressString == self.addressString
                {
                    airPods = IOBluetoothDevice(addressString: addressString)
                    updateIcon()

                    guard airPods != nil else { return }

                    airPods?.register(
                        forDisconnectNotification: self,
                        selector: #selector(updateIcon)
                    )
                    IOBluetoothDevice.register(
                        forConnectNotifications: self,
                        selector: #selector(updateIcon)
                    )
                }
            }
        }

        guard updateConnection else { return }

        _ = airPods!.isConnected() ? airPods?.closeConnection() : airPods?.openConnection()
    }

    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        flash.alphaValue = 1
    }

    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        NSView.animate(withDuration: Constants.animationDuration * 2) { _ in
            self.flash.animator().alphaValue = 0
        }
    }
}
