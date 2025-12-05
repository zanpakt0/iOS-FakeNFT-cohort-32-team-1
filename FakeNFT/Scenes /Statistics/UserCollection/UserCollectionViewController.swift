import UIKit
import Combine

final class UserCollectionViewController: UIViewController, LoadingView {

    // MARK: - Private Properties
    private let viewModel: UserCollectionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .black 
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    lazy var containerForActivityIndicator: UIView = {
        let containerForActivityIndicator = UIView()
        containerForActivityIndicator.backgroundColor = .forActivityIndicatorBackground
        containerForActivityIndicator.layer.cornerRadius = 8
        containerForActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerForActivityIndicator.widthAnchor.constraint(equalToConstant: 82),
            containerForActivityIndicator.heightAnchor.constraint(equalToConstant: 82)
        ])
        
        return containerForActivityIndicator
    }()
    lazy var collectionViewWithNfts: UICollectionView = {
        let collectionViewWithNfts = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        return collectionViewWithNfts
    }()
    
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
        
        view.backgroundColor = .forViewBackground
        navigationController?.navigationBar.tintColor = .closeButton
        
        setupTitle()
        addSubviews()
        setupConstraints()
        
        bindViewModel()
    }
    
    // MARK: - Private Methods
    private func setupTitle() {
        let title = NSLocalizedString("UserCollection.tite", comment: "")
        navigationItem.title = title
    }
    
    private func addSubviews() {
        view.addSubview(containerForActivityIndicator)
        containerForActivityIndicator.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerForActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerForActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerForActivityIndicator.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerForActivityIndicator.centerYAnchor)
        ])
    }

    private func showNeedViewsInScreen(needToShowLoadingIndicator: UIStateForLoader) {
        switch needToShowLoadingIndicator {
        case .showLoaderHideViews:
            self.containerForActivityIndicator.isHidden = false
            self.showLoading()
            self.collectionViewWithNfts.isHidden = true
        case .showViewsHideLoader:
            self.containerForActivityIndicator.isHidden = true
            self.hideLoading()
            self.collectionViewWithNfts.isHidden = false
        case .showBoth:
            self.containerForActivityIndicator.isHidden = false
            self.showLoading()
            self.collectionViewWithNfts.isHidden = false
        case .hideBoth:
            self.containerForActivityIndicator.isHidden = true
            self.hideLoading()
            self.collectionViewWithNfts.isHidden = true
        }
    }
    
    private func bindViewModel() {
        self.viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                case .loading:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideViews)
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                case .error(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
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
