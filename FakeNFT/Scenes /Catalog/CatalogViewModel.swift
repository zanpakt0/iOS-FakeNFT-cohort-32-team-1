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
    @Published var isLoading: Bool = false
    
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(СatalogProvider: CatalogProvider) {
        self.catalog = []
        self.catalogProvider = СatalogProvider
        self.isLoading = true
        СatalogProvider.loadCatalog { catalogItems in
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
}
