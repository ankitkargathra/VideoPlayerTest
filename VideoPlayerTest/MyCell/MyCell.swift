import Foundation
import UIKit
import Kingfisher
import AVFoundation

class MyCell: UITableViewCell {
    
    var firstITem = PlayerView()
    var secondItem = PlayerView()
    var thirdItem = PlayerView()
    var forthItem = PlayerView()
    
    var topHStack =  UIStackView()
    var bottomHStack = UIStackView()
    var stackView = UIStackView()
    
    var reels: ReelItems?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(topHStack)
        stackView.addArrangedSubview(bottomHStack)
        topHStack.translatesAutoresizingMaskIntoConstraints = false
        bottomHStack.translatesAutoresizingMaskIntoConstraints = false
        
        topHStack.addArrangedSubview(firstITem)
        topHStack.addArrangedSubview(secondItem)
        firstITem.translatesAutoresizingMaskIntoConstraints = false
        secondItem.translatesAutoresizingMaskIntoConstraints = false
        
        bottomHStack.addArrangedSubview(thirdItem)
        bottomHStack.addArrangedSubview(forthItem)
        thirdItem.translatesAutoresizingMaskIntoConstraints = false
        forthItem.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            topHStack.heightAnchor.constraint(equalTo: bottomHStack.heightAnchor),
        ])
        
        NSLayoutConstraint.activate([
            firstITem.widthAnchor.constraint(equalTo: secondItem.widthAnchor),
            firstITem.heightAnchor.constraint(equalTo: secondItem.heightAnchor),
            
            thirdItem.widthAnchor.constraint(equalTo: forthItem.widthAnchor),
            thirdItem.heightAnchor.constraint(equalTo: forthItem.heightAnchor),
        ])
    }
    
    func setCell(viewModel: ReelListViewModel, indexPath: IndexPath) {
        
        reels = viewModel.reels[indexPath.row]
        
        if let first = reels?.first {
            firstITem.setItem(reel: first)
        }
        if let second = reels?.second {
            secondItem.setItem(reel: second)
        }
        
        if let third = reels?.third {
            thirdItem.setItem(reel: third)
        }
        
        if let forth = reels?.forth {
            forthItem.setItem(reel: forth)
        }
    }
    
    func setPlayer() {
        guard reels != nil else {
            return
        }
        firstITem.setupPlayer()
        secondItem.setupPlayer()
        thirdItem.setupPlayer()
        forthItem.setupPlayer()
        startPLayingLoop()
    }
    
    var timer: Timer?
    var currentIndex: Int = 0
    
    func startPLayingLoop() {
        currentIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] timer in
            guard let `self` = self else { return }
            self.currentIndex += 1
            self.play()
            
        })
        play()
    }
    
    func play() {
        if currentIndex == 0 {
            firstITem.play()
        } else if currentIndex == 1 {
            firstITem.stop()
            secondItem.play()
        } else if currentIndex == 2 {
            secondItem.stop()
            thirdItem.play()
        } else if currentIndex == 3 {
            thirdItem.stop()
            forthItem.play()
        } else {
            forthItem.stop()
            currentIndex = 0
            timer?.invalidate()
            startPLayingLoop()
        }
    }
    
    func removePlayer() {
        firstITem.removePlayer()
        secondItem.removePlayer()
        thirdItem.removePlayer()
        forthItem.removePlayer()
        timer?.invalidate()
        currentIndex = 0
    }
}

class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var imageView = UIImageView()
    
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
    
    func setupPlayer() {
        if let url = URL.init(string: self.reel?.video ?? "") {
            
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)
            self.playerLayer = AVPlayerLayer(player: player)
            playerLayer?.player?.currentItem?.reversePlaybackEndTime = CMTime.init(seconds: 3, preferredTimescale: 0)
            self.playerLayer?.videoGravity = .resizeAspectFill
            self.playerLayer?.frame = self.imageView.bounds
            self.imageView.layer.addSublayer(self.playerLayer!)
            reel?.player = playerLayer
        }
    }
    
    func play() {
        
        playerLayer?.player?.play()
    }
    
    func stop() {
        playerLayer?.player?.pause()
        playerLayer?.player?.seek(to: CMTime.zero)
    }
    
    func removePlayer() {
        self.playerLayer?.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
    }
}
