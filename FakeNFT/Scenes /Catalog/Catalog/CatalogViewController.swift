import UIKit
import Combine

final class CatalogViewController: UIViewController, ErrorView {
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
    
    //MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = CatalogLayout.tableViewCornerRadius
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .forViewBackgound
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .sortCatalogButton), for: .normal)
        button.tintColor = .segmentActive
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
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
        setupUI()
        bindViewModel()
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .forViewBackgound
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
        let provider = NftServiceImpl(networkClient: DefaultNetworkClient(),
                                     storage: NftStorageImpl())
        let viewModel = NFTCollectionViewModel(provider: provider, nftIds: item.nfts)
        let NFTvc = NFTCollectionViewController(viewModel: viewModel, catalogItem: item)
        NFTvc.modalTransitionStyle = .crossDissolve
        NFTvc.modalPresentationStyle = .fullScreen
        present(NFTvc, animated: true)
    }
}
