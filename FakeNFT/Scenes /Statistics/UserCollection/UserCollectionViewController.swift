import UIKit
import Combine

// MARK: - Need enums
enum UserCollectionViewControllerLayout {
    static let containerForActivityIndicatorCornerRadius: CGFloat = 8
    static let containerForActivityIndicatorSizes: CGFloat = 82
    
    static let collectionViewWithNftsTop: CGFloat = 20
    static let collectionViewWithNftsLeading: CGFloat = 16
    static let collectionViewWithNftsTrailing: CGFloat = -17
    
    static let horizontlSpacingBetweenCells: CGFloat = 9
    static let verticalSpacingBetweenCells: CGFloat = 8
    static let cellHeight: CGFloat = 192
    
    static let itemsPerRowInCollectionView: CGFloat = 3
    static let numberOfSectionsInCollectionView: Int = 1
}

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
    private lazy var containerForActivityIndicator: UIView = {
        let containerForActivityIndicator = UIView()
        containerForActivityIndicator.backgroundColor = .forActivityIndicatorBackground
        containerForActivityIndicator.layer.cornerRadius = UserCollectionViewControllerLayout.containerForActivityIndicatorCornerRadius
        containerForActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerForActivityIndicator.widthAnchor.constraint(equalToConstant: UserCollectionViewControllerLayout.containerForActivityIndicatorSizes),
            containerForActivityIndicator.heightAnchor.constraint(equalToConstant: UserCollectionViewControllerLayout.containerForActivityIndicatorSizes)
        ])
        
        return containerForActivityIndicator
    }()
    private lazy var collectionViewWithNfts: UICollectionView = {
        let collectionViewWithNfts = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionViewWithNfts.delegate = self
        collectionViewWithNfts.dataSource = self
        collectionViewWithNfts.alwaysBounceVertical = true
        collectionViewWithNfts.backgroundColor = .forViewBackground
        
        collectionViewWithNfts.register(
            UserCollectionViewCell.self,
            forCellWithReuseIdentifier: UserCollectionViewCell.reuseIdentifier)
        
        collectionViewWithNfts.translatesAutoresizingMaskIntoConstraints = false
        
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
        view.addSubview(collectionViewWithNfts)
        
        containerForActivityIndicator.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerForActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerForActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerForActivityIndicator.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerForActivityIndicator.centerYAnchor),
            
            collectionViewWithNfts.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UserCollectionViewControllerLayout.collectionViewWithNftsTop),
            collectionViewWithNfts.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UserCollectionViewControllerLayout.collectionViewWithNftsLeading),
            collectionViewWithNfts.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: UserCollectionViewControllerLayout.collectionViewWithNftsTrailing),
            collectionViewWithNfts.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
                    if viewModel.nftList.isEmpty {
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideViews)
                    } else {
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showBoth)
                    }
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                    collectionViewWithNfts.reloadData()
                case .error(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                    showErrorAlertWhenLoadingEverything()
                case .errorWhenTapOnButtonsInCell(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                    showErrorAlertWhenTappingButtonsInCell()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlertWhenLoadingEverything() {
        self.universalErrorAlert { [weak self] in
            guard let self,
            let nftIdsList = self.viewModel.nftIdsList else { return }
            self.viewModel.loadEverything(listOfNfts: nftIdsList)
        }
    }
    
    private func showErrorAlertWhenTappingButtonsInCell() {
        let message = NSLocalizedString("UserCollection.errorAlert.message", comment: "")
        let actionText = NSLocalizedString("UserCollection.errorAlert.actionText", comment: "")
        
        let errorModel = ErrorModel(message: message,
                                    actionText: actionText) { return }
        
        self.showError(errorModel)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension UserCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        UserCollectionViewControllerLayout.numberOfSectionsInCollectionView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.nftList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as? UserCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(nftData: viewModel.nftList[indexPath.row])
        let nftId = viewModel.nftList[indexPath.row].nft.id

        cell.onFavouritesButtonTapped = { [weak self] isFavourite in
            self?.viewModel.likeOrDislikeNft(isItLike: !isFavourite, nftId: nftId)
        }
        
        cell.onCartButtonTapped = { [weak self] isInCart in
            self?.viewModel.orderOrUnorderNft(isInCart: !isInCart, nftId: nftId)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = UserCollectionViewControllerLayout.horizontlSpacingBetweenCells
        let itemsPerRow: CGFloat = UserCollectionViewControllerLayout.itemsPerRowInCollectionView
        
        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / itemsPerRow
        
        return CGSize(width: cellWidth, height: UserCollectionViewControllerLayout.cellHeight)
        }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        UserCollectionViewControllerLayout.horizontlSpacingBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        UserCollectionViewControllerLayout.verticalSpacingBetweenCells
    }
}
