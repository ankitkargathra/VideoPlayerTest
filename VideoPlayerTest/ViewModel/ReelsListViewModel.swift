import Foundation
import AVFoundation

class ReelListViewModel {
    
    var reels: [ReelItems] = []
    
    init() {
        guard let reels = loadJson(filename: "reels") else {
            return
        }
        
        self.reels = reels
    }
    
    func loadJson(filename fileName: String) -> [ReelItems]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Reels.self, from: data)
                return jsonData.reels
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}


class Reels: Codable {
    var reels: [ReelItems]?
}

class ReelItems: Codable {
    var arr: [Reel]?
    
    var first: Reel? {
        return arr?[0]
    }
    
    var second: Reel? {
        return arr?[1]
    }
    
    var third: Reel? {
        return arr?[2]
    }
    
    var forth: Reel? {
        return arr?[3]
    }
}

class Reel: Codable {
    var _id: String?
    var video: String?
    var thumbnail: String?
    
    var thimbNailUrl: URL? {
        return URL.init(string: thumbnail ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case video
        case thumbnail
    }
    
    var player: AVPlayerLayer?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try values.decodeIfPresent(String.self, forKey: ._id)
        self.video = try values.decodeIfPresent(String.self, forKey: .video)
        self.thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
//        if let video = video, let url = URL(string: video) {
//            self.player = AVPlayerLayer.init(player: AVPlayer(url: url))
//            self.player?.videoGravity = .resizeAspectFill
//            self.player?.player?.currentItem?.reversePlaybackEndTime = CMTime.init(seconds: 3, preferredTimescale: 0)
//            self.player?.player?.rate = 2.0
//        }
    }
    
    

}
