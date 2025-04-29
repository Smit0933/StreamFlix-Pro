//
//  WatchlistViewController.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 10/04/2025.
//


import UIKit

final class WatchlistViewController: UIViewController {

    private var watchlistTitles: [Title] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchlistUpdated), name: NSNotification.Name("WatchlistUpdated"), object: nil)
        title = "Watchlist"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        tableView.rowHeight = 150
        
        
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    @objc private func handleWatchlistUpdated() {
        loadWatchlist()
        tableView.reloadData()
    }

}

extension WatchlistViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let model = watchlistTitles[indexPath.row]
        // Configure using your TitleViewModel initializer (adjust if needed)
        cell.configure(with: TitleViewModel(titleName: model.original_title ?? model.original_name ?? "", posterURL: model.poster_path ?? ""))
        return cell
    }
    
    // Open movie detail on cell tap:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Fetch the selected movie model from your watchlist array.
        let selectedTitle = watchlistTitles[indexPath.row]
        
        // Instantiate the detail view controller.
        let previewVC = TitlePreviewViewController()
        
        // Create the dummy YouTube view.
        let dummyYoutubeView = VideoElement(id: IdVideoElement(kind: "youtube#video", videoId: "DEFAULT_VIDEO_ID"))
        
        // Prepare a view model for the detail screen.
        let previewModel = TitlePreviewViewModel(id: selectedTitle.id,
            titleLabel: selectedTitle.original_title ?? selectedTitle.original_name ?? "",
            overViewLabel: selectedTitle.overview ?? "",
            youtubeView: dummyYoutubeView,
            posterPath: selectedTitle.poster_path ?? ""   // Unwrap optional using ?? ""
        )
        
        // Configure the preview view controller with the view model.
        previewVC.configure(with: previewModel)
        
        // Push the detail view controller onto the navigation stack.
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWatchlist()
        tableView.reloadData()
    }
    
    private func loadWatchlist() {
        if let data = UserDefaults.standard.data(forKey: "watchlist"),
           let titles = try? JSONDecoder().decode([Title].self, from: data) {
            self.watchlistTitles = titles
        }
    }
}

