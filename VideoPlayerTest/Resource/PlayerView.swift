//
//  PlayerView.swift
//  VideoPlayerTest
//
//  Created by Govind ravaliya on 04/08/24.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var imageView = UIImageView()
    private var timeObserverToken: Any?
    var reel: Reel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubView()
    }
    
    func addSubView() {
        addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageView.superview!.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: imageView.superview!.trailingAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: imageView.superview!.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageView.superview!.bottomAnchor)
        ])
    }
    
    func setItem(reel: Reel) {
        self.reel = reel
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: reel.thimbNailUrl, placeholder: UIImage(named: "placeholder"))
    }
    
//        func setupPlayer() {
//
//            if let url = URL.init(string: self.reel?.video ?? "") {
//                let item = AVPlayerItem(url: url)
//                let player = AVPlayer(playerItem: item)
//                self.playerLayer = AVPlayerLayer(player: player)
//                self.playerLayer?.videoGravity = .resizeAspectFill
//                self.playerLayer?.frame = self.imageView.bounds
//                self.imageView.layer.addSublayer(self.playerLayer!)
//            }
//        }
    
    var timer: Timer?
    func playCompltion(completion: @escaping () -> ()) {
        play()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            completion()
        }
//        timeObserverToken = self.playerLayer?.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { time in
//            let seconds = CMTimeGetSeconds(time)
//            print("Time \(seconds)")
//            if seconds > 6 {
//                completion()
//            }
//        }
    }
    
//        func setupPlayer() {
//
//
//            if let url = URL.init(string: self.reel?.video ?? "") {
////                CacheManager.shared.cacheVideo(from: url) { [weak self] localUrl in
////                    guard let `self` = self, let localUrl = localUrl else {
////                        return
////                    }
////                    DispatchQueue.main.async {
////                        let item = AVPlayerItem(url: localUrl)
////                        let player = AVPlayer(playerItem: item)
////                        self.playerLayer = AVPlayerLayer(player: player)
////                        self.playerLayer?.videoGravity = .resizeAspectFill
////                        self.playerLayer?.frame = self.imageView.bounds
////                        self.imageView.layer.addSublayer(self.playerLayer!)
////                    }
////
////                }
//
//                VideoDownloader.shared.downloadVideo(from: url) { [weak self] localUrl in
//                    guard let `self` = self, let localUrl = localUrl else {
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        let item = AVPlayerItem(url: localUrl)
//                        let player = AVPlayer(playerItem: item)
//                        self.playerLayer = AVPlayerLayer(player: player)
//                        self.playerLayer?.videoGravity = .resizeAspectFill
//                        self.playerLayer?.frame = self.imageView.bounds
//                        self.imageView.layer.addSublayer(self.playerLayer!)
//                    }
//
//                }
//            }
//        }
    
    func setupPlayer() {
//        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = reel?.player
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.playerLayer?.frame = self.imageView.bounds
        if self.playerLayer != nil {
            self.imageView.layer.addSublayer(self.playerLayer!)
        }
        self.playerLayer?.opacity = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.imageView.bounds
    }
    
    func play() {
        
        if playerLayer == nil && reel?.player != nil {
            setupPlayer()
        }
        
        playerLayer?.player?.play()
        playerLayer?.player?.playImmediately(atRate: 2)
    }
    
    func stop() {
        removeObserver()
        playerLayer?.player?.pause()
        playerLayer?.player?.seek(to: CMTime.zero)
        timer?.invalidate()
        timer = nil
    }
    
    func removeObserver() {
        if let token = timeObserverToken {
            playerLayer?.player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    func removePlayer() {
        removeObserver()
        self.playerLayer?.opacity = 0
        timer?.invalidate()
        timer = nil
        self.playerLayer?.player?.pause()
        
//        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
    }
}
