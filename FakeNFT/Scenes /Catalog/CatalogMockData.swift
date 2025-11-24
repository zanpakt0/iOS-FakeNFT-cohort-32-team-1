import UIKit

struct CatalogItem {
    let image: UIImage
    let title: String
    let count: Int
}

let mockCatalogData: [CatalogItem] = [
    CatalogItem(image: UIImage(systemName: "cube.box.fill")!, title: "Art Blocks", count: 12),
    CatalogItem(image: UIImage(systemName: "gamecontroller.fill")!, title: "Gaming NFTs", count: 8),
    CatalogItem(image: UIImage(systemName: "photo.on.rectangle")!, title: "Photography", count: 19),
    CatalogItem(image: UIImage(systemName: "paintbrush.pointed.fill")!, title: "Digital Art", count: 30),
    CatalogItem(image: UIImage(systemName: "music.note.list")!, title: "Music NFTs", count: 7),
    CatalogItem(image: UIImage(systemName: "person.3.fill")!, title: "Community", count: 5)
]
