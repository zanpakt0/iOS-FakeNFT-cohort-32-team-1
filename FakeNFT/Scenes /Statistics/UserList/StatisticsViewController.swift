//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import UIKit
import Combine

// MARK: - Need enums
enum UIStateForLoader {
    case showLoaderHideTable
    case showTableHideLoader
    case showBoth
    case hideBoth
}

enum StatisticsViewControllerLayout {
    static let tableTop: CGFloat = 20
    static let tableLeading: CGFloat = 16
    static let tableTrailing: CGFloat = -16
    static let tableBottom: CGFloat = -8
}

final class StatisticsViewController: UIViewController, LoadingView {
    
    // MARK: - Private Properties
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    private lazy var filterButton: UIButton = {
        let filterButton = UIButton(type: .system)
        let imageForButton = UIImage(resource: .sort)
        filterButton.setImage(imageForButton, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        filterButton.tintColor = .segmentActive
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 42),
            filterButton.widthAnchor.constraint(equalToConstant: 42)
        ])
        
        return filterButton
    }()
    private lazy var tableViewWithUsers: UITableView = {
        let tableViewWithUsers = UITableView()
        tableViewWithUsers.backgroundColor = .forViewBackgound
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
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackgound
        
        setupNavBar()
        addSubviews()
        setupConstraints()
        
        bindViewModel()
        viewModel.fetchUsers(page: viewModel.pageNumber)
    }
    
    // MARK: - Private Methods
    @objc private func filterButtonClicked() {
        let textOfByNameButton = NSLocalizedString("Statistics.actionSheet.byNameAction.text", comment: "")
        let textOfByRatingButton = NSLocalizedString("Statistics.actionSheet.byRatingAction.text", comment: "")
        
        let byNameAction = UIAlertAction(title: textOfByNameButton, style: .default) {[weak self] _ in
            self?.viewModel.setFilterTypeToStorage(FilterType.byName.rawValue)
            self?.viewModel.sortByNeedFilterType()
            self?.tableViewWithUsers.reloadData()
        }
        
        let byRatingAction = UIAlertAction(title: textOfByRatingButton, style: .default) {[weak self] _ in
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
        case .showLoaderHideTable:
            self.showLoading()
            self.tableViewWithUsers.isHidden = true
        case .showTableHideLoader:
            self.hideLoading()
            self.tableViewWithUsers.isHidden = false
        case .showBoth:
            self.showLoading()
            self.tableViewWithUsers.isHidden = false
        case .hideBoth:
            self.hideLoading()
            self.tableViewWithUsers.isHidden = true
        default:
            break
        }
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                    break
                case .loading:
                    switch self.viewModel.usersList.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideTable)
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showBoth)
                    }
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showTableHideLoader)
                    self.tableViewWithUsers.reloadData()
                case .error(_):
                    switch self.viewModel.usersList.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                        self.showError()
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showTableHideLoader)
                        self.showError()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }
}

// MARK: - ErrorView
extension StatisticsViewController: ErrorView {
    func showError() {
        let retryActionText = NSLocalizedString("Statistics.errorAlert.retryAction.text", comment: "")
        let errorModel = ErrorModel(
            message: "",
            actionText: retryActionText,
            action: {[weak self] in
                guard let self else { return }
                self.viewModel.fetchUsers(page: self.viewModel.pageNumber)
            }
        )
        
        let title = NSLocalizedString("Statistics.errorAlert.title", comment: "")
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: errorModel.actionText, style: .default) {_ in
            errorModel.action()
        }
        alert.addAction(retryAction)
        
        let cancelActionText = NSLocalizedString("Statistics.errorAlert.cancelAction.text", comment: "")
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.usersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        let userInfo = self.viewModel.usersList[indexPath.row]
        cell.configure(numberingOfCell: indexPath.row + 1, with: userInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userCardViewModel = UserCardViewModel(serviceAssembly: self.viewModel.servicesAssembly)
        let userCardViewController = UserCardViewController(viewModel: userCardViewModel)
        
        let transition = CATransition()
        transition.duration = 0.03
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationItem.backButtonTitle = ""
        userCardViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userCardViewController, animated: false)
        
        userCardViewModel.fetchUserById(self.viewModel.usersList[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.viewModel.usersList.count - 1 == indexPath.row {
            self.viewModel.fetchUsers(page: self.viewModel.pageNumber)
        }
    }
}
