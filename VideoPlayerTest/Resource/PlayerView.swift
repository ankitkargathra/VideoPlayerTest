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
    var reel: Reel?
    var timer: Timer?
    var activityView = UIActivityIndicatorView(style: .medium)
    
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
        
        addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityView.trailingAnchor.constraint(equalTo: imageView.superview!.trailingAnchor, constant: -10),
            activityView.bottomAnchor.constraint(equalTo: activityView.superview!.bottomAnchor, constant: -10)
        ])
    }
    
    func setItem(reel: Reel) {
        self.reel = reel
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: reel.thimbNailUrl, placeholder: UIImage(named: "placeholder"))
        validateLoader()
    }
    
    func validateLoader() {
        if reel?.localUrl == nil {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
    
    func playCompltion(player: AVPlayerLayer?, completion: @escaping () -> ()) {
        validateLoader()
        self.playerLayer = player
        self.playerLayer?.videoGravity = .resizeAspectFill
        self.playerLayer?.frame = self.imageView.bounds
        
        if self.playerLayer != nil {
            self.imageView.layer.addSublayer(self.playerLayer!)
        }
        self.playerLayer?.opacity = 1
        
        play()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            completion()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.imageView.bounds
    }
    
    func play() {
        playerLayer?.player?.play()
        playerLayer?.player?.playImmediately(atRate: 2)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        playerLayer?.player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
}
