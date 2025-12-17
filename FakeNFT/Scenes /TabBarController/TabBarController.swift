import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Public Properties
    var servicesAssembly: ServicesAssembly!
    
    // MARK: - Private Properties
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.fill"),
        tag: 0
    )

    private let statisticsTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.statistics", comment: ""),
        image: UIImage(systemName: "flag.2.crossed.fill"),
        tag: 3
    )
    private lazy var statisticsNav: UINavigationController = {
        let viewModel = StatisticsViewModel(servicesAssembly: servicesAssembly)
        let statisticsVc = StatisticsViewController(viewModel: viewModel)
        statisticsVc.tabBarItem = statisticsTabBarItem
        
        return UINavigationController(rootViewController: statisticsVc)
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarAppearance()
        setupTabBarItems()
    }
    
    // MARK: - Private Methods
    private func setupTabBarItems() {
        let catalogViewController = CatalogViewController(
            viewModel: CatalogViewModel(
                catalogProvider: CatalogProvider(
                    networkClient: DefaultNetworkClient(),
                    storage: CatalogStorageImpl())
            ))
        catalogViewController.tabBarItem = catalogTabBarItem

        viewControllers = [catalogViewController, statisticsNav]
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .forViewBackground
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        } else {
            print("Error")
        }
    }
}
