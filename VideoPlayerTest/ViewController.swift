//
//  ViewController.swift
//  Test
//
//  Created by Govind ravaliya on 04/08/24.
//

import UIKit
import Reachability

class ViewController: UIViewController {
    
    let reachability = try! Reachability()
    private var viewModel = ReelListViewModel()
    var previousCell: MyCell?
    @IBOutlet weak var tableView: UITableView!
    var previousIndexPath: IndexPath?
    var reels: [ReelItems] {
        viewModel.reels
    }
    @IBOutlet weak var txtLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addReachabilityObserver()
        tableView.allowsSelection = false
    }
    
    func addReachabilityObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
            do{
              try reachability.startNotifier()
            } catch {
              print("could not start reachability notifier")
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let previousIndexPath = self.tableView.getMostVisibleIndexPath() {
                self.previousIndexPath = previousIndexPath
                let cell = self.tableView.cellForRow(at: previousIndexPath) as? MyCell
                cell?.startPLayingLoop()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? MyCell else {
            return UITableViewCell()
        }
        cell.setCell(viewModel: viewModel, indexPath: indexPath)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 400 + 120 spacing above cell
        return 510
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let indexPath = tableView.getMostVisibleIndexPath() {
            
            if previousIndexPath != indexPath {
                if let previousIndexPath = previousIndexPath, let prevCell = tableView.cellForRow(at: previousIndexPath) as? MyCell {
                    prevCell.removePlayer()
                    print("Removed indexPAth = \(previousIndexPath)")
                }
                
                if let prevCell = tableView.cellForRow(at: indexPath) as? MyCell {
                    prevCell.setPlayer()
                    print("New indexPAth = \(indexPath)")
                }
                previousIndexPath = indexPath
            }
        }
        
    }
}

extension ViewController {
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi, .cellular:
          VideoDownloader.shared.restartAllDownloadTasks()
          txtLabel.text = "You are online"
          txtLabel.textColor = .green
      case .unavailable:
          VideoDownloader.shared.cancelAllDownloadTasks()
          txtLabel.text = "You are offline"
          txtLabel.textColor = .red
      }
    }
}

extension UITableView {

    func getMostVisibleIndexPath() -> IndexPath? {
        // Calculate the center of the visible rect
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let visibleRectCenter = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        // Get all visible cells
        let visibleCells = self.visibleCells
        
        // Variables to store the most visible indexPath and the minimum distance
        var mostVisibleIndexPath: IndexPath?
        var minimumDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for cell in visibleCells {
            // Calculate the center of the cell in the table view's coordinate system
            let cellCenter = self.convert(cell.center, to: self)
            
            // Calculate the distance from the cell's center to the visible rect center
            let distance = sqrt(pow(cellCenter.x - visibleRectCenter.x, 2) +
                                pow(cellCenter.y - visibleRectCenter.y, 2))
            
            // Update the most visible indexPath if this one is closer
            if distance < minimumDistance {
                minimumDistance = distance
                mostVisibleIndexPath = self.indexPath(for: cell)
            }
        }
        
        return mostVisibleIndexPath
    }
}
