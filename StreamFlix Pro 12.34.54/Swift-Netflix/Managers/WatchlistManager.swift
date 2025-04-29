//
//  WatchlistManager.swift
//  StreamFlix Pro
//
//  Created by Patel Smit on 17/04/2025.
//


import Foundation

struct WatchlistManager {
    static let shared = WatchlistManager()
    private let key = "watchlistIDs"
    private let defaults = UserDefaults.standard

    /// The saved list of movie IDs
    var allIDs: [Int64] {
        return defaults.array(forKey: key) as? [Int64] ?? []
    }

    func contains(id: Int64) -> Bool {
        return allIDs.contains(id)
    }

    func add(id: Int64) {
        var ids = allIDs
        guard !ids.contains(id) else { return }
        ids.append(id)
        defaults.set(ids, forKey: key)
    }

    func remove(id: Int64) {
        var ids = allIDs
        ids.removeAll { $0 == id }
        defaults.set(ids, forKey: key)
    }
}