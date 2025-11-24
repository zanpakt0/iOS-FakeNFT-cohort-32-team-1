//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
        
        bindViewModel()
    }
    
    @objc private func filterButtonClicked() {
        
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading: break
                case .loaded(_): break
                case .error(_): break
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
