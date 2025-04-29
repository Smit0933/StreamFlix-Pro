

import Foundation

struct TitlePreviewViewModel {
    let id: Int64  
    let titleLabel: String
    let overViewLabel: String
    let youtubeView: VideoElement
    let posterPath: String?
    
}
struct VideoId: Codable {
    let videoId: String
}
