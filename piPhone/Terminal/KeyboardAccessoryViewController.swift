import SwiftUI
import UIKit

protocol SpecialKeysDelegate {
    func didClickSpecialKey(key: Key)
    func didClickControlKey(key: Key)
}

final class KeyboardAccessoryViewController: UIInputViewController {

    // Public
    var keysDelegate: SpecialKeysDelegate?
    var height: CGFloat = 55  // total accessory height (bar + real gap)

    private var hostingController: UIHostingController<AnyView>?

    override func loadView() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        let inputView = UIInputView(frame: frame, inputViewStyle: .keyboard)
        inputView.backgroundColor = .clear
        inputView.autoresizingMask = [.flexibleWidth]
        self.view = inputView

        preferredContentSize = CGSize(width: frame.width, height: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let accessoryView = KeyboardAccessoryView { [weak self] name in
            guard let self else { return }

            if name == .ctrl {
                self.keysDelegate?.didClickControlKey(key: keys[name]!)
            } else {
                self.keysDelegate?.didClickSpecialKey(key: keys[name]!)
            }
        }

        // Put bar at top; empty space at bottom becomes a REAL "margin" to the keyboard
        let root = VStack(spacing: 0) {
            accessoryView
            Spacer(minLength: 0)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        let hc = UIHostingController(rootView: AnyView(root))
        hostingController = hc

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        hc.view.backgroundColor = .clear
        hc.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Keep accessory height stable (WKWebView can be finicky)
        if view.bounds.height != height {
            var f = view.frame
            f.size.height = height
            view.frame = f
        }
        preferredContentSize = CGSize(width: view.bounds.width, height: height)
    }
}
