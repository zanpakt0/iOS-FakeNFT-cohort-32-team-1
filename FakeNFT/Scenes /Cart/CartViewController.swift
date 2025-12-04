//
//  CartViewController.swift
//  FakeNFT
//
//  Created by Svetlana Varenova on 25.11.2025.
//

import UIKit

final class CartViewController: UIViewController, ErrorView {
    
    private let viewModel: CartViewModel
    
    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView = UITableView()
    private let bottomView = UIView()
    private let countLabel = UILabel()
    private let totalLabel = UILabel()
    private let payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("Filter.actionSheet.title.toPay", comment: ""), for: .normal)
        btn.tintColor = UIColor.segmentButtonText
        btn.backgroundColor = UIColor.segmentButtonBackground
        btn.layer.cornerRadius = 18
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        
        setupNavigationBar()
        setupBottom()
        setupTable()
        setupBindings()
        
        viewModel.updateTotal()
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        
        let sortButtonItem = UIBarButtonItem(
            image: UIImage(named: "sortButton"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButtonItem.tintColor = UIColor.segmentButtonBackground
        navigationItem.rightBarButtonItem = sortButtonItem
    }
    
    // MARK: - Setup bindings
    private func setupBindings() {
        viewModel.onItemsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.onTotalUpdated = { [weak self] count, total in
            self?.countLabel.text = count
            self?.totalLabel.text = total
        }
    }
    
    @objc private func sortButtonTapped() {
        let priceAction = UIAlertAction(title: "По цене", style: .default) { [weak self] _ in
            self?.viewModel.sortByPrice()
        }
        let ratingAction = UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.viewModel.sortByRating()
        }
        let titleAction = UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.viewModel.sortByTitle()
        }
        showFilterActionSheet(
            firstAction: priceAction,
            secondAction: ratingAction,
            thirdAction: titleAction
        )
    }
    
    // MARK: - Setup Table
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
    }
    
    // MARK: - Setup Bottom
    private func setupBottom() {
        bottomView.backgroundColor = .segmentPayCellBackground
        view.addSubview(bottomView)
        bottomView.addSubview(countLabel)
        bottomView.addSubview(totalLabel)
        bottomView.addSubview(payButton)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.font = .systemFont(ofSize: 15, weight: .regular)
        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.textColor = UIColor.greenUniversal
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 76),
            
            countLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            countLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 18),
            
            totalLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            totalLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 4),
            
            payButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            payButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            payButton.widthAnchor.constraint(equalToConstant: 240),
            payButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func payButtonTapped() {
        let nextVC = PaymentViewController()
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

// MARK: - TableView
extension CartViewController: UITableViewDataSource, UITableViewDelegate, CartTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let item = viewModel.item(at: indexPath.row)
        cell.configure(with: item)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - CartTableViewCellDelegate
    func cartCell(_ cell: CartTableViewCell, didChangeRating rating: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.updateRating(at: indexPath.row, rating: rating)
    }
    
    func cartCellDidTapDelete(_ cell: CartTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let item = viewModel.item(at: indexPath.row)
        
        let vc = DeleteModalViewController(
            image: item.image,
            title: item.title,
            onDelete: { [weak self] in
                guard let self = self else { return }
                self.viewModel.removeItem(at: indexPath.row)
                self.tableView.reloadData()
            }
        )
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: true)
    }
}

#Preview {
    CartViewController(viewModel: CartViewModel())
}
