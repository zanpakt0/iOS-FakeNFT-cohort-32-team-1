//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import UIKit
import Combine

enum UIStateForLoader {
    case showLoaderHideTable
    case showTableHideLoader
    case showBoth
    case hideBoth
}

final class StatisticsViewController: UIViewController, LoadingView {
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackgound
        
        setupNavBar()
        addSubviews()
        setupConstraints()
        
        bindViewModel()
        viewModel.fetchUsers(page: viewModel.pageNumber)
    }
    
    @objc private func filterButtonClicked() {
        
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(tableViewWithUsers)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableViewWithUsers.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableViewWithUsers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewWithUsers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewWithUsers.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
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
                    switch self.viewModel.cellViewModels.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideTable)
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showBoth)
                    }
                case .loaded(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showTableHideLoader)
                    self.tableViewWithUsers.reloadData()
                case .error(_):
                    switch self.viewModel.cellViewModels.count {
                    case 0:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                    default:
                        showNeedViewsInScreen(needToShowLoadingIndicator: .showTableHideLoader)
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

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableViewCell.reuseIdentifier, for: indexPath) as? StatisticsTableViewCell else {
            return UITableViewCell()
        }
        
        let userInfo = self.viewModel.cellViewModels[indexPath.row]
        cell.configure(numberingOfCell: indexPath.row + 1, with: userInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
}
