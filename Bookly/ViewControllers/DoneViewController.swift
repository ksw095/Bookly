import UIKit

final class DoneViewController: UIViewController {
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    
    private var doneBooks: [Book] {
        BookStore.shared.doneBooks
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "독서 기록"
        view.backgroundColor = .systemBackground
        configureUI()
        configureNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoreChange),
            name: .bookStoreDidChange,
            object: nil
        )
    }
    
    @objc private func handleBookStoreChange() {
        reloadData()
    }
    
    private func configureUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyLabel.text = "완독한 책이 없습니다."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        reloadData()
    }
    
    private func reloadData() {
        tableView.reloadData()
        emptyLabel.isHidden = !doneBooks.isEmpty
    }
}

extension DoneViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        doneBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book = doneBooks[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell
        cell.configure(with: book)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = doneBooks[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
