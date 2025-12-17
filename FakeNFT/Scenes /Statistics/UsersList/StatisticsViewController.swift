import UIKit
import Combine

// MARK: - Need enums
enum StatisticsViewControllerLayout {
    static let tableTop: CGFloat = 20
    static let tableLeading: CGFloat = 16
    static let tableTrailing: CGFloat = -16
    static let tableBottom: CGFloat = -8
    static let tableHeight: CGFloat = 88
    
    static let filterButtonSizes: CGFloat = 42
}

final class StatisticsViewController: UIViewController, LoadingView {
    
    // MARK: - Private Properties
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .segmentActive
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    private lazy var filterButton: UIButton = {
        let filterButton = UIButton(type: .system)
        let imageForButton = UIImage(resource: .sortCatalogButton)
        filterButton.setImage(imageForButton, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        filterButton.tintColor = .segmentActive
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: StatisticsViewControllerLayout.filterButtonSizes),
            filterButton.widthAnchor.constraint(equalToConstant: StatisticsViewControllerLayout.filterButtonSizes)
        ])
        
        return filterButton
    }()
    private lazy var tableViewWithUsers: UITableView = {
        let tableViewWithUsers = UITableView()
        tableViewWithUsers.backgroundColor = .forViewBackground
        tableViewWithUsers.dataSource = self
        tableViewWithUsers.delegate = self
        tableViewWithUsers.register(StatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsTableViewCell.reuseIdentifier)
        tableViewWithUsers.separatorStyle = .none
        tableViewWithUsers.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithUsers
    }()
    
    // MARK: - Initializers
    init(viewModel: StatisticsViewModel) {
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
        addSubviews()
        setupConstraints()
        
        bindViewModel()
        viewModel.fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.usersList.isEmpty {
            viewModel.fetchUsers()
        }
    }
    
    // MARK: - Private Methods
    @objc private func filterButtonClicked() {
        let textOfByNameButton = NSLocalizedString("Statistics.actionSheet.byNameAction.text", comment: "")
        let textOfByRatingButton = NSLocalizedString("Statistics.actionSheet.byRatingAction.text", comment: "")
        
        let byNameAction = UIAlertAction(title: textOfByNameButton, style: .default) { [weak self] _ in
            self?.viewModel.setFilterTypeToStorage(FilterType.byName.rawValue)
            self?.viewModel.sortByNeedFilterType()
            self?.tableViewWithUsers.reloadData()
        }
        
        let byRatingAction = UIAlertAction(title: textOfByRatingButton, style: .default) { [weak self] _ in
            self?.viewModel.setFilterTypeToStorage(FilterType.byRating.rawValue)
            self?.viewModel.sortByNeedFilterType()
            self?.tableViewWithUsers.reloadData()
        }
        
        showFilterActionSheet(firstAction: byNameAction, secondAction: byRatingAction, thirdAction: nil)
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(tableViewWithUsers)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableViewWithUsers.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: StatisticsViewControllerLayout.tableTop),
            tableViewWithUsers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: StatisticsViewControllerLayout.tableLeading),
            tableViewWithUsers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: StatisticsViewControllerLayout.tableTrailing),
            tableViewWithUsers.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: StatisticsViewControllerLayout.tableBottom)
        ])
    }
    
    private func showNeedViewsInScreen(needToShowLoadingIndicator: UIStateForLoader) {
        switch needToShowLoadingIndicator {
        case .showLoaderHideViews:
            showLoading()
            self.tableViewWithUsers.isHidden = true
        case .showViewsHideLoader:
            hideLoading()
            self.tableViewWithUsers.isHidden = false
        case .showBoth:
            showLoading()
            self.tableViewWithUsers.isHidden = false
        case .hideBoth:
            hideLoading()
            self.tableViewWithUsers.isHidden = true
        }
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                    break
                case .loading:
                    switch self.viewModel.usersList.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideViews)
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showBoth)
                    }
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                    self.tableViewWithUsers.reloadData()
                case .error(_):
                    switch self.viewModel.usersList.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                        showErrorAlert()
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                        showErrorAlert()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }
    
    private func showErrorAlert() {
        universalErrorAlert { [weak self] in
            guard let self else { return }
            self.viewModel.fetchUsers()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        let userInfo = viewModel.usersList[indexPath.row]
        cell.configure(numberingOfCell: indexPath.row + 1, with: userInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userCardViewModel = UserCardViewModel(servicesAssembly: viewModel.servicesAssembly)
        let userCardViewController = UserCardViewController(viewModel: userCardViewModel)
        
        universalOpenPage(viewController: userCardViewController)
        
        userCardViewModel.fetchUserById(viewModel.usersList[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StatisticsViewControllerLayout.tableHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.usersList.count - 1 == indexPath.row {
            viewModel.fetchUsers()
        }
    }
}
