extension NotificationCenter {
    func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }

    func addObserver(_ observer: Any, selector: Selector, names: [NSNotification.Name], object: Any? = nil) {
        names.forEach { addObserver(observer, selector: selector, name: $0, object: object) }
    }

    func postNotification(_ name: Notification.Name) {
        post(name: name, object: nil)
    }
}
