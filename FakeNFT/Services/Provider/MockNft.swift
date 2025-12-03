import UIKit

let mockNFTs: [Nft] = [
    Nft(
        name: "Willow",
        images: [
            URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Willow/1.png")!,
            URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Willow/2.png")!,
            URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Willow/3.png")!
        ],
        rating: 5,
        description: "mock",
        price: 3.35,
        author: URL(string: "https://hungry_darwin.fakenfts.org/")!,
        id: "2534F8D8-D524-45E2-B7FE-A990B4E1A772"
    ),
    Nft(
        name: "Peachy",
        images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Willow/1.png")!],
        rating: 4,
        description: "mock",
        price: 2.1,
        author: URL(string: "https://hungry_darwin.fakenfts.org/")!,
        id: "CACD7AFD-FD6F-4395-A9BA-18A05912D716"
    ),
    Nft(
        name: "Cloud Cat",
        images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Yellow/Willow/2.png")!],
        rating: 3,
        description: "mock",
        price: 1.7,
        author: URL(string: "https://hungry_darwin.fakenfts.org/")!,
        id: "B7E9904A-6D98-4607-AC35-459785A07F09"
    )
]
