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
    
    var completedDownlaod: (() -> ())?
    var thimbNailUrl: URL? {
        return URL.init(string: thumbnail ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case video
        case thumbnail
    }
    
    var _player: AVPlayerLayer?
    
    var player: AVPlayerLayer? {
        if let url = URL(string: video ?? "") ,_player == nil {
            if let lclUrl = VideoDownloader.shared.cachedVideoURL(for: url) {
                let item = AVPlayerItem(url: lclUrl)
                let player = AVPlayer(playerItem: item)
                self._player = AVPlayerLayer(player: player)
                return self._player
            } else {
                return nil
            }
        } else {
            return _player
        }
    }
    
    
    func validateCompletedDownload() {
        VideoDownloader.shared.downloadCompletion = { [weak self] localUrl in
            guard let localUrl = localUrl else {return }
            guard let `self` = self else {
                return
            }
            if self.video == localUrl.absoluteString {
                
                let item = AVPlayerItem(url: localUrl)
                let player = AVPlayer(playerItem: item)
                self._player = AVPlayerLayer(player: player)
            }
        }
    }
    
    func startDownload() {
        if let video = video, let url = URL(string: video) {
            VideoDownloader.shared.downloadVideo(from: url) { [weak self] localUrl in
                guard let `self` = self, let localUrl = localUrl else {
                    return
                }
                let item = AVPlayerItem(url: localUrl)
                let player = AVPlayer(playerItem: item)
                self._player = AVPlayerLayer(player: player)
                
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try values.decodeIfPresent(String.self, forKey: ._id)
        self.video = try values.decodeIfPresent(String.self, forKey: .video)
        self.thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        startDownload()
        validateCompletedDownload()
    }
}
