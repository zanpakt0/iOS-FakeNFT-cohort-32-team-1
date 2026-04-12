import UIKit
extension UIViewController: ErrorView {
    func universalErrorAlert(handler: @escaping () -> Void) {
        let retryActionText = NSLocalizedString("common.retry", comment: "")
        let errorModel = ErrorModel(
            message: "",
            actionText: retryActionText,
            action: handler
        )
        
        let title = NSLocalizedString("statistics.error.title", comment: "")
        
        let retryAction = UIAlertAction(title: errorModel.actionText, style: .default) { _ in
            errorModel.action()
        }
        
        let cancelActionText = NSLocalizedString("common.cancel", comment: "")
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel)
        
        showErrorAlertWithTwoButtons(titleOfAlert: title, firstAction: cancelAction, secondAction: retryAction)
    }
}

extension UIViewController {
    func universalOpenPage(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = ConstantsForStatistics.transitionDurationWhenOpenPage
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationItem.backButtonTitle = ""
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: false)
    }
}

extension UIView {
    func createDefaultStar() -> UIImageView {
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
    
    func visualizeStars(rating: Int, stars: [UIImageView]) {
        for (index, star) in stars.enumerated() {
            star.tintColor = index <= rating ? .yellowForStars : .segmentInactive
        }
    }
}
