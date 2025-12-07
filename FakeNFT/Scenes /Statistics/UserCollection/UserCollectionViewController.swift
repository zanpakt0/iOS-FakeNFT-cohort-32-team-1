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
    private lazy var containerForActivityIndicator: UIView = {
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
            
            collectionViewWithNfts.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionViewWithNfts.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionViewWithNfts.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
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
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideViews)
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                    collectionViewWithNfts.reloadData()
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
            self.viewModel.loadEverything(listOfNfts: nftIdsList)
        }
    }
}

extension UserCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.nftList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.reuseIdentifier, for: indexPath) as? UserCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(nftData: viewModel.nftList[indexPath.row])
        
        return cell
    }
}

extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let itemsPerRow: CGFloat = 3
        
        let totalSpacing = spacing * (itemsPerRow - 1)
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / itemsPerRow
        
        return CGSize(width: cellWidth, height: 192)
        }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
}
