import Foundation

extension TouchBar {
    public class Item: NSView {

        public enum Alignment {
            case left
            case right
        }

        public let alignment: Alignment


        init(alignment: Alignment, width: CGFloat) {
            self.alignment = alignment

            super.init(frame: NSRect(x: 0, y: 0, width: width, height: NSTouchBar.size.height))
            
            set(width: width)
        }

        required init?(coder: NSCoder) { fatalError() }


        public func set(width: CGFloat, animated: Bool = false) {
            NSView.animate(withDuration: animated ? animationDuration : 0) { _ in
                animator().frame.size.width = width
                NotificationCenter.default.post(
                    name: Notification.touchBarItemWidthDidChange,
                    object: nil
                )
            }
        }
    }
}
