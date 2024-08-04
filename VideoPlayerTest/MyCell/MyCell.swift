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
    var playerArr: [PlayerView] = []
    
    var indexPath: IndexPath?
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
        firstITem.setupPlayer()
        secondItem.setupPlayer()
        thirdItem.setupPlayer()
        forthItem.setupPlayer()
//        startPLayingLoop()
        self.startPLayingLoop()
    }
    
    var timer: Timer?
    var currentIndex: Int = 0
    
    func startPLayingLoop() {
//        currentIndex = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] timer in
//            guard let `self` = self else { return }
//            self.currentIndex += 1
//            self.processNextItem()
//
//        })
//        processNextItem()
        
        print("Start \(indexPath)")
        firstITem.playCompltion { [weak self] in
            self?.firstITem.stop()
            self?.secondItem.playCompltion { [weak self] in
                self?.secondItem.stop()
                self?.thirdItem.playCompltion { [weak self] in
                    self?.thirdItem.stop()
                    self?.forthItem.playCompltion { [weak self] in
                        self?.forthItem.stop()
                        print("finished \(self?.indexPath)")
                        self?.startPLayingLoop()
                    }

                }
            }
        }
    }
    
    func processNextItem() {
        if currentIndex < playerArr.count {
            
            let item = playerArr[currentIndex]
            // Process the item here
            if currentIndex > 0 {
                playerArr[currentIndex - 1].stop()
                item.play()
            } else {
                item.play()
            }
        } else {
            playerArr[currentIndex - 1].stop()
            currentIndex = 0
            timer?.invalidate()
            startPLayingLoop()
        }
    }
    
    func removePlayer() {
        print("Stop \(indexPath)")
        firstITem.removePlayer()
        secondItem.removePlayer()
        thirdItem.removePlayer()
        forthItem.removePlayer()
        timer?.invalidate()
        currentIndex = 0
    }
}


