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
        
        setupTitle()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    private func setupTitle() {
        let title = NSLocalizedString("UserCollection.tite", comment: "")
        navigationItem.title = title
    }

    private func bindViewModel() {
        self.viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    break
                case .loaded(_):
                    break
                case .error(_):
                    showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert() {
        self.universalErrorAlert { [weak self] in
            guard let self,
            let nftIdsList = self.viewModel.nftIdsList else { return }
            self.viewModel.fetchNfts(listOfNfts: nftIdsList)
        }
    }
}
