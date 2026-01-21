import UIKit
import Combine

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackground
        
        bindViewModel()
        
        viewModel.fetchProfileInfo()
    }
    
    // MARK: - Private Methods
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle: break
                    
                case .loading: break
                    
                case .loaded(let profile): break
                    
                case .error(_): break
                    
                }
            }
            .store(in: &cancellables)
    }
}
