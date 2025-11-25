import UIKit
import Combine

final class CatalogViewController: UIViewController {
    //MARK: - Constants    
    private let viewModel = CatalogViewModel(catalogProvider: CatalogProvider())
    
    private var subscribes = Set<AnyCancellable>()

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
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupSortButton()
        setupTableView()
        bindViewModel()
    }
    
    //MARK: - Setup UI
    func setupSortButton() {
        view.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -9),
            sortButton.heightAnchor.constraint(equalToConstant: 42),
            sortButton.widthAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CatalogCell.self)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - Actions
    @objc func sortButtonTapped() {
        print("Sort Button Tapped")
    }
    
    //MARK: - Bind
    func bindViewModel() {
        viewModel.$catalog
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
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
