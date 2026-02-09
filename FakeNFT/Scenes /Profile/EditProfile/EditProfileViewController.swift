import UIKit
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func bindViewModel() {
        viewModel.$state
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
                    break
                }
            }
            .store(in: &cancellables)
    }
}

