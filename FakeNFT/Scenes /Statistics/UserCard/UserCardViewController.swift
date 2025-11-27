//
//  UserCardViewController.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 26.11.2025.
//

import UIKit
import Combine

final class UserCardViewController: UIViewController {
    
    private let viewModel: UserCardViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UserCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackgound
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    break
                case .loaded(_):
                    break
                case .error(_):
                    break
                }
            }
            .store(in: &cancellables)
    }
}
