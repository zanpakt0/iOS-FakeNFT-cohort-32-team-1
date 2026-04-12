import CoreFoundation
import Kingfisher
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

enum BaseStateForQuery {
    case idle
    case loading
    case loaded
    case error(Error)
}

enum ConstantsForStatistics {
    static let pageSize: Int = 10
    static let keyForFilterTypeInStatistics: String = "filterTypeInStatistics"
    static let transitionDurationWhenOpenPage: CFTimeInterval = 0.01
}

final class Constants {
    static let defaultImage = UIImage(systemName: "person.crop.circle.fill")?.withTintColor(UIColor.forDefaultAvatarBackground, renderingMode: .alwaysOriginal)
    
    static let dispatchGroup = DispatchGroup()
    static let processorWithTwelveCornerRadius = RoundCornerImageProcessor(cornerRadius: 12)
    
    static func replaceDotsWithCommas(price: Decimal) -> String {
        let string = "\(price)"
        return "\(string.replacingOccurrences(of: ".", with: ",")) ETH"
    }
}
