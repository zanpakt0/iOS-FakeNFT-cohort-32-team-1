import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Public Properties
    var servicesAssembly: ServicesAssembly!
    
    // MARK: - Private Properties
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("tab.profile", comment: ""),
        image: UIImage(resource: .profileTabBarIcon),
        tag: 0
    )
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("tab.catalog", comment: ""),
        image: UIImage(resource: .catalogTabBarIcon),
        tag: 1
    )
    
    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("tab.cart", comment: ""),
        image: UIImage(resource: .cartTabBarIcon),
        tag: 2
    )
    
    private let statisticsTabBarItem = UITabBarItem(
        title: NSLocalizedString("tab.statistics", comment: ""),
        image: UIImage(resource: .statisticsTabBarIcon),
        tag: 3
    )
    
    private lazy var profileNav: UINavigationController = {
        let viewModel = ProfileViewModel(servicesAssembly: servicesAssembly)
        let profileVc = ProfileViewController(viewModel: viewModel)
        profileVc.tabBarItem = profileTabBarItem
        
        return UINavigationController(rootViewController: profileVc)
    }()
    private lazy var cartNav: UINavigationController = {
        let cartService = CartServiceImpl(client: DefaultNetworkClient())
        let nftService = NFTServiceImpl()
        let cartViewModel = CartViewModel(
            nftService: nftService,
            cartService: cartService
        )

        let paymentService = PaymentServiceImpl(
            client: DefaultNetworkClient(),
            baseURL: RequestConstants.baseURL
        )

        let paymentViewModel = PaymentViewModel(
            paymentService: paymentService, nftIds: []
        )

        let cartVC = CartViewController(
            cartViewModel: cartViewModel,
            paymentService: paymentService,
            paymentViewModel: paymentViewModel
        )

        cartVC.tabBarItem = cartTabBarItem
        return UINavigationController(rootViewController: cartVC)
    }()
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
        
        viewControllers = [profileNav, catalogViewController, cartNav, statisticsNav]
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .forViewBackground
        
        appearance.stackedLayoutAppearance.normal.iconColor = .segmentActive
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.segmentActive
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        } else {
            print("Error")
        }
    }
}
