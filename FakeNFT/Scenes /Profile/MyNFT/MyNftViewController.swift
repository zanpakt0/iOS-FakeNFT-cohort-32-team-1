import UIKit

final class MyNftViewController: UIViewController {
    
    // MARK: - Views (elements)
    private let tableViewWithNfts: UITableView = {
        let tableViewWithNfts = UITableView()
        tableViewWithNfts.register(MyNftTableViewCell.self, forCellReuseIdentifier: MyNftTableViewCell.reusedIdentifier)
        tableViewWithNfts.separatorStyle = .none
        tableViewWithNfts.rowHeight = 140
        tableViewWithNfts.translatesAutoresizingMaskIntoConstraints = false
        
        return tableViewWithNfts
    }()
    
    private func setupTableView() {
        tableViewWithNfts.delegate = self
        tableViewWithNfts.dataSource = self
    }
}

extension MyNftViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
