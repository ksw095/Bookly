import UIKit

final class LibraryViewController: UIViewController {
    private let segmentedControl = UISegmentedControl(items: BookStatus.allCases.map { $0.rawValue })
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    
    private var selectedStatus: BookStatus = .wish
    
    private var filteredBooks: [Book] {
        BookStore.shared.books(for: selectedStatus)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "나의 서재"
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
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        reloadData()
    }
    
    @objc private func statusChanged() {
        selectedStatus = BookStatus.allCases[segmentedControl.selectedSegmentIndex]
        reloadData()
    }
    
    private func reloadData() {
        tableView.reloadData()
        emptyLabel.text = "\(selectedStatus.title)에 등록된 책이 없습니다."
        emptyLabel.isHidden = !filteredBooks.isEmpty
    }
}

extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let book = filteredBooks[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell
        cell.configure(with: book)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = filteredBooks[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
            let book = self.filteredBooks[indexPath.row]
            BookStore.shared.deleteBook(book)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
