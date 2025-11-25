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
    init(СatalogProvider: CatalogProvider) {
        self.catalog = []
        self.catalogProvider = СatalogProvider
        СatalogProvider.loadCatalog { catalogItems in
            self.catalog = catalogItems
        }
    }
    
    func sortByName() {
        catalog = catalog.sorted(by: { $0.title < $1.title })
    }
    
    func sortByCountOfNfts() {
        catalog = catalog.sorted(by: { $0.count > $1.count })
    }
}
