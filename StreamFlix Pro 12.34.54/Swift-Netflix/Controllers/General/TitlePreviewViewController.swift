import UIKit
import WebKit
import FirebaseAuth
import FirebaseFunctions
import FirebaseFirestore

class TitlePreviewViewController: UIViewController {
    // MARK: – Models & Services
    private var titlePreviewModel: TitlePreviewViewModel?
    private let db = Firestore.firestore()
    private var trailerIDs: [String] = []

    private lazy var trailersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 200)
        layout.minimumLineSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrailerCollectionViewCell.self, forCellWithReuseIdentifier: "TrailerCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // Track thumb state
    private var isThumbedUp = false
    private var ratingDocumentID: String?
    
    // MARK: – UI Elements

    private let backgroundDimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Scroll View and Content View for scrolling
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Video teaser
    private let webview: WKWebView = {
        let w = WKWebView()
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    // Poster thumbnail
    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // Title & overview
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 22, weight: .bold)
        return l
    }()
    private let overviewLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 18)
        l.numberOfLines = 0
        return l
    }()
    
    // Buttons: Watchlist, Rate, Download
    private let watchlistButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        return b
    }()
    private let watchlistLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Watchlist"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        return l
    }()
    private lazy var watchlistStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [watchlistButton, watchlistLabel])
        s.axis = .vertical; s.alignment = .center; s.spacing = 4
        return s
    }()
    
    private let thumbsUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        return b
    }()
    private let thumbsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Rate"
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        return l
    }()
    private lazy var thumbsStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [thumbsUpButton, thumbsLabel])
        s.axis = .vertical; s.alignment = .center; s.spacing = 4
        return s
    }()
    
    private let downloadButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Download", for: .normal)
        return b
    }()
    
    // Horizontal container
    private let buttonStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillProportionally
        s.alignment = .center
        s.spacing = 20
        return s
    }()

    // MARK: – Recommendations UI
    private let recommendationsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "More Like This"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private let recommendationsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: – Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Add background dim view
        view.addSubview(backgroundDimView)
        NSLayoutConstraint.activate([
            backgroundDimView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundDimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundDimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundDimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add scrollView and contentView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Add subviews to contentView
        [webview, posterImageView, titleLabel, overviewLabel, buttonStack].forEach(contentView.addSubview)
        contentView.addSubview(recommendationsLabel)
        contentView.addSubview(recommendationsContainer)
        recommendationsContainer.addSubview(trailersCollectionView)
        NSLayoutConstraint.activate([
            trailersCollectionView.topAnchor.constraint(equalTo: recommendationsContainer.topAnchor),
            trailersCollectionView.leadingAnchor.constraint(equalTo: recommendationsContainer.leadingAnchor),
            trailersCollectionView.trailingAnchor.constraint(equalTo: recommendationsContainer.trailingAnchor),
            trailersCollectionView.bottomAnchor.constraint(equalTo: recommendationsContainer.bottomAnchor)
        ])
        // Hide recommendations until a rating is given
        recommendationsLabel.isHidden = true
        recommendationsContainer.isHidden = true
        [watchlistStack, thumbsStack, downloadButton].forEach(buttonStack.addArrangedSubview)

        // Style & sizing
        [watchlistButton, thumbsUpButton, downloadButton].forEach(styleButton)
        watchlistButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        thumbsUpButton.contentEdgeInsets  = .init(top: 8, left: 8, bottom: 8, right: 8)
        downloadButton.contentEdgeInsets = .init(top: 10, left: 40, bottom: 10, right: 40)
        NSLayoutConstraint.activate([
            watchlistButton.widthAnchor.constraint(equalToConstant: 40),
            thumbsUpButton.widthAnchor.constraint(equalToConstant: 40)
            
        ])

        // Targets
        watchlistButton.addTarget(self, action: #selector(watchlistButtonTapped), for: .touchUpInside)
        thumbsUpButton.addTarget(self, action: #selector(thumbsUpTapped),         for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped),    for: .touchUpInside)

        // Layout
        configureConstraints()

        // Poster zoom/fade-in initial state
        self.posterImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.posterImageView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut]) {
            self.posterImageView.transform = .identity
            self.posterImageView.alpha = 1.0
            self.backgroundDimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
                swipeDown.direction = .down
            self.view.addGestureRecognizer(swipeDown)        }
    }
    
    // MARK: – Layout
    @objc private func handleSwipeDown() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureConstraints() {
        let webV = [
            webview.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 150),
            webview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webview.heightAnchor.constraint(equalToConstant: 250)
        ]
        let posterV = [
            posterImageView.topAnchor.constraint(equalTo: webview.bottomAnchor, constant: 25),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            posterImageView.widthAnchor.constraint(equalToConstant: 150),
            posterImageView.heightAnchor.constraint(equalToConstant: 225)
        ]
        let titleV = [
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25)
        ]
        let overviewV = [
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25)
        ]
        let buttonV = [
            buttonStack.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            buttonStack.heightAnchor.constraint(equalToConstant: 70)
        ]

        NSLayoutConstraint.activate(webV + posterV + titleV + overviewV + buttonV)

        // Recommendations constraints
        let recommendationsLabelV = [
            recommendationsLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            recommendationsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            recommendationsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25)
        ]
        let recommendationsContainerV = [
            recommendationsContainer.topAnchor.constraint(equalTo: recommendationsLabel.bottomAnchor, constant: 10),
            recommendationsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recommendationsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recommendationsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(recommendationsLabelV + recommendationsContainerV)
    }
    
    // MARK: – Styling
    
    private func styleButton(_ b: UIButton) {
        let bg = UIColor { tc in tc.userInterfaceStyle == .dark ? .systemGray : .white }
        let fg = UIColor { tc in tc.userInterfaceStyle == .dark ? .white     : .systemGray }
        b.backgroundColor = bg
        b.setTitleColor(fg, for: .normal)
        b.tintColor = fg
        b.layer.cornerRadius = 10
        b.layer.borderWidth = 1
        b.layer.borderColor = fg.cgColor
        b.clipsToBounds = true
    }
    
    // MARK: – Configuration
    
    func configure(with model: TitlePreviewViewModel) {
        titlePreviewModel = model
        titleLabel.text    = model.titleLabel
        overviewLabel.text = model.overViewLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Load YouTube preview
        let vid = model.youtubeView.id.videoId
           guard !vid.isEmpty,
                 let url = URL(string: "https://youtube.com/embed/\(vid)") else {
               return
           }
           webview.load(URLRequest(url: url))
        // Watchlist icon state
        let inList = isInWatchlist(id: Int(model.id))
        let symbol = isInWatchlist(id: Int(model.id)) ? "checkmark" : "plus"
        watchlistButton.setImage(.init(systemName: symbol), for: .normal)
        // Restore saved rating state
        loadRatingState(for: model.id)
    }

    /// Load any existing rating from Firestore and update the thumbs-up button
    private func loadRatingState(for movieID: Int64) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("userMovieEvents")
          .whereField("userID", isEqualTo: userID)
          .whereField("movieID", isEqualTo: movieID)
          .whereField("eventType", isEqualTo: "rating")
          .getDocuments { [weak self] snapshot, error in
              guard let self = self,
                    error == nil,
                    let docs = snapshot?.documents,
                    let first = docs.first
              else { return }
              self.ratingDocumentID = first.documentID
              self.isThumbedUp = true
              DispatchQueue.main.async {
                  self.thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                  self.recommendationsLabel.isHidden = false
                  self.recommendationsContainer.isHidden = false
              }
              self.fetchRecommendations(basedOn: movieID)
        }
    }
    
    // MARK: – Actions
    
    @objc private func downloadButtonTapped() {
        guard let model = titlePreviewModel else { return }
        // Persist download through DataPersistenceManager
        let titleItem = Title(
            id: model.id,
            media_type: "movie",
            original_name: nil,
            original_title: model.titleLabel,
            poster_path: model.posterPath,
            overview: model.overViewLabel,
            vote_count: 0,
            release_date: "",
            vote_average: 0.0
        )
        DataPersistenceManager.shared.downloadTitleWith(model: titleItem) { [weak self] result in
            switch result {
            case .success():
                // Notify Downloads screen
                NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
                DispatchQueue.main.async {
                    self?.downloadButton.setTitle("Downloaded", for: .normal)
                    self?.downloadButton.isEnabled = false
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func watchlistButtonTapped() {
        guard let model = titlePreviewModel else { return }
        let inList = isInWatchlist(id: Int(model.id))
        
        if inList { removeFromWatchlist(id: Int(model.id)) }
        else      { saveToWatchlist(model)             }
        
        let symbol = inList ? "plus" : "checkmark"
        watchlistButton.setImage(.init(systemName: symbol), for: .normal)
    }
    
    @objc private func thumbsUpTapped() {
        guard let model = titlePreviewModel,
              let userID = Auth.auth().currentUser?.uid else { return }
        
        if isThumbedUp {
            // undo
            if let doc = ratingDocumentID {
                db.collection("userMovieEvents").document(doc).delete()
                thumbsUpButton.setImage(.init(systemName: "hand.thumbsup"), for: .normal)
                isThumbedUp = false
            }
        } else {
            // rate
            var ref: DocumentReference?
            let data: [String:Any] = [
                "userID": userID,
                "movieID": model.id,
                "eventType":"rating",
                "rating":1,
                "timestamp": FieldValue.serverTimestamp()
            ]
            ref = db.collection("userMovieEvents").addDocument(data: data) { [weak self] err in
                guard err == nil, let docID = ref?.documentID else { return }
                self?.ratingDocumentID = docID
                self?.thumbsUpButton.setImage(.init(systemName: "hand.thumbsup.fill"), for: .normal)
                self?.isThumbedUp = true
                DispatchQueue.main.async {
                    self?.recommendationsLabel.isHidden = false
                    self?.recommendationsContainer.isHidden = false
                }
                self?.fetchRecommendations(basedOn: model.id)
            }
        }
    }
    
    // MARK: – Recommendations
    
    private func fetchRecommendations(basedOn movieID: Int64) {
        guard let model = titlePreviewModel else { return }
        let title = model.titleLabel
        let base = "https://us-central1-streamflix-pro.cloudfunctions.net/recommendMovies"
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(base)?title=\(encodedTitle)") else {
            print("❌ Invalid URL for title: \(title)")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch recommendations:", error?.localizedDescription ?? "Unknown error")
                return
            }

            do {
                let result = try JSONDecoder().decode([String: [String]].self, from: data)
                let recommendedTitles = result["recommendations"] ?? []

                // Optionally search these titles with your existing TMDb API to get IDs
                self?.searchTitlesForTrailers(recommendedTitles)
            } catch {
                print("❌ JSON decode error:", error)
            }
        }.resume()
    }
    private func searchTitlesForTrailers(_ titles: [String]) {
        var foundTrailerIDs = [String]()
        let group = DispatchGroup()

        titles.forEach { title in
            group.enter()
            APICaller.shared.searchYoutubeTrailer(for: title) { result in
                switch result {
                case .success(let videoID):
                    foundTrailerIDs.append(videoID)
                case .failure(let error):
                    print("Trailer search failed for \(title):", error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard !foundTrailerIDs.isEmpty else {
                print("⚠️ No trailers found for recommendations.")
                return
            }
            self?.showRecommendedTrailers(with: foundTrailerIDs)
        }
    }
    private func showRecommendedTrailers(with videoIDs: [String]) {
        self.trailerIDs = videoIDs
        trailersCollectionView.alpha = 0.0
        trailersCollectionView.reloadData()
        recommendationsLabel.isHidden = false
        recommendationsContainer.isHidden = false
        let trailerHeight: CGFloat = 220 // 200 for cell + 20 margin
        let newHeightConstraint = recommendationsContainer.heightAnchor.constraint(equalToConstant: trailerHeight)
        newHeightConstraint.isActive = true
        UIView.animate(withDuration: 0.5) {
            self.trailersCollectionView.alpha = 1.0
        }
    }
   
    
    // MARK: – Watchlist Storage

    private func saveToWatchlist(_ model: TitlePreviewViewModel) {
        // 1) Local
        WatchlistManager.shared.add(id: model.id)
        // Persist watchlist locally
        let newTitle = Title(
            id: model.id,
            media_type: "movie",
            original_name: nil,
            original_title: model.titleLabel,
            poster_path: model.posterPath,
            overview: model.overViewLabel,
            vote_count: 0,
            release_date: "",
            vote_average: 0.0
        )
        var currentList: [Title] = []
        if let data = UserDefaults.standard.data(forKey: "watchlist"),
           let saved = try? JSONDecoder().decode([Title].self, from: data) {
            currentList = saved
        }
        currentList.append(newTitle)
        if let data = try? JSONEncoder().encode(currentList) {
            UserDefaults.standard.set(data, forKey: "watchlist")
        }
        // Notify Watchlist screen
        NotificationCenter.default.post(name: NSNotification.Name("WatchlistUpdated"), object: nil)
        // 2) Firestore event
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let data: [String:Any] = [
            "userID": userID,
            "movieID": model.id,
            "eventType": "watchlist_add",
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("userMovieEvents").addDocument(data: data)
    }

    private func removeFromWatchlist(id: Int) {
        // 1) Local
        WatchlistManager.shared.remove(id: Int64(id))
        // Update persisted watchlist
        var currentList: [Title] = []
        if let data = UserDefaults.standard.data(forKey: "watchlist"),
           let saved = try? JSONDecoder().decode([Title].self, from: data) {
            currentList = saved
        }
        currentList.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(currentList) {
            UserDefaults.standard.set(data, forKey: "watchlist")
        }
        // Notify Watchlist screen
        NotificationCenter.default.post(name: NSNotification.Name("WatchlistUpdated"), object: nil)
        // 2) Firestore event
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let data: [String:Any] = [
            "userID": userID,
            "movieID": id,
            "eventType": "watchlist_remove",
            "timestamp": FieldValue.serverTimestamp()
        ]
        db.collection("userMovieEvents").addDocument(data: data)
    }

    private func isInWatchlist(id: Int) -> Bool {
        return WatchlistManager.shared.contains(id: Int64(id))
    }}
extension TitlePreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trailerIDs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrailerCell", for: indexPath) as? TrailerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let videoID = trailerIDs[indexPath.row]
        cell.configure(with: videoID)
        return cell
    }
}
