import UIKit

enum BooklyTheme {
    static let navy = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    static let navy2 = UIColor(red: 0.05, green: 0.15, blue: 0.38, alpha: 1.0)
    static let indigo = UIColor(red: 0.30, green: 0.22, blue: 0.88, alpha: 1.0)
    static let softIndigo = UIColor(red: 0.30, green: 0.22, blue: 0.88, alpha: 0.10)
    static let background = UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1.0)
    static let card = UIColor.white
    static let mutedText = UIColor(red: 0.54, green: 0.56, blue: 0.62, alpha: 1.0)
    static let border = UIColor(red: 0.88, green: 0.89, blue: 0.94, alpha: 1.0)
    
    static func applyGlobalAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = navy
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 34)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .white
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.94)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = indigo
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray2
    }
}

extension UIView {
    func applyBooklyCardStyle(
        cornerRadius: CGFloat = 18,
        shadowOpacity: Float = 0.08,
        shadowRadius: CGFloat = 12,
        shadowOffset: CGSize = CGSize(width: 0, height: 6)
    ) {
        backgroundColor = BooklyTheme.card
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
}

extension UIButton {
    func applyBooklyPrimaryButtonStyle(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        setTitleColor(.white, for: .normal)
        backgroundColor = BooklyTheme.indigo
        layer.cornerRadius = 14
    }
    
    func applyBooklyOutlineButtonStyle(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 14)
        setTitleColor(BooklyTheme.indigo, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = BooklyTheme.indigo.cgColor
    }
}
