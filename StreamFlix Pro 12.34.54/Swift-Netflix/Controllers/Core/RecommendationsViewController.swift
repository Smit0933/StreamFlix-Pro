//
//  RecommendationsViewController.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 17/04/2025.
//


import UIKit

class RecommendationsViewController: UIViewController, UICollectionViewDelegate {
    // Fetched movie details for display
    private var titles: [Title] = []
    // this will be injected before presentation
    var movieIDs: [Int64] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 180)
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RecommendationCell.self, forCellWithReuseIdentifier: "cell")
        // Load metadata for recommended movies
        for id in movieIDs {
            APICaller.shared.getMovieDetail(id: id) { [weak self] (result: Result<Title, Error>) in
                switch result {
                case .success(let title):
                    self?.titles.append(title)
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print("Recommendation load failed:", error.localizedDescription)
                }
            }
        }
    }
}

extension RecommendationsViewController: UICollectionViewDataSource {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecommendationCell
        let title = titles[indexPath.item]
        // Assuming RecommendationCell expects only the poster URL string
        if let posterPath = title.poster_path {
            cell.configure(with: posterPath)
        }
        return cell
    }
}
