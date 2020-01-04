extension NotificationCenter {
    func addObserver(_ observer: Any, selector: Selector, names: [NSNotification.Name], object: Any?) {
        names.forEach { addObserver(observer, selector: selector, name: $0, object: object) }
    }
}
