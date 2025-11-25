import UIKit
import Combine

struct CatalogItem {
    let image: UIImage
    let title: String
    let count: Int
}

final class CatalogViewModel {
    //MARK: - Constants
    @Published var catalog: [CatalogItem]
    
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(catalogProvider: CatalogProvider) {
        self.catalog = []
        self.catalogProvider = catalogProvider
        catalogProvider.loadCatalog { catalogItems in
            self.catalog = catalogItems
        }
    }
}
