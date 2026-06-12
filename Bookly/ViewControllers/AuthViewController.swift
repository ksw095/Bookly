import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AuthViewController: UIViewController {
    private enum AuthMode {
        case login
        case signUp
    }
    
    private var currentMode: AuthMode = .login {
        didSet {
            updateMode()
        }
    }
    
    private let navyColor = UIColor(red: 0.02, green: 0.10, blue: 0.28, alpha: 1.0)
    private let backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.99, alpha: 1.0)
    
    private let headerView = UIView()
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let whitePanelView = UIView()
    private let modeSegmentedControl = UISegmentedControl(items: ["로그인", "회원가입"])
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let emailContainerView = UIView()
    private let emailIconImageView = UIImageView()
    private let emailTextField = UITextField()
    
    private let passwordContainerView = UIView()
    private let passwordIconImageView = UIImageView()
    private let passwordTextField = UITextField()
    
    private let confirmPasswordContainerView = UIView()
    private let confirmPasswordIconImageView = UIImageView()
    private let confirmPasswordTextField = UITextField()
    
    private let primaryButton = UIButton(type: .system)
    private let switchModeButton = UIButton(type: .system)
    private let helperLabel = UILabel()
    
    private var confirmPasswordHeightConstraint: NSLayoutConstraint?
    
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = navyColor
        
        configureUI()
        configureKeyboardDismiss()
        updateMode()
    }
    
    private func configureUI() {
        configureHeaderView()
        configureWhitePanelView()
        configureModeSegmentedControl()
        configureTextContent()
        configureInputFields()
        configureButtons()
        configureLayout()
    }
    
    private func configureHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = navyColor
        
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.text = "Bookly"
        logoLabel.textColor = .white
        logoLabel.font = UIFont(name: "Georgia-BoldItalic", size: 44) ?? .italicSystemFont(ofSize: 44)
        logoLabel.textAlignment = .left
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "기록할수록 나의 독서가 완성된다 ✦"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textAlignment = .left
        
        view.addSubview(headerView)
        headerView.addSubview(logoLabel)
        headerView.addSubview(subtitleLabel)
    }
    
    private func configureWhitePanelView() {
        whitePanelView.translatesAutoresizingMaskIntoConstraints = false
        whitePanelView.backgroundColor = backgroundColor
        whitePanelView.layer.cornerRadius = 34
        whitePanelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        whitePanelView.clipsToBounds = true
        
        view.addSubview(whitePanelView)
    }
    
    private func configureModeSegmentedControl() {
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        modeSegmentedControl.selectedSegmentIndex = 0
        modeSegmentedControl.backgroundColor = .white
        modeSegmentedControl.selectedSegmentTintColor = navyColor
        
        modeSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ],
            for: .normal
        )
        
        modeSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ],
            for: .selected
        )
        
        modeSegmentedControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        
        whitePanelView.addSubview(modeSegmentedControl)
    }
    
    private func configureTextContent() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = navyColor
        titleLabel.font = .boldSystemFont(ofSize: 27)
        titleLabel.textAlignment = .left
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 0
        
        helperLabel.translatesAutoresizingMaskIntoConstraints = false
        helperLabel.textColor = .secondaryLabel
        helperLabel.font = .systemFont(ofSize: 12, weight: .regular)
        helperLabel.textAlignment = .center
        helperLabel.numberOfLines = 0
        
        whitePanelView.addSubview(titleLabel)
        whitePanelView.addSubview(descriptionLabel)
        whitePanelView.addSubview(helperLabel)
    }
    
    private func configureInputFields() {
        configureInputContainer(
            emailContainerView,
            iconImageView: emailIconImageView,
            textField: emailTextField,
            iconName: "envelope.fill",
            placeholder: "이메일",
            keyboardType: .emailAddress,
            isSecure: false
        )
        
        configureInputContainer(
            passwordContainerView,
            iconImageView: passwordIconImageView,
            textField: passwordTextField,
            iconName: "lock.fill",
            placeholder: "비밀번호",
            keyboardType: .default,
            isSecure: true
        )
        
        configureInputContainer(
            confirmPasswordContainerView,
            iconImageView: confirmPasswordIconImageView,
            textField: confirmPasswordTextField,
            iconName: "checkmark.shield.fill",
            placeholder: "비밀번호 확인",
            keyboardType: .default,
            isSecure: true
        )
        
        whitePanelView.addSubview(emailContainerView)
        whitePanelView.addSubview(passwordContainerView)
        whitePanelView.addSubview(confirmPasswordContainerView)
    }
    
    private func configureInputContainer(
        _ containerView: UIView,
        iconImageView: UIImageView,
        textField: UITextField,
        iconName: String,
        placeholder: String,
        keyboardType: UIKeyboardType,
        isSecure: Bool
    ) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 18
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        containerView.clipsToBounds = true
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = navyColor.withAlphaComponent(0.86)
        iconImageView.contentMode = .scaleAspectFit
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 15, weight: .medium)
        textField.textColor = .label
        textField.tintColor = navyColor
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecure
        textField.returnKeyType = .done
        textField.delegate = self
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(textField)
        
        let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 54)
        heightConstraint.isActive = true
        
        if containerView === confirmPasswordContainerView {
            confirmPasswordHeightConstraint = heightConstraint
        }
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    private func configureButtons() {
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.backgroundColor = navyColor
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        primaryButton.layer.cornerRadius = 20
        primaryButton.clipsToBounds = true
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        
        switchModeButton.translatesAutoresizingMaskIntoConstraints = false
        switchModeButton.setTitleColor(navyColor, for: .normal)
        switchModeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        switchModeButton.addTarget(self, action: #selector(switchModeButtonTapped), for: .touchUpInside)
        
        whitePanelView.addSubview(primaryButton)
        whitePanelView.addSubview(switchModeButton)
    }
    
    private func configureLayout() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 300),
            
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 58),
            logoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 28),
            logoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -28),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: logoLabel.trailingAnchor),
            
            whitePanelView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -42),
            whitePanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whitePanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whitePanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            modeSegmentedControl.topAnchor.constraint(equalTo: whitePanelView.topAnchor, constant: 34),
            modeSegmentedControl.leadingAnchor.constraint(equalTo: whitePanelView.leadingAnchor, constant: 28),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: whitePanelView.trailingAnchor, constant: -28),
            modeSegmentedControl.heightAnchor.constraint(equalToConstant: 42),
            
            titleLabel.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: whitePanelView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: whitePanelView.trailingAnchor, constant: -30),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
            emailContainerView.leadingAnchor.constraint(equalTo: whitePanelView.leadingAnchor, constant: 28),
            emailContainerView.trailingAnchor.constraint(equalTo: whitePanelView.trailingAnchor, constant: -28),
            
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 14),
            passwordContainerView.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor),
            passwordContainerView.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor),
            
            confirmPasswordContainerView.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 14),
            confirmPasswordContainerView.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor),
            confirmPasswordContainerView.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor),
            
            primaryButton.topAnchor.constraint(equalTo: confirmPasswordContainerView.bottomAnchor, constant: 26),
            primaryButton.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor),
            primaryButton.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 54),
            
            switchModeButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 18),
            switchModeButton.centerXAnchor.constraint(equalTo: whitePanelView.centerXAnchor),
            
            helperLabel.leadingAnchor.constraint(equalTo: whitePanelView.leadingAnchor, constant: 34),
            helperLabel.trailingAnchor.constraint(equalTo: whitePanelView.trailingAnchor, constant: -34),
            helperLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
        ])
    }
    
    private func updateMode() {
        let isLoginMode = currentMode == .login
        
        modeSegmentedControl.selectedSegmentIndex = isLoginMode ? 0 : 1
        
        titleLabel.text = isLoginMode ? "다시 만난 독서 기록" : "Bookly 시작하기"
        descriptionLabel.text = isLoginMode
            ? "로그인하고 나만의 서재와 독서 기록을 이어서 확인해보세요."
            : "간단한 계정으로 읽고 싶은 책과 완독 기록을 관리해보세요."
        
        primaryButton.setTitle(isLoginMode ? "로그인하기" : "회원가입하기", for: .normal)
        
        switchModeButton.setTitle(
            isLoginMode ? "아직 계정이 없나요? 회원가입" : "이미 계정이 있나요? 로그인",
            for: .normal
        )
        
        helperLabel.text = isLoginMode
            ? "처음 사용하는 경우 회원가입을 먼저 진행해주세요."
            : "Firebase를 통해 계정 정보가 안전하게 관리됩니다."
        
        confirmPasswordContainerView.isHidden = isLoginMode
        confirmPasswordHeightConstraint?.constant = isLoginMode ? 0 : 54
        
        UIView.animate(withDuration: 0.18) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func modeChanged() {
        currentMode = modeSegmentedControl.selectedSegmentIndex == 0 ? .login : .signUp
        clearInput()
    }
    
    @objc private func switchModeButtonTapped() {
        currentMode = currentMode == .login ? .signUp : .login
        clearInput()
    }
    
    @objc private func primaryButtonTapped() {
        view.endEditing(true)
        
        switch currentMode {
        case .login:
            login()
        case .signUp:
            signUp()
        }
    }
    
    private func signUp() {
        let email = trimmed(emailTextField.text)
        let password = trimmed(passwordTextField.text)
        let confirmPassword = trimmed(confirmPasswordTextField.text)
        
        guard !email.isEmpty else {
            showAlert(message: "이메일을 입력해주세요.")
            return
        }
        
        guard email.contains("@") else {
            showAlert(message: "올바른 이메일 형식으로 입력해주세요.")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(message: "비밀번호는 6자 이상 입력해주세요.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(message: "비밀번호가 서로 일치하지 않아요.")
            return
        }
        
        setLoading(true)
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self else {
                return
            }
            
            if let error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(message: self.firebaseAuthErrorMessage(error))
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(message: "회원가입 정보를 확인할 수 없어요.")
                }
                return
            }
            
            self.createUserDocument(user: user, email: email)
        }
    }
    
    private func login() {
        let email = trimmed(emailTextField.text)
        let password = trimmed(passwordTextField.text)
        
        guard !email.isEmpty else {
            showAlert(message: "이메일을 입력해주세요.")
            return
        }
        
        guard !password.isEmpty else {
            showAlert(message: "비밀번호를 입력해주세요.")
            return
        }
        
        setLoading(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self else {
                return
            }
            
            if let error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(message: self.firebaseAuthErrorMessage(error))
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(message: "로그인 정보를 확인할 수 없어요.")
                }
                return
            }
            
            self.updateLastLoginAt(user: user)
        }
    }
    
    private func createUserDocument(user: User, email: String) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users")
            .document(user.uid)
            .setData(userData, merge: true) { [weak self] error in
                guard let self else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.setLoading(false)
                    
                    if let error {
                        self.showAlert(message: "사용자 정보 저장 중 오류가 발생했어요.\n\(error.localizedDescription)")
                        return
                    }
                    
                    self.moveToMainScreen()
                }
            }
    }
    
    private func updateLastLoginAt(user: User) {
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "updatedAt": FieldValue.serverTimestamp(),
            "lastLoginAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users")
            .document(user.uid)
            .setData(userData, merge: true) { [weak self] error in
                guard let self else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.setLoading(false)
                    
                    if let error {
                        self.showAlert(message: "로그인 정보 저장 중 오류가 발생했어요.\n\(error.localizedDescription)")
                        return
                    }
                    
                    self.moveToMainScreen()
                }
            }
    }
    
    private func moveToMainScreen() {
        BookStore.shared.startListeningForCurrentUser()
        
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.showMainScreen()
    }
    
    private func clearInput() {
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }
    
    private func setLoading(_ isLoading: Bool) {
        primaryButton.isEnabled = !isLoading
        switchModeButton.isEnabled = !isLoading
        modeSegmentedControl.isEnabled = !isLoading
        
        emailTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        confirmPasswordTextField.isEnabled = !isLoading
        
        primaryButton.alpha = isLoading ? 0.65 : 1.0
        
        let title: String
        
        switch currentMode {
        case .login:
            title = isLoading ? "로그인 중..." : "로그인하기"
        case .signUp:
            title = isLoading ? "가입 중..." : "회원가입하기"
        }
        
        primaryButton.setTitle(title, for: .normal)
    }
    
    private func trimmed(_ text: String?) -> String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    private func firebaseAuthErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case 17007:
            return "이미 가입된 이메일이에요."
        case 17008:
            return "올바른 이메일 형식이 아니에요."
        case 17009:
            return "비밀번호가 일치하지 않아요."
        case 17011:
            return "가입되지 않은 이메일이에요."
        case 17020:
            return "네트워크 연결을 확인해주세요."
        case 17026:
            return "비밀번호는 6자 이상 입력해주세요."
        default:
            return "로그인 처리 중 오류가 발생했어요.\n\(error.localizedDescription)"
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "확인해주세요",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            if currentMode == .login {
                primaryButtonTapped()
            } else {
                confirmPasswordTextField.becomeFirstResponder()
            }
        } else {
            primaryButtonTapped()
        }
        
        return true
    }
}
