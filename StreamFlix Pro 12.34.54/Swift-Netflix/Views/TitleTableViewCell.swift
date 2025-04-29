import UIKit
import SDWebImage

class TitleTableViewCell: UITableViewCell {

    static let identifier = "TitleTableViewCell"
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel : UILabel = {
       let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }
    public func configure(with model: TitleViewModel) {
        titleLabel.text = model.titleName

        let baseURL = "https://image.tmdb.org/t/p/w500"
        let completeURL: String
        if model.posterURL.hasPrefix("/") {
            completeURL = baseURL + model.posterURL
        } else {
            completeURL = baseURL + "/" + model.posterURL
        }
        guard let url = URL(string: completeURL) else {
            posterImageView.image = UIImage(systemName: "photo")
            return
        }
        posterImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))

        // Attempt to load the image
        posterImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
    }
    
    private func applyConstraints() {
        let imageConstraints = [
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ]
        
        let titleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(imageConstraints)
        NSLayoutConstraint.activate(titleConstraints)
    }
}
