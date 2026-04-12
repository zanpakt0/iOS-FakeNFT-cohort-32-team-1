import UIKit
import Combine

final class MyNftViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: MyNftViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
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
        
        setupNavBar()
        setupTableView()
        addSubviews()
        addTargetsForButtons()
        bindViewModel()
        
        viewModel.fetchNfts() {
            print("Что то произошло")
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func filterButtonClicked() {
        
    }
    
    private func setupTableView() {
        tableViewWithNfts.delegate = self
        tableViewWithNfts.dataSource = self
    }
    
    private func addSubviews() {
        view.addSubview(tableViewWithNfts)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
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
                case .loaded:
                    self.tableViewWithNfts.reloadData()
                case .error(_):
                    break
                }
            }
            .store(in: &cancellables)
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
        
        return cell
    }
}
