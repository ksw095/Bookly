import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        BooklyTheme.applyGlobalAppearance()
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func makeRootTabBarController() -> UITabBarController {
        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let libraryVC = LibraryViewController()
        let doneVC = DoneViewController()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let searchNav = UINavigationController(rootViewController: searchVC)
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        let doneNav = UINavigationController(rootViewController: doneVC)
        
        homeNav.navigationBar.prefersLargeTitles = false
        searchNav.navigationBar.prefersLargeTitles = false
        libraryNav.navigationBar.prefersLargeTitles = false
        doneNav.navigationBar.prefersLargeTitles = false
        
        homeNav.tabBarItem = makeTabBarItem(
            title: "Bookly",
            imageName: "house",
            selectedImageName: "house.fill"
        )
        
        searchNav.tabBarItem = makeTabBarItem(
            title: "검색",
            imageName: "magnifyingglass",
            selectedImageName: "magnifyingglass"
        )
        
        libraryNav.tabBarItem = makeTabBarItem(
            title: "나의 서재",
            imageName: "books.vertical",
            selectedImageName: "books.vertical.fill"
        )
        
        doneNav.tabBarItem = makeTabBarItem(
            title: "독서 기록",
            imageName: "star",
            selectedImageName: "star.fill"
        )
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            homeNav,
            searchNav,
            libraryNav,
            doneNav
        ]
        
        configureTabBarAppearance(for: tabBarController)
        
        return tabBarController
    }
    
    private func makeTabBarItem(
        title: String,
        imageName: String,
        selectedImageName: String
    ) -> UITabBarItem {
        let item = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            selectedImage: UIImage(systemName: selectedImageName)
        )
        
        item.title = title
        item.imageInsets = .zero
        item.titlePositionAdjustment = .zero
        
        return item
    }
    
    private func configureTabBarAppearance(for tabBarController: UITabBarController) {
        let selectedColor = UIColor(red: 0.31, green: 0.22, blue: 0.88, alpha: 1.0)
        let normalColor = UIColor.black
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.96)
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: normalColor
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: selectedColor
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = .zero
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = .zero
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.normal.iconColor = normalColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.normal.iconColor = normalColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        tabBarController.tabBar.tintColor = selectedColor
        tabBarController.tabBar.unselectedItemTintColor = normalColor
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
