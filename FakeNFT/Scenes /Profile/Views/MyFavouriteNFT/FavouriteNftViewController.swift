import UIKit
import Combine

final class FavouriteNftViewController: UIViewController, LoadingView {

    // MARK: - Private Properties
    private let viewModel: FavouriteNftViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    private let containerForActivityIndicator: UIView = {
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
    private let emptyPageLabel: UILabel = {
        let emptyPageLabel = UILabel()
        let textForEmptyPage = NSLocalizedString("favouriteNft.emptyPage", comment: "")
        
        emptyPageLabel.textAlignment = .center
        emptyPageLabel.text = textForEmptyPage
        emptyPageLabel.font = .bodyBold
        emptyPageLabel.textColor = .segmentActive
        emptyPageLabel.isHidden = true
        emptyPageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return emptyPageLabel
    }()
    private let collectionWithNfts: UICollectionView = {
        let collectionWithNfts = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionWithNfts.alwaysBounceVertical = true
        collectionWithNfts.backgroundColor = .forViewBackground
        collectionWithNfts.register(FavouriteNftViewCell.self, forCellWithReuseIdentifier: FavouriteNftViewCell.reusedIdentifier)
        
        collectionWithNfts.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionWithNfts
    }()
    
    
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
        
        setupCollectionView()
        addSubviews()
        bindViewModel()
        
        viewModel.loadData()
    }
    
    // MARK: - Private Methods
    private func addSubviews() {
        view.addSubview(emptyPageLabel)
        view.addSubview(collectionWithNfts)
        view.addSubview(containerForActivityIndicator)
        
        containerForActivityIndicator.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerForActivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerForActivityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerForActivityIndicator.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerForActivityIndicator.centerYAnchor),
            
            emptyPageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyPageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionWithNfts.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionWithNfts.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionWithNfts.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionWithNfts.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionWithNfts.delegate = self
        collectionWithNfts.dataSource = self
    }
    
    private func setupNavBar() {
        let title = NSLocalizedString("profile.favouriteNft", comment: "")
        
        navigationItem.title = title
    }
    
    private func showNeedViewsInScreen(whatShouldBeShown: UIStateForLoader) {
        switch whatShouldBeShown {
        case .showLoaderHideViews:
            self.containerForActivityIndicator.isHidden = false
            showLoading()
            self.collectionWithNfts.isHidden = true
            self.emptyPageLabel.isHidden = true
        case .showViewsHideLoader:
            self.containerForActivityIndicator.isHidden = true
            hideLoading()
            self.collectionWithNfts.isHidden = false
            self.emptyPageLabel.isHidden = true
        case .showBoth:
            self.containerForActivityIndicator.isHidden = false
            showLoading()
            self.collectionWithNfts.isHidden = false
            self.emptyPageLabel.isHidden = true
        case .hideBoth:
            self.containerForActivityIndicator.isHidden = true
            hideLoading()
            self.collectionWithNfts.isHidden = true
            self.emptyPageLabel.isHidden = true
        }
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(whatShouldBeShown: .hideBoth)
                case .loading:
                    if self.viewModel.listOfNfts.isEmpty {
                        showNeedViewsInScreen(whatShouldBeShown: .showLoaderHideViews)
                    } else {
                        showNeedViewsInScreen(whatShouldBeShown: .showBoth)
                    }
                case .loaded(_):
                    if self.viewModel.listOfNfts.isEmpty {
                        makeEmptyPage()
                    } else {
                        setupNavBar()
                        showNeedViewsInScreen(whatShouldBeShown: .showViewsHideLoader)
                        collectionWithNfts.reloadData()
                    }
                case .error(_):
                    showNeedViewsInScreen(whatShouldBeShown: .hideBoth)
                    showErrorAlertWhenLoadingEverything()
                case .errorWhenTapOnButtonsInCell(_):
                    showNeedViewsInScreen(whatShouldBeShown: .showViewsHideLoader)
                    showErrorAlertWhenTappingButtonsInCell()
                }
            }
            .store(in: &cancellables)
    }
    
    private func makeEmptyPage() {
        emptyPageLabel.isHidden = false
        collectionWithNfts.isHidden = true
        containerForActivityIndicator.isHidden = true
        
        navigationItem.title = nil
    }
    
    private func showErrorAlertWhenLoadingEverything() {
        universalErrorAlert { [weak self] in
            guard let self else { return }
            self.viewModel.loadData()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FavouriteNftViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.listOfNfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteNftViewCell.reusedIdentifier, for: indexPath) as? FavouriteNftViewCell else { return UICollectionViewCell()
        }
        
        cell.configure(nftData: viewModel.listOfNfts[indexPath.row])
        
        cell.didHeartButtonTapped = { [weak self] in
            guard let self else { return }
            self.viewModel.dislikeNft(nftId: self.viewModel.listOfNfts[indexPath.row].nft.id)
        }
        
        return cell
    }
}

extension FavouriteNftViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 168, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        7
    }
}
