import Foundation
import AVKit
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
    var playerArr: [PlayerView] = []
    
    var indexPath: IndexPath?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
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
        stackView.spacing = 5
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
        topHStack.spacing = 5
        bottomHStack.spacing = 5
        
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
        
        playerArr = [firstITem, secondItem, thirdItem, forthItem]
    }
    
    func setCell(viewModel: ReelListViewModel, indexPath: IndexPath) {
        self.indexPath = indexPath
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
        startPLayingLoop()
    }
    
    var timer: Timer?
    var currentIndex: Int = 0
    
    func startPLayingLoop() {
        
        //print("Paying indexpath \(self.indexPath)")
        firstITem.playCompltion(player: getPlayer(lclUrl: firstITem.reel?.localUrl)) { [weak self] in
            guard let self = self else { return }
            self.firstITem.stop()
            self.secondItem.playCompltion(player: self.getPlayer(lclUrl: self.secondItem.reel?.localUrl)) { [weak self] in
                guard let self = self else { return }
                self.secondItem.stop()
                self.thirdItem.playCompltion(player: self.getPlayer(lclUrl: self.thirdItem.reel?.localUrl)){ [weak self] in
                    guard let self = self else { return }
                    self.thirdItem.stop()
                    self.forthItem.playCompltion(player: self.getPlayer(lclUrl: self.forthItem.reel?.localUrl)) { [weak self] in
                        guard let self = self else { return }
                        self.forthItem.stop()
                        self.startPLayingLoop()
                    }
                }
            }
        }
    }
    
    func getPlayer(lclUrl: URL?) -> AVPlayerLayer? {
        guard let lclUrl = lclUrl else {
            return nil
        }
        let item = AVPlayerItem(url: lclUrl)
        let player = AVPlayer(playerItem: item)
        self.playerLayer = AVPlayerLayer(player: player)
        return self.playerLayer
    }
    
    func removePlayer() {
        timer?.invalidate()
        currentIndex = 0
        firstITem.stop()
        secondItem.stop()
        thirdItem.stop()
        forthItem.stop()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removePlayer()
    }
}


