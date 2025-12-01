import UIKit
import Combine

final class UserCollectionViewController: UIViewController {

    // MARK: - Private Properties
    private let viewModel: UserCollectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: UserCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .forViewBackgound
        navigationController?.navigationBar.tintColor = .closeButton
        
        let title = NSLocalizedString("UserCollection.tite", comment: "")
        navigationItem.title = title
    }
}
