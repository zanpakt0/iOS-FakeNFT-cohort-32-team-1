import CoreFoundation
import UIKit

enum UIStateForLoader {
    case showLoaderHideViews
    case showViewsHideLoader
    case showBoth
    case hideBoth
}

enum FilterType: String {
    case byName = "ByName"
    case byRating = "ByRating"
}

enum ConstantsForStatistics {
    static let pageSize: Int = 10
    static let keyForFilterTypeInStatistics: String = "filterTypeInStatistics"
    static let transitionDurationWhenOpenPage: CFTimeInterval = 0.01
}

final class Constants {
    static let defaultImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(UIColor.forDefaultAvatarBackground, renderingMode: .alwaysOriginal)
    
    static func createDefaultStar() -> UIImageView {
        let exampleImage = UIImage(systemName: "star.fill")
        let star = UIImageView(image: exampleImage)
        star.tintColor = .segmentInactive
        star.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            star.widthAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizeOfStars),
            star.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizeOfStars)
        ])
        
        return star
    }
}
