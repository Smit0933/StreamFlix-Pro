//
//  RecommendationCell.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 17/04/2025.
//


import UIKit
import SDWebImage

class RecommendationCell: UICollectionViewCell {
    static let identifier = "RecommendationCell"

    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }

    func configure(with posterPath: String) {
        posterImageView.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)"), completed: nil)    }
}
