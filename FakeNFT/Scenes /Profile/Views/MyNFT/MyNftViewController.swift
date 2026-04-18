import UIKit
import Combine

final class MyNftViewController: UIViewController, LoadingView {
    
    // MARK: - Private Properties
    private let viewModel: MyNftViewModel
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
        let textForEmptyPage = NSLocalizedString("myNft.emptyPage", comment: "")
        
        emptyPageLabel.textAlignment = .center
        emptyPageLabel.text = textForEmptyPage
        emptyPageLabel.font = .bodyBold
        emptyPageLabel.textColor = .segmentActive
        emptyPageLabel.isHidden = true
        emptyPageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return emptyPageLabel
    }()
    private let tableViewWithNfts: UITableView = {
        let tableViewWithNfts = UITableView()
        tableViewWithNfts.register(MyNftTableViewCell.self, forCellReuseIdentifier: MyNftTableViewCell.reusedIdentifier)
        tableViewWithNfts.separatorStyle = .none
        tableViewWithNfts.rowHeight = 140
        tableViewWithNfts.backgroundColor = .forViewBackground
        tableViewWithNfts.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithNfts
    }()
    private let filterButton: UIButton = {
        let filterButton = UIButton(type: .system)
        let imageForButton = UIImage(resource: .sortCatalogButton)
        filterButton.setImage(imageForButton, for: .normal)
        filterButton.tintColor = .segmentActive
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 42),
            filterButton.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        return filterButton
    }()
    
    // MARK: - Initializers
    init(viewModel: MyNftViewModel) {
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
        
        setupTableView()
        addSubviews()
        addTargetsForButtons()
        bindViewModel()
        
        viewModel.downloadData()
    }
    
    // MARK: - Private Methods
    
    @objc private func filterButtonClicked() {
        let titleForByPrice = NSLocalizedString("myNft.filter.byPrice", comment: "")
        let titleForByRating = NSLocalizedString("myNft.filter.byRating", comment: "")
        let titleForByName = NSLocalizedString("myNft.filter.byName", comment: "")
        
        let byPriceAction = UIAlertAction(title: titleForByPrice, style: .default) {_ in 
            self.viewModel.setFilterTypeOfProfileToStorage(filterType: .byPrice)
            self.tableViewWithNfts.reloadData()
        }
        
        let byRatingAction = UIAlertAction(title: titleForByRating, style: .default) {_ in
            self.viewModel.setFilterTypeOfProfileToStorage(filterType: .byRating)
            self.tableViewWithNfts.reloadData()
        }
        
        let byNameAction = UIAlertAction(title: titleForByName, style: .default) {_ in
            self.viewModel.setFilterTypeOfProfileToStorage(filterType: .byName)
            self.tableViewWithNfts.reloadData()
        }
        
        showFilterActionSheet(firstAction: byPriceAction, secondAction: byRatingAction, thirdAction: byNameAction)
    }
    
    private func setupTableView() {
        tableViewWithNfts.delegate = self
        tableViewWithNfts.dataSource = self
    }
    
    private func addSubviews() {
        view.addSubview(emptyPageLabel)
        view.addSubview(tableViewWithNfts)
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
            
            tableViewWithNfts.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableViewWithNfts.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewWithNfts.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewWithNfts.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addTargetsForButtons() {
        filterButton.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
    }
    
    private func setupNavBar() {
        let title = NSLocalizedString("profile.myNft", comment: "")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
        navigationItem.title = title
    }
    
    private func showNeedViewsInScreen(whatShouldBeShown: UIStateForLoader) {
        switch whatShouldBeShown {
        case .showLoaderHideViews:
            self.containerForActivityIndicator.isHidden = false
            showLoading()
            self.tableViewWithNfts.isHidden = true
            self.emptyPageLabel.isHidden = true
        case .showViewsHideLoader:
            self.containerForActivityIndicator.isHidden = true
            hideLoading()
            self.tableViewWithNfts.isHidden = false
            self.emptyPageLabel.isHidden = true
        case .showBoth:
            self.containerForActivityIndicator.isHidden = false
            showLoading()
            self.tableViewWithNfts.isHidden = false
            self.emptyPageLabel.isHidden = true
        case .hideBoth:
            self.containerForActivityIndicator.isHidden = true
            hideLoading()
            self.tableViewWithNfts.isHidden = true
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
                    showNeedViewsInScreen(whatShouldBeShown: .showBoth)
                case .loading:
                    if self.viewModel.listOfNfts.isEmpty {
                        showNeedViewsInScreen(whatShouldBeShown: .showLoaderHideViews)
                    } else {
                        showNeedViewsInScreen(whatShouldBeShown: .showBoth)
                    }
                case .loaded:
                    if self.viewModel.listOfNfts.isEmpty {
                        makeEmptyPage()
                    } else {
                        setupNavBar()
                        showNeedViewsInScreen(whatShouldBeShown: .showViewsHideLoader)
                        self.tableViewWithNfts.reloadData()
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
        tableViewWithNfts.isHidden = true
        containerForActivityIndicator.isHidden = true
    }
    
    private func showErrorAlertWhenLoadingEverything() {
        universalErrorAlert { [weak self] in
            guard let self else { return }
            self.viewModel.downloadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MyNftViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.listOfNfts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyNftTableViewCell.reusedIdentifier, for: indexPath) as? MyNftTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(nftData: viewModel.listOfNfts[indexPath.row])
        
        cell.didHeartButtonTapped = { [weak self] in
            guard let self else { return }
            
            self.viewModel.likeOrDislikeNft(
                isItLike: !self.viewModel.listOfNfts[indexPath.row].isFavourite,
                nftId: self.viewModel.listOfNfts[indexPath.row].nft.id
            )
            
        }
        
        return cell
    }
}
