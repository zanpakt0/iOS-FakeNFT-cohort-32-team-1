import Foundation

protocol CatalogStorage: AnyObject {
    func saveCatalog(_ catalog: [Catalog])
    func getCatalog() -> [Catalog]?
}

final class CatalogStorageImpl: CatalogStorage {
    private var storage: [Catalog] = []

    private let syncQueue = DispatchQueue(label: "sync-catalog-queue")

    func saveCatalog(_ catalog: [Catalog]) {
        syncQueue.sync { [weak self] in
            self?.storage = catalog
        }
    }

    func getCatalog() -> [Catalog]? {
        syncQueue.sync {
            storage
        }
    }
}
