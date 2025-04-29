
import Foundation
import UIKit
import CoreData

final class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case alreadyInWatchlist
    }
    
    static let shared = DataPersistenceManager()
    
    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let item = TitleItem(context: context)
        
        item.id = model.id
        item.media_type = model.media_type
        item.original_name = model.original_name
        item.original_title = model.original_title
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_average = model.vote_average
        item.vote_count = model.vote_count
        item.isWatchlist = false
        
        do {
            try context.save()
            completion(.success(()))
        }catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func fetchingTitlesFromDatabase(completion: @escaping (Result<[TitleItem],Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<TitleItem>
        
        request = TitleItem.fetchRequest()
        
        do {
            let titles = try context.fetch(request)
            completion(.success(titles))
        }
        catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteTitleWith(model: TitleItem, completion: @escaping (Result<Void,Error>)->Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        }catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
    // MARK: - Watchlist (New Methods)

        /// Add a title to the watchlist if it isn't already in it
        func addTitleToWatchlist(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            // Check if the title is already in the watchlist
            let fetchRequest: NSFetchRequest<TitleItem> = TitleItem.fetchRequest()
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "id == %d", model.id),
                NSPredicate(format: "isWatchlist == true")
            ])
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    // Not in watchlist yet, so create a new record or reuse an existing TitleItem if you prefer
                    let item = TitleItem(context: context)
                    item.id = model.id
                    item.media_type = model.media_type
                    item.original_name = model.original_name
                    item.original_title = model.original_title
                    item.overview = model.overview
                    item.poster_path = model.poster_path
                    item.release_date = model.release_date
                    item.vote_average = model.vote_average
                    item.vote_count = model.vote_count
                    
                    // Mark as watchlist
                    item.isWatchlist = true
                    
                    try context.save()
                    completion(.success(()))
                } else {
                    // Title already in watchlist
                    completion(.failure(DatabaseError.alreadyInWatchlist))
                }
            } catch {
                completion(.failure(DatabaseError.failedToSaveData))
            }
        }
        
        /// Fetch all titles marked as watchlist
        func fetchWatchlistFromDatabase(completion: @escaping (Result<[TitleItem],Error>) -> Void) {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request: NSFetchRequest<TitleItem> = TitleItem.fetchRequest()
            request.predicate = NSPredicate(format: "isWatchlist == true")
            
            do {
                let watchlistItems = try context.fetch(request)
                completion(.success(watchlistItems))
            } catch {
                completion(.failure(DatabaseError.failedToFetchData))
            }
        }
        
        /// Remove a title from the watchlist
        func removeTitleFromWatchlist(model: TitleItem, completion: @escaping (Result<Void,Error>) -> Void) {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            // If you want to keep the record but just mark `isWatchlist = false`, do this:
            model.isWatchlist = false
            
            // OR if you want to remove it completely, just do:
            // context.delete(model)
            
            do {
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(DatabaseError.failedToDeleteData))
            }
        }
}
