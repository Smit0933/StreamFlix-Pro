import Foundation
import UIKit
import FirebaseCore
import FirebaseAppCheck



struct Constants {
    static let API_KEY = "a45b9f8cba44cc26481d2166fa3a69c1"
    static let BASE_URL = "https://api.themoviedb.org"
    static let YT_API_KEY = "AIzaSyCKFG99Piyd74yeCjCzB9OEDbSl2e3wCfM"
    static let YT_BASE_URL = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    /// Shared singleton instance
    static let shared = APICaller()
    private let session: URLSession = {
        #if targetEnvironment(simulator)
        // Use ephemeral session on Simulator to avoid HTTP/3 QUIC protocol violations
        return URLSession(configuration: .ephemeral)
        #else
        return URLSession.shared
        #endif
    }()
    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            
            FirebaseApp.configure()

            #if DEBUG
            // Disable App Check for development builds
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            #endif

            return true
        }
    
    func getTrendingMovies(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/trending/movie/day?api_key=\(Constants.API_KEY)") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getTrendingTVs(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/trending/tv/day?api_key=\(Constants.API_KEY)") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getUpcoming(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/movie/upcoming?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getPopular(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/movie/popular?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func topRated(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/movie/top_rated?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getDiscoverMovies(completion: @escaping (Result<[Title],Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/discover/movie?api_key=\(Constants.API_KEY)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func search(with query: String, completion: @escaping (Result<[Title],Error>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        guard let url = URL(string: "\(Constants.BASE_URL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    func getMovieWithQuery(with query: String, completion: @escaping (Result<VideoElement,Error>) -> Void) {
        
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode query: \(query)")
            return
        }
        guard let url = URL(string: "\(Constants.YT_BASE_URL)q=\(query)&key=\(Constants.YT_API_KEY)") else {return}
        
        let task = session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let raw = String(data: data, encoding: .utf8) ?? "<no data>"
                print("❌ YouTube API error status code: \(httpResponse.statusCode). Response:\n\(raw)")
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                if results.items.isEmpty {
                    print("⚠️ YouTube API returned no items for query: \(query)")
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                completion(.success(results.items[0]))
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "<no data>"
                print("❌ YouTube API decode error. Raw response:\n\(raw)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    /// Fetch full movie details for a given movie ID
    func getMovieDetail(id: Int64, completion: @escaping (Result<Title, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.BASE_URL)/3/movie/\(id)?api_key=\(Constants.API_KEY)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                let movie = try JSONDecoder().decode(Title.self, from: data)
                completion(.success(movie))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    func getCBFRecommendations(for title: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let base = "https://us-central1-streamflix-pro.cloudfunctions.net/recommendMovies"
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(base)?title=\(encodedTitle)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        print("🌐 Requesting from URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            // ✅ NEW: Check if the response status is 200 OK
            if !(200...299).contains(httpResponse.statusCode) {
                let raw = String(data: data, encoding: .utf8) ?? "<no data>"
                print("❌ Server returned error status: \(httpResponse.statusCode)")
                print("❌ Raw response:\n\(raw)")
                completion(.failure(APIError.failedToGetData))
                return
            }

            do {
                let result = try JSONDecoder().decode([String: [String]].self, from: data)
                let recommendations = result["recommendations"] ?? []
                completion(.success(recommendations))
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode string"
                print("❌ Decode error. Raw response:\n\(responseString)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
    func searchMovie(with title: String, completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(Constants.BASE_URL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            do {
                let results = try JSONDecoder().decode(TrendingTitleResponce.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    func searchYoutubeTrailer(for query: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://youtube.googleapis.com/youtube/v3/search?q=\(encodedQuery)%20trailer&key=\(Constants.YT_API_KEY)&part=snippet&type=video&maxResults=1") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        print("🌐 YouTube API Request URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                if let videoID = response.items.first?.id.videoId {
                    completion(.success(videoID))
                } else {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                let rawResponse = String(data: data, encoding: .utf8) ?? "<no data>"
                print("❌ Failed to decode YouTube response. Raw response:\n\(rawResponse)")
                completion(.failure(error))
            }
        }

        task.resume()
    }}

extension APICaller {
    /// Fetch YouTube trailer key for a movie title
    func getMovieTrailerKey(for title: String, completion: @escaping (Result<VideoElement, Error>) -> Void) {
        getMovieWithQuery(with: "\(title) trailer") { result in
            switch result {
            case .success(let videoElement):
                completion(.success(videoElement))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
