import UIKit
import Combine

final class CatalogViewController: UIViewController {
    private enum CatalogLayout {
        static let sortButtonTrailing: CGFloat = -9
        static let sortButtonSize: CGFloat = 42
        static let tableViewLeading: CGFloat = 16
        static let tableViewTrailing: CGFloat = -16
        static let tableViewCornerRadius: CGFloat = 12
    }
    
    //MARK: - Constants
    private let viewModel: CatalogViewModel
    private var subscribes = Set<AnyCancellable>()
    
    private let sortByNameTitle: String = NSLocalizedString("catalog.sortByNameTitle", comment: "Sort by name")
    private let sortByCountTitle: String = NSLocalizedString("catalog.sortByCountTitle", comment: "Sort by count of nfts")
    private let alertTitle: String = NSLocalizedString("catalog.alertTitle", comment: "Не удалось загрузить данные")
    private let repeatAlertButton: String = NSLocalizedString("catalog.repeatAlertButton", comment: "Повторить")
    private let cancelAlertButton: String = NSLocalizedString("catalog.cancelAlertButton", comment: "Отмена")
    
    //MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = CatalogLayout.tableViewCornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .forViewBackground
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .sortCatalogButton), for: .normal)
        button.tintColor = .segmentActive
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .segmentActive
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    
    //MARK: - Init
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargetsForButtons()
        setupUI()
        bindViewModel()
    }
    
    //MARK: - Setup UI
    private func addTargetsForButtons() {
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .forViewBackground
        setupSortButton()
        setupTableView()
        setupLoadingIndicator()
    }
    
    private func setupSortButton() {
        view.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CatalogLayout.sortButtonTrailing),
            sortButton.heightAnchor.constraint(equalToConstant: CatalogLayout.sortButtonSize),
            sortButton.widthAnchor.constraint(equalToConstant: CatalogLayout.sortButtonSize)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CatalogCell.self)
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CatalogLayout.tableViewLeading),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CatalogLayout.tableViewTrailing),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.constraintCenters(to: view)
    }
    
    private func showError() {
        let repeatAction = UIAlertAction(title: repeatAlertButton, style: .default) { _ in
            self.viewModel.loadData()
        }
        let cancelAction = UIAlertAction(title: cancelAlertButton, style: .cancel)
        
        self.showErrorAlertWithTwoButtons(
            titleOfAlert: alertTitle,
            firstAction: repeatAction,
            secondAction: cancelAction
        )
    }
    
    //MARK: - Actions
    @objc func sortButtonTapped() {
        let sortByNameTitleAction = UIAlertAction(title: sortByNameTitle, style: .default) { [weak self] _ in
            self?.viewModel.sortByName()
        }
        let sortByCountAction = UIAlertAction(title: sortByCountTitle, style: .default) { [weak self] _ in
            self?.viewModel.sortByCountOfNfts()
        }
        self.showFilterActionSheet(firstAction: sortByNameTitleAction, secondAction: sortByCountAction, thirdAction: nil)
    }
    
    @objc private func refreshData() {
        viewModel.loadData()
    }
    
    //MARK: - Bind
    func bindViewModel() {
        viewModel.$catalog
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
            })
            .store(in: &subscribes)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
            }
            .store(in: &subscribes)
        
        viewModel.$loadError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self else { return }
                self.showError()
            }
            .store(in: &subscribes)
    }
}

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.catalog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogCell = tableView.dequeueReusableCell()
        let item = viewModel.catalog[indexPath.row]
        cell.configure(imageURL: item.cover, text: item.name, numberOfNfts: item.nfts.count)
        return cell
    }
    
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.catalog[indexPath.row]
        let provider = NftServiceImpl(
            networkClient: DefaultNetworkClient(),
            storage: NftStorageImpl()
        )
        
        let favoriteProvider = FavoriteNftProviderImpl(
            networkClient: DefaultNetworkClient(),
            storage: FavoriteNftStorageImpl()
        )
        
        let orderProvider = OrderNftProviderImpl(
            networkClient: DefaultNetworkClient(),
            storage: OrdersNftStorageImpl()
        )
        
        let viewModel = NFTCollectionViewModel(
            provider: provider,
            favoriteProvider: favoriteProvider,
            orderProvider: orderProvider,
            nftIds: item.nfts
        )
        
        let NFTvc = NFTCollectionViewController(
            viewModel: viewModel,
            catalogItem: item
        )
        
        let nav = UINavigationController(rootViewController: NFTvc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        present(nav, animated: true)
    }
}
