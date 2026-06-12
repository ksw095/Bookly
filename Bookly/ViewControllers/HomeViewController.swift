import UIKit
import FirebaseAuth

final class HomeViewController: UIViewController {
    private let store = BookStore.shared
    
    private let headerView = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    private let headerStatsCardView = UIView()
    
    private let wishHeaderCountLabel = UILabel()
    private let readingHeaderCountLabel = UILabel()
    private let doneHeaderCountLabel = UILabel()
    
    private let contentPanelView = UIView()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private var todayCollectionView: UICollectionView!
    private var readingCollectionView: UICollectionView!
    
    private let onboardingGuideCardView = UIView()
    private let libraryShortcutView = UIView()
    private let readingSectionTitleLabel = UILabel()
    private let readingSectionSubtitleLabel = UILabel()
    
    private var todayBooks: [KakaoBookDocument] = []
    
    private var readingBooks: [Book] {
        store.readingBooks
    }
    
    private var isLibraryCompletelyEmpty: Bool {
        store.count(for: .wish) == 0 &&
        store.count(for: .reading) == 0 &&
        store.count(for: .done) == 0
    }
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let navyLightColor = UIColor(red: 0.20, green: 0.26, blue: 0.47, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1.0)
    
    private let dailyKeywords = [
        "한국문학 소설",
        "세계문학 소설",
        "문학상 수상작",
        "에세이 베스트셀러",
        "고전문학",
        "인문학 교양",
        "철학 에세이",
        "심리학 교양",
        "경제경영 교양",
        "사회과학 교양",
        "과학 교양서",
        "역사 교양서",
        "자기계발 베스트셀러",
        "브랜딩 마케팅",
        "트렌드 분석"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        view.backgroundColor = navyColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        configureUI()
        configureNotification()
        loadTodayBooks()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        navigationController?.tabBarItem.title = "Bookly"
        navigationController?.tabBarItem.image = UIImage(systemName: "house")
        navigationController?.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        navigationController?.tabBarItem.imageInsets = .zero
        navigationController?.tabBarItem.titlePositionAdjustment = .zero
        
        tabBarController?.tabBar.items?[0].title = "Bookly"
        tabBarController?.tabBar.items?[1].title = "검색"
        tabBarController?.tabBar.items?[2].title = "나의 서재"
        tabBarController?.tabBar.items?[3].title = "독서 기록"
        
        reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        configureHeaderView()
        configureContentPanelView()
        configureScrollView()
        configureTodayBooksSection()
        configureReadingSection()
        configureOnboardingGuideCard()
        configureLibraryShortcut()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        logoLabel.text = "Bookly"
        logoLabel.textColor = .white
        logoLabel.font = UIFont(name: "Georgia-BoldItalic", size: 36) ?? .italicSystemFont(ofSize: 36)
        logoLabel.textAlignment = .left
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        subtitleLabel.textAlignment = .left
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        configureMenuButton()
        
        headerStatsCardView.backgroundColor = navyLightColor
        headerStatsCardView.layer.cornerRadius = 22
        headerStatsCardView.clipsToBounds = true
        headerStatsCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let wishItem = makeHeaderStatusItem(
            englishTitle: "WISH",
            iconName: "bookmark.fill",
            countLabel: wishHeaderCountLabel
        )
        
        let readingItem = makeHeaderStatusItem(
            englishTitle: "READING",
            iconName: "book.fill",
            countLabel: readingHeaderCountLabel
        )
        
        let doneItem = makeHeaderStatusItem(
            englishTitle: "DONE",
            iconName: "checkmark.circle.fill",
            countLabel: doneHeaderCountLabel
        )
        
        let divider1 = makeHeaderDivider()
        let divider2 = makeHeaderDivider()
        
        let statsStack = UIStackView(arrangedSubviews: [
            wishItem,
            divider1,
            readingItem,
            divider2,
            doneItem
        ])
        statsStack.axis = .horizontal
        statsStack.alignment = .fill
        statsStack.distribution = .fill
        statsStack.spacing = 0
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        divider1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        divider2.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        headerStatsCardView.addSubview(statsStack)
        
        view.addSubview(headerView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(menuButton)
        headerView.addSubview(headerStatsCardView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 250),
            
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            menuButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22),
            menuButton.widthAnchor.constraint(equalToConstant: 36),
            menuButton.heightAnchor.constraint(equalToConstant: 36),
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            logoLabel.trailingAnchor.constraint(lessThanOrEqualTo: menuButton.leadingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22),
            
            headerStatsCardView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            headerStatsCardView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22),
            headerStatsCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            headerStatsCardView.heightAnchor.constraint(equalToConstant: 64),
            
            statsStack.topAnchor.constraint(equalTo: headerStatsCardView.topAnchor, constant: 10),
            statsStack.leadingAnchor.constraint(equalTo: headerStatsCardView.leadingAnchor, constant: 10),
            statsStack.trailingAnchor.constraint(equalTo: headerStatsCardView.trailingAnchor, constant: -10),
            statsStack.bottomAnchor.constraint(equalTo: headerStatsCardView.bottomAnchor, constant: -10)
        ])
        
        wishItem.widthAnchor.constraint(equalTo: readingItem.widthAnchor).isActive = true
        readingItem.widthAnchor.constraint(equalTo: doneItem.widthAnchor).isActive = true
    }
    
    private func configureMenuButton() {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(
            systemName: "line.3.horizontal",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        )
        
        menuButton.setImage(image, for: .normal)
        menuButton.tintColor = .white
        menuButton.backgroundColor = .clear
        menuButton.layer.cornerRadius = 0
        menuButton.clipsToBounds = false
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
    }
    
    @objc private func menuButtonTapped() {
        let accountVC = AccountViewController()
        let navigationController = UINavigationController(rootViewController: accountVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
        present(navigationController, animated: true)
    }
    
    private func configureContentPanelView() {
        contentPanelView.translatesAutoresizingMaskIntoConstraints = false
        contentPanelView.backgroundColor = backgroundColor
        contentPanelView.layer.cornerRadius = 28
        contentPanelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        contentPanelView.clipsToBounds = true
        
        view.addSubview(contentPanelView)
        
        NSLayoutConstraint.activate([
            contentPanelView.topAnchor.constraint(equalTo: headerStatsCardView.bottomAnchor, constant: 14),
            contentPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 14
        
        contentPanelView.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentPanelView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentPanelView.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 34),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -110),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }
    
    private func configureTodayBooksSection() {
        let titleLabel = makeSectionTitleLabel("오늘의 도서")
        let subtitleLabel = makeSectionSubtitleLabel("매일 새로운 주제의 책을 추천해드려요.")
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 1
        
        contentStackView.addArrangedSubview(titleStack)
        contentStackView.setCustomSpacing(6, after: titleStack)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 130, height: 190)
        layout.minimumLineSpacing = 12
        
        todayCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        todayCollectionView.heightAnchor.constraint(equalToConstant: 198).isActive = true
        todayCollectionView.backgroundColor = .clear
        todayCollectionView.showsHorizontalScrollIndicator = false
        todayCollectionView.dataSource = self
        todayCollectionView.delegate = self
        todayCollectionView.register(
            BookCollectionViewCell.self,
            forCellWithReuseIdentifier: BookCollectionViewCell.identifier
        )
        
        contentStackView.addArrangedSubview(todayCollectionView)
    }
    
    private func configureReadingSection() {
        readingSectionTitleLabel.text = "읽고 있는 책"
        readingSectionTitleLabel.font = .boldSystemFont(ofSize: 20)
        
        readingSectionSubtitleLabel.text = "진행률과 읽기 시작일을 확인하세요."
        readingSectionSubtitleLabel.font = .systemFont(ofSize: 13)
        readingSectionSubtitleLabel.textColor = .secondaryLabel
        
        let titleStack = UIStackView(arrangedSubviews: [
            readingSectionTitleLabel,
            readingSectionSubtitleLabel
        ])
        titleStack.axis = .vertical
        titleStack.spacing = 1
        titleStack.tag = 901
        
        contentStackView.addArrangedSubview(titleStack)
        contentStackView.setCustomSpacing(6, after: titleStack)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 218)
        layout.minimumLineSpacing = 12
        
        readingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        readingCollectionView.heightAnchor.constraint(equalToConstant: 224).isActive = true
        readingCollectionView.backgroundColor = .clear
        readingCollectionView.showsHorizontalScrollIndicator = false
        readingCollectionView.dataSource = self
        readingCollectionView.delegate = self
        readingCollectionView.register(
            BookCollectionViewCell.self,
            forCellWithReuseIdentifier: BookCollectionViewCell.identifier
        )
        
        contentStackView.addArrangedSubview(readingCollectionView)
    }
    
    private func configureOnboardingGuideCard() {
        onboardingGuideCardView.translatesAutoresizingMaskIntoConstraints = false
        onboardingGuideCardView.backgroundColor = .systemBackground
        onboardingGuideCardView.layer.cornerRadius = 22
        onboardingGuideCardView.clipsToBounds = true
        
        let stepOne = makeGuideStepView(
            number: "1",
            iconName: "bookmark.fill",
            title: "읽고 싶은 책을 WISH에 담기",
            description: "관심 있는 책을 검색하고 나만의 서재를 만들어보세요."
        )
        
        let stepTwo = makeGuideStepView(
            number: "2",
            iconName: "book.fill",
            title: "읽기 시작한 책은 READING으로 이동",
            description: "읽고 있는 책을 등록하고, 독서 여정을 관리하세요."
        )
        
        let stepThree = makeGuideStepView(
            number: "3",
            iconName: "checkmark.circle.fill",
            title: "다 읽은 책은 잊지 않고 기록 남기기",
            description: "완독 후 독서 기록을 남기고 독서 카드를 공유해보세요."
        )
        
        let stepStackView = UIStackView(arrangedSubviews: [
            stepOne,
            stepTwo,
            stepThree
        ])
        stepStackView.translatesAutoresizingMaskIntoConstraints = false
        stepStackView.axis = .vertical
        stepStackView.spacing = 0
        stepStackView.distribution = .fillEqually
        
        let searchButton = UIButton(type: .system)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setTitle("책 검색하러 가기  →", for: .normal)
        searchButton.setTitleColor(navyColor, for: .normal)
        searchButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        searchButton.backgroundColor = .clear
        searchButton.layer.cornerRadius = 18
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = navyColor.withAlphaComponent(0.18).cgColor
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        onboardingGuideCardView.addSubview(stepStackView)
        onboardingGuideCardView.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            onboardingGuideCardView.heightAnchor.constraint(equalToConstant: 226),
            
            stepStackView.topAnchor.constraint(equalTo: onboardingGuideCardView.topAnchor, constant: 22),
            stepStackView.leadingAnchor.constraint(equalTo: onboardingGuideCardView.leadingAnchor, constant: 22),
            stepStackView.trailingAnchor.constraint(equalTo: onboardingGuideCardView.trailingAnchor, constant: -22),
            stepStackView.heightAnchor.constraint(equalToConstant: 144),
            
            searchButton.topAnchor.constraint(equalTo: stepStackView.bottomAnchor, constant: 14),
            searchButton.centerXAnchor.constraint(equalTo: onboardingGuideCardView.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 178),
            searchButton.heightAnchor.constraint(equalToConstant: 38),
            searchButton.bottomAnchor.constraint(lessThanOrEqualTo: onboardingGuideCardView.bottomAnchor, constant: -18)
        ])
        
        contentStackView.addArrangedSubview(onboardingGuideCardView)
    }
    
    private func configureLibraryShortcut() {
        libraryShortcutView.backgroundColor = .systemBackground
        libraryShortcutView.layer.cornerRadius = 18
        libraryShortcutView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = navyColor.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 22
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: "books.vertical.fill"))
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "내 서재 보기"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "찜한 책, 읽는 중인 책, 완독한 책을 확인하세요."
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        libraryShortcutView.addSubview(iconContainer)
        libraryShortcutView.addSubview(textStack)
        libraryShortcutView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            libraryShortcutView.heightAnchor.constraint(equalToConstant: 92),
            
            iconContainer.leadingAnchor.constraint(equalTo: libraryShortcutView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            
            arrowImageView.trailingAnchor.constraint(equalTo: libraryShortcutView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: libraryShortcutView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(libraryShortcutTapped))
        libraryShortcutView.addGestureRecognizer(tapGesture)
        libraryShortcutView.isUserInteractionEnabled = true
        
        contentStackView.addArrangedSubview(libraryShortcutView)
    }
    
    private func makeGuideStepView(
        number: String,
        iconName: String,
        title: String,
        description: String
    ) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let numberCircleView = UIView()
        numberCircleView.translatesAutoresizingMaskIntoConstraints = false
        numberCircleView.backgroundColor = navyLightColor
        numberCircleView.layer.cornerRadius = 12
        numberCircleView.clipsToBounds = true
        
        let numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = number
        numberLabel.textColor = .white
        numberLabel.font = .systemFont(ofSize: 12, weight: .bold)
        numberLabel.textAlignment = .center
        
        numberCircleView.addSubview(numberLabel)
        
        let iconCircleView = UIView()
        iconCircleView.translatesAutoresizingMaskIntoConstraints = false
        iconCircleView.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1.0)
        iconCircleView.layer.cornerRadius = 21
        iconCircleView.clipsToBounds = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconCircleView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = .systemFont(ofSize: 11, weight: .regular)
        descriptionLabel.numberOfLines = 1
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        let textStackView = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel
        ])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 3
        
        container.addSubview(numberCircleView)
        container.addSubview(iconCircleView)
        container.addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            numberCircleView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            numberCircleView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            numberCircleView.widthAnchor.constraint(equalToConstant: 24),
            numberCircleView.heightAnchor.constraint(equalToConstant: 24),
            
            numberLabel.centerXAnchor.constraint(equalTo: numberCircleView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: numberCircleView.centerYAnchor),
            
            iconCircleView.leadingAnchor.constraint(equalTo: numberCircleView.trailingAnchor, constant: 18),
            iconCircleView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconCircleView.widthAnchor.constraint(equalToConstant: 42),
            iconCircleView.heightAnchor.constraint(equalToConstant: 42),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 19),
            iconImageView.heightAnchor.constraint(equalToConstant: 19),
            
            textStackView.leadingAnchor.constraint(equalTo: iconCircleView.trailingAnchor, constant: 14),
            textStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func reloadData() {
        todayCollectionView?.reloadData()
        readingCollectionView?.reloadData()
        updateHeaderStats()
        updateReadingSectionVisibility()
        updateOnboardingGuideVisibility()
    }
    
    private func updateHeaderStats() {
        wishHeaderCountLabel.text = "\(store.count(for: .wish))"
        readingHeaderCountLabel.text = "\(store.count(for: .reading))"
        doneHeaderCountLabel.text = "\(store.count(for: .done))"
    }
    
    private func updateReadingSectionVisibility() {
        let shouldShow = !readingBooks.isEmpty
        
        for view in contentStackView.arrangedSubviews where view.tag == 901 {
            view.isHidden = !shouldShow
        }
        
        readingCollectionView?.isHidden = !shouldShow
    }
    
    private func updateOnboardingGuideVisibility() {
        onboardingGuideCardView.isHidden = !isLibraryCompletelyEmpty
    }
    
    private func makeHeaderStatusItem(
        englishTitle: String,
        iconName: String,
        countLabel: UILabel
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconCircleView = UIView()
        iconCircleView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        iconCircleView.layer.cornerRadius = 18
        iconCircleView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconCircleView.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = englishTitle
        titleLabel.font = .systemFont(ofSize: 10, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        
        countLabel.text = "0"
        countLabel.font = .boldSystemFont(ofSize: 18)
        countLabel.textColor = .white
        countLabel.textAlignment = .left
        
        let unitLabel = UILabel()
        unitLabel.text = "권"
        unitLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        unitLabel.textColor = .white
        
        let countStack = UIStackView(arrangedSubviews: [
            countLabel,
            unitLabel
        ])
        countStack.axis = .horizontal
        countStack.spacing = 2
        countStack.alignment = .lastBaseline
        
        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            countStack
        ])
        textStack.axis = .vertical
        textStack.spacing = 1
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconCircleView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            iconCircleView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            iconCircleView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconCircleView.widthAnchor.constraint(equalToConstant: 36),
            iconCircleView.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 17),
            iconImageView.heightAnchor.constraint(equalToConstant: 17),
            
            textStack.leadingAnchor.constraint(equalTo: iconCircleView.trailingAnchor, constant: 8),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -6),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func makeHeaderDivider() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func makeSectionTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }
    
    private func makeSectionSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }
    
    private func loadTodayBooks() {
        Task {
            do {
                var finalDocuments: [KakaoBookDocument] = []
                var seenKeys = Set<String>()
                
                let keywords = rotatedDailyKeywordsStartingFromToday()
                
                for keyword in keywords {
                    let response = try await KakaoBookService.shared.searchBooks(
                        keyword: keyword,
                        page: 1,
                        size: 50,
                        target: nil,
                        sort: "accuracy"
                    )
                    
                    let filteredDocuments = response.documents.filter { document in
                        RecommendationFilter.isRecommendable(document)
                    }
                    
                    for document in filteredDocuments {
                        let key = recommendationUniqueKey(for: document)
                        
                        guard !seenKeys.contains(key) else {
                            continue
                        }
                        
                        seenKeys.insert(key)
                        finalDocuments.append(document)
                        
                        if finalDocuments.count >= 8 {
                            break
                        }
                    }
                    
                    if finalDocuments.count >= 8 {
                        break
                    }
                }
                
                await MainActor.run {
                    self.todayBooks = finalDocuments
                    self.todayCollectionView.reloadData()
                }
            } catch {
                print("Today books load error:", error.localizedDescription)
            }
        }
    }
    
    private func todayKeyword() -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dailyKeywords[day % dailyKeywords.count]
    }
    
    private func rotatedDailyKeywordsStartingFromToday() -> [String] {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let startIndex = day % dailyKeywords.count
        
        let firstPart = dailyKeywords[startIndex..<dailyKeywords.count]
        let secondPart = dailyKeywords[0..<startIndex]
        
        return Array(firstPart + secondPart)
    }
    
    private func recommendationUniqueKey(for document: KakaoBookDocument) -> String {
        let title = document.title.removingHTMLTags()
        let authors = document.authors.joined(separator: ",")
        let publisher = document.publisher
        
        return "\(title)-\(authors)-\(publisher)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
    }
    
    @objc private func libraryShortcutTapped() {
        tabBarController?.selectedIndex = 2
    }
    
    @objc private func searchButtonTapped() {
        tabBarController?.selectedIndex = 1
    }
    
    private func pushDetail(book: Book) {
        let detailVC = BookDetailViewController(book: book)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func pushSearchDetail(document: KakaoBookDocument) {
        let detailVC = SearchBookDetailViewController(document: document)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == todayCollectionView {
            return todayBooks.count
        } else {
            return readingBooks.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BookCollectionViewCell.identifier,
            for: indexPath
        ) as! BookCollectionViewCell
        
        if collectionView == todayCollectionView {
            cell.configureToday(with: todayBooks[indexPath.item])
        } else {
            cell.configureReading(with: readingBooks[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == todayCollectionView {
            pushSearchDetail(document: todayBooks[indexPath.item])
        } else {
            pushDetail(book: readingBooks[indexPath.item])
        }
    }
}
