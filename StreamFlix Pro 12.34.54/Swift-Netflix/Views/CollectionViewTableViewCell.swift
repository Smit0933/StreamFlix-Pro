import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCellDidTapCell(
        _ cell: CollectionViewTableViewCell,
        viewModel: TitlePreviewViewModel
    )
}

final class CollectionViewTableViewCell: UITableViewCell {

    static let identifier = "CollectionViewTableViewCell"
    weak var delegate: CollectionViewTableViewCellDelegate?
    private var titles: [Title] = []

    private let collectionView: UICollectionView = {
        // 1) Flow layout with spacing & insets
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(
            TitleCollectionViewCell.self,
            forCellWithReuseIdentifier: TitleCollectionViewCell.identifier
        )
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // remove any debug/background colors before shipping
        contentView.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate   = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }

    public func configure(with titles: [Title]) {
        self.titles = titles
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    private func downloadTitleAt(indexPath: IndexPath) {
        // unchanged…
    }

    private func addToWatchlistAt(indexPath: IndexPath) {
        // unchanged…
    }
}

extension CollectionViewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TitleCollectionViewCell.identifier,
                for: indexPath
            ) as? TitleCollectionViewCell,
            let posterPath = titles[indexPath.row].poster_path
        else {
            return UICollectionViewCell()
        }

        cell.configure(with: posterPath)
        return cell
    }

    // MARK: – Slide‑in + fade
    // MARK: – Zoom‑in + fade on appear
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
                // Start small & invisible
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Animate up to full size + full opacity with a spring
        UIView.animate(
            withDuration: 0.4,
            delay: 0.05 * Double(indexPath.row),
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut],
            animations: {
                cell.alpha = 1
                cell.transform = .identity
            },
            completion: nil
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        // MARK: – Bounce feedback on tap
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(
                withDuration: 0.15,
                animations: { cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                completion: { _ in
                    UIView.animate(
                        withDuration: 0.15,
                        delay: 0,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 3,
                        options: [],
                        animations: { cell.transform = .identity },
                        completion: nil
                    )
                }
            )
        }

        // MARK: – Existing trailer fetch + delegate call
        let title = titles[indexPath.row]
        guard
            let titleName = title.original_title ?? title.original_name,
            let titleOverview = title.overview
        else { return }

        APICaller.shared.getMovieTrailerKey(for: titleName) { [weak self] result in
            switch result {
            case .success(let key):
                guard let self = self else { return }
                let posterPath = title.poster_path ?? ""
                let viewModel = TitlePreviewViewModel(
                    id: title.id,
                    titleLabel: titleName,
                    overViewLabel: titleOverview,
                    youtubeView: key, // now the YouTube video key
                    posterPath: posterPath
                )
                DispatchQueue.main.async {
                    self.delegate?.collectionViewTableViewCellDidTapCell(self, viewModel: viewModel)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let downloadImage = UIImage(
                systemName: "arrow.down.circle.fill"
            )?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            
            let downloadAction = UIAction(
                title: "Download",
                image: downloadImage
            ) { _ in
                self.downloadTitleAt(indexPath: indexPath)
            }
            
            let watchlistAction = UIAction(
                title: "Add to Watchlist"
            ) { _ in
                self.addToWatchlistAt(indexPath: indexPath)
            }
            
            return UIMenu(options: .displayInline, children: [downloadAction, watchlistAction])
        }
    }
}
