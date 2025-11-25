import UIKit
import Combine

final class CatalogViewController: UIViewController, ErrorView {
    //MARK: - Constants
    private let viewModel = CatalogViewModel(СatalogProvider: CatalogProvider())
    private var subscribes = Set<AnyCancellable>()
    
    private let sortByNameTitle: String = NSLocalizedString("catalog.sortByNameTitle", comment: "Sort by name")
    private let sortByCountTitle: String = NSLocalizedString("catalog.sortByCountTitle", comment: "Sort by count of nfts")
    
    //MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 12
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .sortButton), for: .normal)
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
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupSortButton()
        setupTableView()
        setupLoadingIndicator()
        bindViewModel()
    }
    
    //MARK: - Setup UI
    private func setupSortButton() {
        view.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -9),
            sortButton.heightAnchor.constraint(equalToConstant: 42),
            sortButton.widthAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CatalogCell.self)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
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
    
    //MARK: - Bind
    func bindViewModel() {
        viewModel.$catalog
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &subscribes)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.loadingIndicator.startAnimating()
                    self.tableView.isHidden = true
                } else {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.isHidden = false
                }
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
        cell.configure(image: item.image, text: item.title, numberOfNfts: item.count)
        return cell
    }
    
}

extension CatalogViewController: UITableViewDelegate { }
