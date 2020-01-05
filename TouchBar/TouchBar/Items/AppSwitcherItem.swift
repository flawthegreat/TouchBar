final class AppSwitcherItem: TouchBar.Button {

    override init(alignment: Alignment) {
        super.init(alignment: alignment)

        title = "􀚅"
        target = self
        action = #selector(toggleAppSwitcher)
    }

    required init?(coder: NSCoder) { fatalError() }


    @objc
    func toggleAppSwitcher() {
        guard let view = superview as? TouchBar.View else { return }

        view.applicationManager.toggleAppSwitcher()
    }
}
