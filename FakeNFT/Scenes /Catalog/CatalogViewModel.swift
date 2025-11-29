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
    @Published var isLoading = false
    
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(catalogProvider: CatalogProvider) {
        self.catalog = []
        self.catalogProvider = catalogProvider
        self.isLoading = true
        catalogProvider.loadCatalog { [weak self] catalogItems in
            guard let self else { return }
            self.catalog = catalogItems
            self.isLoading = false
        }
    }
    
    func sortByName() {
        catalog = catalog.sorted(by: { $0.title < $1.title })
    }
    
    func sortByCountOfNfts() {
        catalog = catalog.sorted(by: { $0.count > $1.count })
    }
    
    func reload() {
        catalogProvider.loadCatalog { [weak self] catalogItems in
            guard let self else { return }
            self.catalog = catalogItems
        }
    }
}
