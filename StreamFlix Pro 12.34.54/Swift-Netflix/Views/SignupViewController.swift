//
//  SignupViewController.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 25/02/2025.
//

import UIKit
import FirebaseAuth

final class SignupViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let createAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Create an Account"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label // <-- Use .label for automatic dark/light mode
        label.textAlignment = .center
        return label
    }()
    
    // 1) Add a logo image view
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo")) // <-- replace with your logo asset name
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
    
    private let confirmPasswordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(createAccountLabel)
        view.addSubview(logoImageView)       // <-- add the logo here
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(signupButton)
        
        // Button target
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let fieldWidth = view.frame.size.width - 60
        
        // Position the "Create an Account" label near the top
        let labelHeight: CGFloat = 40
        createAccountLabel.frame = CGRect(
            x: 30,
            y: 100,
            width: fieldWidth,
            height: labelHeight
        )
        
        // 2) Place the logo below the label
        let logoSize: CGFloat = 100
        logoImageView.frame = CGRect(
            x: (view.frame.size.width - logoSize) / 2,
            y: createAccountLabel.frame.maxY + 20,
            width: logoSize,
            height: logoSize
        )
        
        // Calculate total height for fields + button: 190
        let totalFormHeight: CGFloat = 190
        let bottomMargin: CGFloat = 60
        
        // 3) Keep the fields near the bottom
        let startY = view.frame.size.height - bottomMargin - totalFormHeight
        
        emailField.frame = CGRect(
            x: 30,
            y: startY,
            width: fieldWidth,
            height: 40
        )
        
        passwordField.frame = CGRect(
            x: 30,
            y: emailField.frame.maxY + 10,
            width: fieldWidth,
            height: 40
        )
        
        confirmPasswordField.frame = CGRect(
            x: 30,
            y: passwordField.frame.maxY + 10,
            width: fieldWidth,
            height: 40
        )
        
        signupButton.frame = CGRect(
            x: 30,
            y: confirmPasswordField.frame.maxY + 20,
            width: fieldWidth,
            height: 50
        )
    }
    
    // MARK: - Actions
    
    @objc private func handleSignup() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill all fields")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Firebase Create User
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                strongSelf.showAlert(title: "Signup Error", message: error.localizedDescription)
            } else {
                // Navigate to HomeViewController on success
                let homeVC = MainTabBarViewController()
                strongSelf.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
    }
    
    // MARK: - Helper
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
