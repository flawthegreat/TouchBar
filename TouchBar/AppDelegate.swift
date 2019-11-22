import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "  "
        statusItem.menu = menu

        TouchBar.shared.items = [
            VolumeItem(alignment: .left),
            CalculatorItem(alignment: .left),
            BrightnessItem(alignment: .left),
            DateItem(alignment: .right),
            BatteryItem(alignment: .right),
            AirPodsItem(alignment: .right),
        ]
        TouchBar.shared.show()
    }

    @IBAction func reloadControlStripButton(_ sender: NSMenuItem) {
        TouchBar.shared.reloadControlStripButton()
    }

    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
