import UIKit
import FirebaseAuth
import SDWebImage  // If you want to load the user's photo from a URL

class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 1.0, alpha: 1.0) // Light purple
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profilePlaceholder"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // We'll set the corner radius in viewDidLayoutSubviews once we know its size
        return imageView
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "No Email"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.tintColor = .systemRed
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 1) Fetch current user info from Firebase
        configureUserInfo()
        
        // 2) Add subviews
        view.addSubview(headerView)
        headerView.addSubview(profileImageView)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        
        // 3) Layout subviews with Auto Layout
        headerView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header at the top, about 1/3 of the screen height
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            
            // Profile image in the center of the header
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Email label below the header
            emailLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Logout button at the bottom
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 4) Add action for logout
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make the profile image circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
    
    // MARK: - Fetch User Info
    
    private func configureUserInfo() {
        if let user = Auth.auth().currentUser {
            let email = user.email ?? "No Email"
            emailLabel.text = email
            
            // If you have a photo URL in Firebase, load it with SDWebImage:
            if let photoURL = user.photoURL {
                profileImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "profilePlaceholder"))
            }
        } else {
            emailLabel.text = "No user logged in"
        }
    }
    
    // MARK: - Logout Action
    
    @objc private func didTapLogout() {
        print("Logging out...")
        do {
            // 1) Sign out from Firebase
            try Auth.auth().signOut()
            
            // 2) Replace the root view controller with your LoginViewController
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                
                let loginVC = LoginViewController() // or your actual login screen
                let nav = UINavigationController(rootViewController: loginVC)
                
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
                    window.rootViewController = nav
                }
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
