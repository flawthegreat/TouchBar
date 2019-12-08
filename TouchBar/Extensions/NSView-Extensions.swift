import Foundation

public extension NSView {
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

    static func animate(
        withDuration duration: TimeInterval,
        changes: (NSAnimationContext) -> Void
    ) {
        animate(withDuration: duration, changes: changes, completionHandler: nil)
    }
}
