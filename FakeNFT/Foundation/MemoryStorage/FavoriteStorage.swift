import Foundation

protocol FavoriteNftStorage: AnyObject {
    func saveFavoriteNft(_ catalog: [String])
    func getFavoriteNft() -> [String]?
}

final class FavoriteNftStorageImpl: FavoriteNftStorage {
    private var storage: [String] = []

    private let syncQueue = DispatchQueue(label: "sync-favorite-queue")

    func saveFavoriteNft(_ favorites: [String]) {
        syncQueue.sync { [weak self] in
            self?.storage = favorites
        }
    }

    func getFavoriteNft() -> [String]? {
        syncQueue.sync {
            storage
        }
    }
}
