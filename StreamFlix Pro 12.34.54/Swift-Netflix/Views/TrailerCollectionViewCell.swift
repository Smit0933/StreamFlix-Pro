//
//  TrailerCollectionViewCell.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 29/04/2025.
//


import UIKit
import WebKit

class TrailerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrailerCell"

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public func configure(with videoID: String) {
        guard let url = URL(string: "https://youtube.com/embed/\(videoID)") else { return }
        webView.load(URLRequest(url: url))
    }
}