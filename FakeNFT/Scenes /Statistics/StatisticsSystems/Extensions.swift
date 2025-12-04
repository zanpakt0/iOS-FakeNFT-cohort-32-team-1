import UIKit
extension UIViewController: ErrorView {
    func universalErrorAlert(handler: @escaping () -> Void) {
        let retryActionText = NSLocalizedString("Statistics.errorAlert.retryAction.text", comment: "")
        let errorModel = ErrorModel(
            message: "",
            actionText: retryActionText,
            action: handler
        )
        
        let title = NSLocalizedString("Statistics.errorAlert.title", comment: "")
        
        let retryAction = UIAlertAction(title: errorModel.actionText, style: .default) { _ in
            errorModel.action()
        }
        
        let cancelActionText = NSLocalizedString("Statistics.errorAlert.cancelAction.text", comment: "")
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel)
        
        self.showErrorAlertWithTwoButtons(titleOfAlert: title, firstAction: cancelAction, secondAction: retryAction)
    }
}
