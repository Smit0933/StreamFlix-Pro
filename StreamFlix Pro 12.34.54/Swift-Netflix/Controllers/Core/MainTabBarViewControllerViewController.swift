import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // MARK: - View Controllers
        let homeVC = HomeViewController()
        let upcomingVC = UpcomingViewController()
        let searchVC = SearchViewController()
        let downloadsVC = DownloadsViewController()
        
        // Wrap each in a navigation controller
        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: upcomingVC)
        let nav3 = UINavigationController(rootViewController: searchVC)
        let nav4 = UINavigationController(rootViewController: downloadsVC)
        let watchlistVC = UINavigationController(rootViewController: WatchlistViewController())
        
        // Configure tab bar items for each nav controller
        nav1.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: nil
        )
        nav2.tabBarItem = UITabBarItem(
            title: "Coming Soon",
            image: UIImage(systemName: "play.circle"),
            selectedImage: nil
        )
        nav3.tabBarItem = UITabBarItem(
            title: "Top Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: nil
        )
        nav4.tabBarItem = UITabBarItem(
            title: "Downloads",
            image: UIImage(systemName: "arrow.down.to.line"),
            selectedImage: nil
        )
        
        // Configure the Watchlist tab bar item
        watchlistVC.tabBarItem = UITabBarItem(
            title: "Watchlist",
            image: UIImage(systemName: "bookmark"),
            selectedImage: nil
        )
        
        // MARK: - Tab Bar Appearance (iOS 15+)
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // MARK: - Configure Tab Bar
        tabBar.tintColor = .label
        view.backgroundColor = .systemBackground
        
        // MARK: - Set the Array of View Controllers (Include Watchlist)
        setViewControllers([nav1, nav2, nav3, nav4, watchlistVC], animated: true)
        
        // Make sure Home (first tab) is selected by default
        selectedIndex = 0
    }
}
