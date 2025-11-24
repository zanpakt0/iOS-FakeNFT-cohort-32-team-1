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
