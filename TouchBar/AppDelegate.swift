@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "  "
        statusItem.menu = menu

        TouchBar.shared.items = [
            VolumeItem(alignment: .left),
            BrightnessItem(alignment: .left),
            AppSwitcherItem(alignment: .left),
            DateItem(alignment: .right),
            BatteryItem(alignment: .right),
            AirPodsItem(alignment: .right),
        ]

        TouchBar.shared.applications = [
            TouchBar.Application(name: "Hello)", accentColor: .systemIndigo),
            TouchBar.Application(name: "Hello)", accentColor: .systemRed),
            TouchBar.Application(name: "Hello)", accentColor: .systemBlue),
            TouchBar.Application(name: "Hello)", accentColor: .systemGray),
            TouchBar.Application(name: "Hello)", accentColor: .systemGreen),
            TouchBar.Application(name: "Hello)", accentColor: .systemOrange),
            TouchBar.Application(name: "Hello)", accentColor: .systemPurple),
            TouchBar.Application(name: "Hello)", accentColor: .systemTeal),
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
