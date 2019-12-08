import Foundation

class CalculatorItem: TouchBar.Button {

    private var isRunning: Bool
    private var applicationName: String?


    override init(alignment: Alignment) {
        isRunning = false

        super.init(alignment: alignment)

        title = "􀘽"
        target = self
        action = #selector(toggleApplication)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate),
            name: .touchBarApplicationWillTerminate,
            object: nil
        )
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    private func toggleApplication() {
        if isRunning {
            isRunning = false
            TouchBar.shared.terminateApplication()
        } else {
            isRunning = true
            TouchBar.shared.runApplication(CalculatorApplication())
            applicationName = TouchBar.shared.runningApplication?.name
        }
    }

    @objc
    private func applicationWillTerminate() {
        if TouchBar.shared.runningApplication?.name == applicationName { isRunning = false }
    }
}
