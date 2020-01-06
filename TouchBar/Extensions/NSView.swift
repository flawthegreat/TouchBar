extension NSView {
    convenience init(x: CGFloat, width: CGFloat) {
        self.init(frame: NSRect(x: x, y: 0, width: width, height: TouchBar.size.height))
    }


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
        NSView.animate(withDuration: TouchBar.animationDuration, changes: { _ in
            animator().alphaValue = 1
        }, completionHandler: {
            NSView.animate(withDuration: TouchBar.animationDuration) { _ in
                self.animator().alphaValue = 0
            }
        })
    }
}
