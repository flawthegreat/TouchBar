//class CalculatorItem: TouchBar.Button {
//
//    private var isRunning: Bool = false
//    private var applicationName: String?
//
//
//    override init(alignment: Alignment) {
//        super.init(alignment: alignment)
//
//        title = "􀘽"
//        target = self
//        action = #selector(toggleApplication)
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(applicationWillTerminate),
//            name: .touchBarApplicationWillTerminate,
//            object: nil
//        )
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//
//    @objc
//    private func toggleApplication() {
//        if let runningApplicationName = TouchBar.shared.currentApplication?.name,
//           runningApplicationName == applicationName
//        {
//            isRunning = false
//            TouchBar.shared.terminateApplication()
//        } else if !isRunning {
//            isRunning = true
//            TouchBar.shared.runApplication(CalculatorApplication())
//            applicationName = TouchBar.shared.currentApplication?.name
//        }
//    }
//
//    @objc
//    private func applicationWillTerminate() {
//        if TouchBar.shared.currentApplication?.name == applicationName { isRunning = false }
//    }
//}
