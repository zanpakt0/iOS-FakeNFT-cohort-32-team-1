import UIKit
import Combine

final class FavouriteNftViewController: UIViewController {

    // MARK: - Private Properties
    private let viewModel: FavouriteNftViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    init(viewModel: FavouriteNftViewModel) {
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
        
        viewModel.loadData()
    }
    
    // MARK: - Private Methods
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
                case .errorWhenTapOnButtonsInCell(_):
                    break
                }
            }
            .store(in: &cancellables)
        
    }
}
