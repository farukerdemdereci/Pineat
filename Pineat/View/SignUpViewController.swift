//
//  SignUpViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 1.01.2026.
//

import UIKit

class SignUpViewController: UIViewController {

    private let vm: AuthViewModel
    
    init(vm: AuthViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "arkaplan")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Kayıt Ol"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.shadowColor = .black.withAlphaComponent(0.1)
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let glassCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        return view
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "E-posta"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifre"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Şifre Tekrar"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kayıt Ol", for: .normal)
        button.backgroundColor = UIColor(red: 0.45, green: 0.72, blue: 0.52, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Zaten bir hesabınız var mı?", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        setupKeyboardObservers()
    }
}

// MARK: - Actions
extension SignUpViewController {
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpClicked), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backClicked), for: .touchUpInside)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }

    @objc private func signUpClicked() {
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty,
                  let confirm = confirmPasswordTextField.text, !confirm.isEmpty else {
                showAlert(title: "Hata", message: "Lütfen tüm alanları doldurun.")
                return
            }
            
            if password != confirm {
                showAlert(title: "Hata", message: "Şifreler birbiriyle uyuşmuyor.")
                return
            }
            setLoading(true)
            
            Task {
                await vm.signUp(email: email, password: password)
                
                setLoading(false)
                
                if let error = vm.errorMessage {
                    showAlert(title: "Hata", message: error)
                    
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    
    @objc private func backClicked() {
        self.dismiss(animated: true)
    }
    
    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            signUpButton.setTitle("", for: .normal)
            signUpButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            signUpButton.setTitle("Kayıt Ol", for: .normal)
            signUpButton.isEnabled = true
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
}

// MARK: - Keyboard Handling
extension SignUpViewController {
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 2
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - Setup Views
extension SignUpViewController {
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(pageTitleLabel)
        view.addSubview(glassCardView)
        
        let textFieldStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, confirmPasswordTextField])
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [textFieldStack, signUpButton, backButton])
        mainStack.axis = .vertical
        mainStack.spacing = 18
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        glassCardView.addSubview(mainStack)
        glassCardView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageTitleLabel.bottomAnchor.constraint(equalTo: glassCardView.topAnchor, constant: -30),
            pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            glassCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassCardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            glassCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            glassCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            mainStack.topAnchor.constraint(equalTo: glassCardView.topAnchor, constant: 30),
            mainStack.leadingAnchor.constraint(equalTo: glassCardView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: glassCardView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: glassCardView.bottomAnchor, constant: -30),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 45),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 45),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor)
        ])
    }
}
