import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let testCatalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.fill"),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let testCatalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        testCatalogController.tabBarItem = testCatalogTabBarItem
        
        let catalogViewController = CatalogViewController(
            viewModel: CatalogViewModel(
                catalogProvider: CatalogProvider(
                    networkClient: DefaultNetworkClient(),
                    storage: CatalogStorageImpl())
            ))
        catalogViewController.tabBarItem = catalogTabBarItem

        viewControllers = [testCatalogController, catalogViewController]

        view.backgroundColor = .systemBackground
    }
}
