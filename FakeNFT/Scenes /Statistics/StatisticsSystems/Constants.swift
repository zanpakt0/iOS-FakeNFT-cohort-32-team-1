import CoreFoundation
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
