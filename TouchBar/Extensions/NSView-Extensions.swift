extension NSView {
    static func animate(
        withDuration duration: TimeInterval,
        changes: (NSAnimationContext) -> Void,
        completionHandler: (() -> Void)?
    ) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            changes(context)
        }, completionHandler: completionHandler)
    }

    static func animate(withDuration duration: TimeInterval, changes: (NSAnimationContext) -> Void) {
        animate(withDuration: duration, changes: changes, completionHandler: nil)
    }

    @objc
    func flash() {
        NSView.animate(withDuration: Constants.animationDuration, changes: { _ in
            animator().alphaValue = 1
        }, completionHandler: {
            NSView.animate(withDuration: Constants.animationDuration) { _ in
                self.animator().alphaValue = 0
            }
        })
    }
}
