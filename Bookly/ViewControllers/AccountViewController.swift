import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AccountViewController: UIViewController {
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1.0)
    
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let contentPanelView = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let profileCardView = UIView()
    private let emailValueLabel = UILabel()
    private let uidValueLabel = UILabel()
    
    private let passwordChangeButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    private let deleteAccountButton = UIButton(type: .system)
    
    private let supportCardView = UIView()
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = navyColor
        
        configureUI()
        updateUserInfo()
    }
    
    private func configureUI() {
        configureHeaderView()
        configureContentPanelView()
        configureScrollView()
        configureStackView()
        configureProfileCardView()
        configureActionButtons()
        configureSupportCardView()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(
            UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            ),
            for: .normal
        )
        closeButton.tintColor = .white
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "회원 정보"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textAlignment = .left
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "로그인 계정과 보안 설정을 확인하세요."
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 1
        
        view.addSubview(headerView)
        headerView.addSubview(closeButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22)
        ])
    }
    
    private func configureContentPanelView() {
        contentPanelView.translatesAutoresizingMaskIntoConstraints = false
        contentPanelView.backgroundColor = backgroundColor
        contentPanelView.layer.cornerRadius = 32
        contentPanelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        contentPanelView.clipsToBounds = true
        
        view.addSubview(contentPanelView)
        
        NSLayoutConstraint.activate([
            contentPanelView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -34),
            contentPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        
        contentPanelView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentPanelView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentPanelView.bottomAnchor)
        ])
    }
    
    private func configureStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 28),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 22),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -22),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -34),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -44)
        ])
    }
    
    private func configureProfileCardView() {
        profileCardView.backgroundColor = .white
        profileCardView.layer.cornerRadius = 22
        profileCardView.clipsToBounds = true
        profileCardView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = navyColor.withAlphaComponent(0.08)
        iconView.layer.cornerRadius = 25
        
        let iconImageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconView.addSubview(iconImageView)
        
        let cardTitleLabel = UILabel()
        cardTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTitleLabel.text = "내 계정"
        cardTitleLabel.textColor = navyColor
        cardTitleLabel.font = .boldSystemFont(ofSize: 20)
        
        let emailTitleLabel = makeInfoTitleLabel("회원 아이디")
        emailValueLabel.translatesAutoresizingMaskIntoConstraints = false
        emailValueLabel.textColor = .label
        emailValueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        emailValueLabel.numberOfLines = 0
        
        let uidTitleLabel = makeInfoTitleLabel("UID")
        uidValueLabel.translatesAutoresizingMaskIntoConstraints = false
        uidValueLabel.textColor = .secondaryLabel
        uidValueLabel.font = .systemFont(ofSize: 12, weight: .regular)
        uidValueLabel.numberOfLines = 0
        
        let emailStack = UIStackView(arrangedSubviews: [
            emailTitleLabel,
            emailValueLabel
        ])
        emailStack.translatesAutoresizingMaskIntoConstraints = false
        emailStack.axis = .vertical
        emailStack.spacing = 4
        
        let uidStack = UIStackView(arrangedSubviews: [
            uidTitleLabel,
            uidValueLabel
        ])
        uidStack.translatesAutoresizingMaskIntoConstraints = false
        uidStack.axis = .vertical
        uidStack.spacing = 4
        
        profileCardView.addSubview(iconView)
        profileCardView.addSubview(cardTitleLabel)
        profileCardView.addSubview(emailStack)
        profileCardView.addSubview(uidStack)
        
        NSLayoutConstraint.activate([
            profileCardView.heightAnchor.constraint(equalToConstant: 178),
            
            iconView.topAnchor.constraint(equalTo: profileCardView.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 27),
            iconImageView.heightAnchor.constraint(equalToConstant: 27),
            
            cardTitleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            cardTitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            cardTitleLabel.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -20),
            
            emailStack.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 14),
            emailStack.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: 20),
            emailStack.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -20),
            
            uidStack.topAnchor.constraint(equalTo: emailStack.bottomAnchor, constant: 12),
            uidStack.leadingAnchor.constraint(equalTo: emailStack.leadingAnchor),
            uidStack.trailingAnchor.constraint(equalTo: emailStack.trailingAnchor)
        ])
        
        stackView.addArrangedSubview(profileCardView)
    }
    
    private func configureActionButtons() {
        configureActionButton(
            passwordChangeButton,
            title: "비밀번호 변경",
            subtitle: "가입 이메일로 비밀번호 재설정 메일을 보내요.",
            iconName: "lock.rotation",
            tintColor: navyColor
        )
        passwordChangeButton.addTarget(self, action: #selector(passwordChangeButtonTapped), for: .touchUpInside)
        
        configureActionButton(
            termsButton,
            title: "이용약관",
            subtitle: "Bookly 서비스 이용약관과 개인정보 안내를 확인해요.",
            iconName: "doc.text.fill",
            tintColor: navyColor
        )
        termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        
        configureActionButton(
            logoutButton,
            title: "로그아웃",
            subtitle: "현재 계정에서 로그아웃하고 로그인 화면으로 이동해요.",
            iconName: "rectangle.portrait.and.arrow.right",
            tintColor: navyColor
        )
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        configureActionButton(
            deleteAccountButton,
            title: "회원 탈퇴",
            subtitle: "계정 정보를 삭제하고 Bookly 이용을 종료해요.",
            iconName: "person.crop.circle.badge.xmark",
            tintColor: .systemRed
        )
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(passwordChangeButton)
        stackView.addArrangedSubview(termsButton)
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(deleteAccountButton)
    }
    
    private func configureActionButton(
        _ button: UIButton,
        title: String,
        subtitle: String,
        iconName: String,
        tintColor: UIColor
    ) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        
        let container = UIView()
        container.isUserInteractionEnabled = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = tintColor.withAlphaComponent(0.08)
        iconContainer.layer.cornerRadius = 21
        
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = tintColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = tintColor == UIColor.systemRed ? .systemRed : .label
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.numberOfLines = 2
        
        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 3
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.contentMode = .scaleAspectFit
        
        container.addSubview(iconContainer)
        container.addSubview(textStack)
        container.addSubview(arrowImageView)
        
        button.addSubview(container)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 70),
            
            container.topAnchor.constraint(equalTo: button.topAnchor),
            container.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 42),
            iconContainer.heightAnchor.constraint(equalToConstant: 42),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 21),
            iconImageView.heightAnchor.constraint(equalToConstant: 21),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -12),
            
            arrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            arrowImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 10),
            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func configureSupportCardView() {
        supportCardView.translatesAutoresizingMaskIntoConstraints = false
        supportCardView.backgroundColor = .white
        supportCardView.layer.cornerRadius = 18
        supportCardView.clipsToBounds = true
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = navyColor.withAlphaComponent(0.08)
        iconContainer.layer.cornerRadius = 21
        
        let iconImageView = UIImageView(image: UIImage(systemName: "questionmark.circle.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = navyColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Bookly 고객지원"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "앱 이용 중 문제가 있거나 문의가 있다면 아래 이메일로 의견을 보내주세요."
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descriptionLabel.numberOfLines = 2
        
        let emailTitleLabel = UILabel()
        emailTitleLabel.text = "개발자 이메일:"
        emailTitleLabel.textColor = .secondaryLabel
        emailTitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        let emailLabel = UILabel()
        emailLabel.text = "angela122491@gmail.com"
        emailLabel.textColor = navyColor
        emailLabel.font = .systemFont(ofSize: 14, weight: .bold)
        emailLabel.numberOfLines = 1
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.8
        
        let versionLabel = UILabel()
        versionLabel.text = "앱 버전 \(appVersionText)"
        versionLabel.textColor = navyColor.withAlphaComponent(0.72)
        versionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        
        let textStack = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            emailTitleLabel,
            emailLabel,
            versionLabel
        ])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        
        supportCardView.addSubview(iconContainer)
        supportCardView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            supportCardView.heightAnchor.constraint(equalToConstant: 166),
            
            iconContainer.leadingAnchor.constraint(equalTo: supportCardView.leadingAnchor, constant: 18),
            iconContainer.topAnchor.constraint(equalTo: supportCardView.topAnchor, constant: 24),
            iconContainer.widthAnchor.constraint(equalToConstant: 42),
            iconContainer.heightAnchor.constraint(equalToConstant: 42),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            textStack.topAnchor.constraint(equalTo: supportCardView.topAnchor, constant: 20),
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: supportCardView.trailingAnchor, constant: -18),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: supportCardView.bottomAnchor, constant: -20)
        ])
        
        stackView.addArrangedSubview(supportCardView)
    }
    
    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func makeInfoTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }
    
    private func updateUserInfo() {
        let user = Auth.auth().currentUser
        
        emailValueLabel.text = user?.email ?? "이메일 정보 없음"
        uidValueLabel.text = user?.uid ?? "UID 정보 없음"
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func passwordChangeButtonTapped() {
        guard let email = Auth.auth().currentUser?.email else {
            showSimpleAlert(
                title: "이메일 정보 없음",
                message: "비밀번호 변경 메일을 보낼 이메일 정보를 찾을 수 없어요."
            )
            return
        }
        
        let alert = UIAlertController(
            title: "비밀번호 변경",
            message: "\(email)\n\n이 이메일로 비밀번호 재설정 메일을 보낼까요?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(
            UIAlertAction(title: "보내기", style: .default) { [weak self] _ in
                self?.sendPasswordResetEmail(to: email)
            }
        )
        
        present(alert, animated: true)
    }
    
    private func sendPasswordResetEmail(to email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.showSimpleAlert(
                        title: "전송 실패",
                        message: "비밀번호 재설정 메일을 보내지 못했어요.\n\(error.localizedDescription)"
                    )
                    return
                }
                
                self?.showSimpleAlert(
                    title: "메일 전송 완료",
                    message: "비밀번호 재설정 메일을 보냈어요.\n메일함을 확인해주세요."
                )
            }
        }
    }
    
    @objc private func termsButtonTapped() {
        let termsVC = TermsViewController()
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "로그아웃할까요?",
            message: "로그아웃하면 다시 로그인 화면으로 이동합니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(
            UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
                self?.logout()
            }
        )
        
        present(alert, animated: true)
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            BookStore.shared.stopListeningAndClear()
            moveToAuthScreen()
        } catch {
            showSimpleAlert(
                title: "로그아웃 실패",
                message: "로그아웃 중 오류가 발생했어요.\n\(error.localizedDescription)"
            )
        }
    }
    
    @objc private func deleteAccountButtonTapped() {
        let alert = UIAlertController(
            title: "회원 탈퇴",
            message: "계정을 탈퇴하면 회원 정보가 삭제됩니다.\n정말 탈퇴할까요?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(
            UIAlertAction(title: "탈퇴", style: .destructive) { [weak self] _ in
                self?.deleteAccount()
            }
        )
        
        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            showSimpleAlert(
                title: "계정 정보 없음",
                message: "현재 로그인된 계정 정보를 찾을 수 없어요."
            )
            return
        }
        
        let uid = user.uid
        
        user.delete { [weak self] authError in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }
                
                if let authError {
                    let nsError = authError as NSError
                    
                    if nsError.code == 17014 {
                        self.showSimpleAlert(
                            title: "다시 로그인 필요",
                            message: "보안을 위해 최근 로그인 후에만 탈퇴할 수 있어요.\n로그아웃 후 다시 로그인하고 탈퇴를 시도해주세요."
                        )
                    } else {
                        self.showSimpleAlert(
                            title: "탈퇴 실패",
                            message: "계정 삭제 중 오류가 발생했어요.\n\(authError.localizedDescription)"
                        )
                    }
                    return
                }
                
                self.deleteFirestoreUserDataAfterAuthDeletion(uid: uid)
            }
        }
    }

    private func deleteFirestoreUserDataAfterAuthDeletion(uid: String) {
        BookStore.shared.deleteAllBooks(for: uid) { [weak self] booksDeleteError in
            guard let self else {
                return
            }
            
            if let booksDeleteError {
                DispatchQueue.main.async {
                    self.showSimpleAlert(
                        title: "일부 데이터 삭제 실패",
                        message: "계정은 삭제되었지만 책장 데이터 삭제 중 오류가 발생했어요.\n\(booksDeleteError.localizedDescription)"
                    )
                    
                    BookStore.shared.stopListeningAndClear()
                    self.moveToAuthScreen()
                }
                return
            }
            
            self.db.collection("users")
                .document(uid)
                .delete { [weak self] firestoreError in
                    DispatchQueue.main.async {
                        guard let self else {
                            return
                        }
                        
                        if let firestoreError {
                            self.showSimpleAlert(
                                title: "일부 데이터 삭제 실패",
                                message: "계정은 삭제되었지만 사용자 문서 삭제 중 오류가 발생했어요.\n\(firestoreError.localizedDescription)"
                            )
                            
                            BookStore.shared.stopListeningAndClear()
                            self.moveToAuthScreen()
                            return
                        }
                        
                        BookStore.shared.stopListeningAndClear()
                        self.moveToAuthScreen()
                    }
                }
        }
    }
    
    private func moveToAuthScreen() {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        
        dismiss(animated: false) {
            sceneDelegate.showAuthScreen()
        }
    }
    
    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

private final class TermsViewController: UIViewController {
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1.0)
    
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    private let contentPanelView = UIView()
    private let scrollView = UIScrollView()
    private let textLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = navyColor
        
        configureUI()
    }
    
    private func configureUI() {
        configureHeaderView()
        configureContentPanelView()
        configureTermsContent()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(
            UIImage(
                systemName: "chevron.left",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            ),
            for: .normal
        )
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 190),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 18),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 68),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -22)
        ])
    }
    
    private func configureContentPanelView() {
        contentPanelView.translatesAutoresizingMaskIntoConstraints = false
        contentPanelView.backgroundColor = backgroundColor
        contentPanelView.layer.cornerRadius = 32
        contentPanelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        contentPanelView.clipsToBounds = true
        
        view.addSubview(contentPanelView)
        
        NSLayoutConstraint.activate([
            contentPanelView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -34),
            contentPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTermsContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        textLabel.textColor = .label
        textLabel.font = .systemFont(ofSize: 14, weight: .regular)
        textLabel.text = termsText
        
        contentPanelView.addSubview(scrollView)
        scrollView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentPanelView.topAnchor, constant: 30),
            scrollView.leadingAnchor.constraint(equalTo: contentPanelView.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: contentPanelView.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: contentPanelView.bottomAnchor, constant: -30),
            
            textLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            textLabel.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private var termsText: String {
        """
        제1조 목적

        본 약관은 Bookly 앱에서 제공하는 도서 검색, 서재 관리, 독서 기록 기능의 이용 조건과 절차를 안내하기 위한 것입니다.

        제2조 서비스 내용

        Bookly는 사용자가 읽고 싶은 책, 읽는 중인 책, 완독한 책을 기록하고 관리할 수 있도록 돕는 개인 독서 기록 서비스입니다.

        제3조 계정 관리

        사용자는 Firebase Authentication을 통해 이메일과 비밀번호 기반 계정을 생성할 수 있습니다. 사용자는 본인의 계정 정보를 안전하게 관리해야 하며, 타인에게 계정 정보를 공유하지 않아야 합니다.

        제4조 데이터 저장

        사용자의 계정 정보 및 서비스 이용 데이터는 Firebase를 통해 저장될 수 있습니다. Bookly는 사용자의 독서 기록을 서비스 제공 목적에 한해 사용합니다.

        제5조 회원 탈퇴

        사용자는 회원 정보 화면에서 회원 탈퇴를 요청할 수 있습니다. 탈퇴 시 계정 정보가 삭제되며, 일부 데이터는 Firebase 처리 과정에 따라 삭제 완료까지 시간이 소요될 수 있습니다.

        제6조 비밀번호 변경

        사용자는 가입한 이메일을 통해 비밀번호 재설정 메일을 받을 수 있습니다.

        제7조 개인정보 안내

        Bookly는 서비스 제공을 위해 이메일, 사용자 UID, 독서 기록 정보를 사용할 수 있습니다. 해당 정보는 사용자 식별 및 개인 서재 관리 기능 제공을 위해 사용됩니다.

        제8조 기타

        본 약관은 앱 기능 및 버전 변경에 따라 수정될 수 있습니다.
        """
    }
}
