import Foundation

protocol NftCollectionStorage: AnyObject {
    func saveCollection(_ colection: [Nft])
    func getCollection() -> [Nft]?
}

final class NftCollectionStorageImpl: NftCollectionStorage {
    private var storage: [Nft] = []

    private let syncQueue = DispatchQueue(label: "sync-nftCollection-queue")

    func saveCollection(_ collection: [Nft]) {
        syncQueue.async { [weak self] in
            self?.storage = collection
        }
    }

    func getCollection() -> [Nft]? {
        syncQueue.sync {
            storage
        }
    }
}
