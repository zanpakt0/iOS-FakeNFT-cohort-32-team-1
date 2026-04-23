import UIKit
import Combine

final class FavouriteNftViewController: UIViewController {

    // MARK: - Private Properties
    private let viewModel: FavouriteNftViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
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
        view.addSubview(collectionWithNfts)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
                    if self.viewModel.listOfNfts.isEmpty {
                        print("Нет ничего в списке")
                    } else {
                        setupNavBar()
                        collectionWithNfts.reloadData()
                    }
                case .error(_):
                    break
                case .errorWhenTapOnButtonsInCell(_):
                    break
                }
            }
            .store(in: &cancellables)
        
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
