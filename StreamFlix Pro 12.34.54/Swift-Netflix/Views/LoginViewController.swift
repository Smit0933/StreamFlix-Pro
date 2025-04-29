//
//  LoginViewController.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 25/02/2025.
//

import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Elements
    
    // 1) Logo ImageView
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo")) // Replace with your logo image name
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let signupLabelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign Up", for: .normal)
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
        
        // Add subviews
        view.addSubview(logoImageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signupLabelButton)
        
        // Button targets
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        signupLabelButton.addTarget(self, action: #selector(goToSignup), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let fieldWidth = view.frame.size.width - 60
        let bottomPadding = view.safeAreaInsets.bottom
        
        // 2) Position the logo near the top center
        let logoSize: CGFloat = 100
        logoImageView.frame = CGRect(
            x: (view.frame.size.width - logoSize) / 2,
            y: 100,
            width: logoSize,
            height: logoSize
        )
        
        // 3) Position the text fields around the middle
        emailField.frame = CGRect(
            x: 30,
            y: view.frame.size.height / 2 - 60,
            width: fieldWidth,
            height: 40
        )
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.frame.maxY + 10,
            width: fieldWidth,
            height: 40
        )
        
        // 4) Push the login button & signup label near the bottom
        loginButton.frame = CGRect(
            x: 30,
            y: view.frame.size.height - 140 - bottomPadding,
            width: fieldWidth,
            height: 50
        )
        signupLabelButton.frame = CGRect(
            x: 30,
            y: loginButton.frame.maxY + 10,
            width: fieldWidth,
            height: 30
        )
    }
    
    // MARK: - Actions
    
    @objc private func handleLogin() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }

        // Firebase Login Attempt
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                // Show specific error message from Firebase
                strongSelf.showAlert(title: "Login Failed", message: error.localizedDescription)
            } else if authResult?.user == nil {
                // Extra safety check in case Firebase doesn't return a user
                strongSelf.showAlert(title: "Login Error", message: "Could not log in. Please try again.")
            } else {
                // Instead of pushing HomeViewController, call handleLoginSuccess()
                strongSelf.handleLoginSuccess()
            }
        }
    }
    
    func handleLoginSuccess() {
        let mainTabBarVC = MainTabBarViewController()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = mainTabBarVC
        }
        print("Replaced root with MainTabBarViewController")
    }
    
    @objc private func goToSignup() {
        let signupVC = SignupViewController()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // This hides the keyboard
        return true
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
