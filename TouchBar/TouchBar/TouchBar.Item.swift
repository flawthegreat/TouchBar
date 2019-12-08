import Foundation

extension TouchBar {
    public class Item: NSView {

        enum Alignment {
            case left
            case right
        }

        let alignment: Alignment


        init(alignment: Alignment, width: CGFloat) {
            self.alignment = alignment

            super.init(frame: NSRect(x: 0, y: 0, width: width, height: NSTouchBar.size.height))
            
            setWidth(width)
        }

        required init?(coder: NSCoder) { fatalError() }


        func setWidth(_ width: CGFloat, animated: Bool = false) {
            NSView.animate(withDuration: animated ? Constants.animationDuration : 0, changes: { _ in
                animator().frame.size.width = width
            }, completionHandler: {
                NotificationCenter.default.post(
                    name: .touchBarItemWidthDidChange,
                    object: nil
                )
            })
        }

        func update() {}
    }
}
