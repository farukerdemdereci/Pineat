//
//  LoginViewController.swift
//  PinEatUIKit
//
//  Created by Faruk Dereci on 18.12.2025.
//

import UIKit

class LoginViewController: UIViewController {

    private let vm = AuthViewModel()
    
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
        label.text = "Giriş Yap"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.shadowColor = .black.withAlphaComponent(0.1)
        label.shadowOffset = CGSize(width: 1, height: 1)
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
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurView, at: 0)
        
        return view
    }()

    private let continueWithGoogleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google ile Devam Et", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "veya"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "E-posta"
        textfield.borderStyle = .roundedRect
        textfield.autocapitalizationType = .none
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    private let passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Şifre"
        textfield.borderStyle = .roundedRect
        textfield.isSecureTextEntry = true
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.backgroundColor = UIColor(red: 0.45, green: 0.72, blue: 0.52, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Şifremi unuttum?", for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hesap Oluştur", for: .normal)
        button.setTitleColor(UIColor(red: 0.32, green: 0.55, blue: 0.38, alpha: 1.0), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
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

        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: - Setup
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(pageTitleLabel)
        view.addSubview(glassCardView)
        
        let textFieldStackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        textFieldStackView.axis = .vertical
        textFieldStackView.spacing = 12

        let mainStackView = UIStackView(arrangedSubviews: [
            continueWithGoogleButton,
            orLabel,
            textFieldStackView,
            signInButton,
            resetPasswordButton,
            createAnAccountButton
        ])
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 18
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        glassCardView.addSubview(mainStackView)
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
            
            mainStackView.topAnchor.constraint(equalTo: glassCardView.topAnchor, constant: 30),
            mainStackView.leadingAnchor.constraint(equalTo: glassCardView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: glassCardView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: glassCardView.bottomAnchor, constant: -30),
            
            continueWithGoogleButton.heightAnchor.constraint(equalToConstant: 45),
            emailTextField.heightAnchor.constraint(equalToConstant: 45),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInButtonClicked), for: .touchUpInside)
        createAnAccountButton.addTarget(self, action: #selector(createAnAccountButtonClicked), for: .touchUpInside)
        resetPasswordButton.addTarget(self, action: #selector(resetPasswordButtonClicked), for: .touchUpInside)
    }

    @objc func signInButtonClicked() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Hata", message: "Lütfen tüm alanları doldurun.")
            return
        }
        
        activityIndicator.startAnimating()
        signInButton.setTitle("", for: .normal)
        signInButton.isEnabled = false
        
        Task {
            await vm.signIn(email: email, password: password)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.signInButton.setTitle("Giriş Yap", for: .normal)
                self.signInButton.isEnabled = true
                
                if let error = self.vm.errorMessage {
                    self.showAlert(title: "Hata", message: error)
                } else {
                    self.performSegue(withIdentifier: "toListVC", sender: nil)
                }
            }
        }
    }
    
    @objc func createAnAccountButtonClicked() { performSegue(withIdentifier: "toSignUpVC", sender: nil) }
    @objc func resetPasswordButtonClicked() { print("Reset Tıklandı") }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - Keyboard Handling
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

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
}
