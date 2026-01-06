import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let deviceVC = DeviceViewController()
        deviceVC.title = "Gentris's piPhone"
        deviceVC.navigationItem.largeTitleDisplayMode = .always
        deviceVC.tabBarItem = UITabBarItem(
            title: "Device",
            image: UIImage(systemName: "antenna.radiowaves.left.and.right"),
            tag: 0
        )

        let appsVC = AppsViewController()
        appsVC.title = "Apps"
        appsVC.navigationItem.largeTitleDisplayMode = .always
        appsVC.tabBarItem = UITabBarItem(
            title: "Apps",
            image: UIImage(systemName: "square.grid.2x2"),
            tag: 1
        )

        let terminalVC = TerminalViewController()
        terminalVC.title = "Terminal"
        terminalVC.navigationItem.largeTitleDisplayMode = .always
        terminalVC.tabBarItem = UITabBarItem(
            title: "Terminal",
            image: UIImage(systemName: "terminal"),
            tag: 2
        )

        let deviceNav = UINavigationController(rootViewController: deviceVC)
        deviceNav.navigationBar.prefersLargeTitles = true

        let appsNav = UINavigationController(rootViewController: appsVC)
        appsNav.navigationBar.prefersLargeTitles = true

        let terminalNav = UINavigationController(rootViewController: terminalVC)
        terminalNav.navigationBar.prefersLargeTitles = true

        viewControllers = [deviceNav, appsNav, terminalNav]
        selectedIndex = 0
    }
}
