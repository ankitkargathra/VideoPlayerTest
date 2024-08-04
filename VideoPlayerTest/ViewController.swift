//
//  ViewController.swift
//  Test
//
//  Created by Govind ravaliya on 04/08/24.
//

import UIKit

class ViewController: UIViewController {
    
    private var viewModel = ReelListViewModel()
    var previousCell: MyCell?
    @IBOutlet weak var tableView: UITableView!
    var previousIndexPath: IndexPath?
    var reels: [ReelItems] {
        viewModel.reels
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ReelCount \(reels.count)")
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.previousCell = self.tableView.mostVisibleCell()
            self.previousCell?.setPlayer()
        }
    }


}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reels.count
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
//        if let cell = tableView.mostVisibleCell() {
//            if previousCell != cell {
//                previousCell?.removePlayer()
//                previousCell = nil
//            } else {
//                print("Same cell")
//            }
//        }
        
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
        
//        print(tableView.getMostVisibleIndexPath())
    }
    

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        stopScroll()
    }
    
    func stopScroll() {
        if let cell = tableView.mostVisibleCell() {
            if previousCell != cell {
                previousCell = cell
                previousCell?.setPlayer()
            } else {
                print("Same cell")
            }
        }

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if (!decelerate) {
//            stopScroll()
//        }
    }
}

extension UITableView {
    func mostVisibleCell() -> MyCell? {

        guard let indexPaths = indexPathsForVisibleRows else {
            return nil
        }

        if let fullyVisibleIndexPaths = indexPaths.filter({ indexPath in
            // Filter out all the partially visible cells
            let cellFrame = rectForRow(at: indexPath)
            let isCellFullyVisible = bounds.contains(cellFrame)
            return isCellFullyVisible
        }).first {
            return cellForRow(at: fullyVisibleIndexPaths) as? MyCell
        }

        return nil

    }
}

//import UIKit

//extension UITableView {
//
//    func mostVisibleCell() -> MyCell? {
//        // Calculate the center of the visible rect
//        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
//        let visibleRectCenter = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//
//        // Get all visible cells
//        let visibleCells = self.visibleCells
//
//        // Variables to store the closest cell and the minimum distance
//        var closestCell: UITableViewCell?
//        var minimumDistance: CGFloat = CGFloat.greatestFiniteMagnitude
//
//        for cell in visibleCells {
//            // Calculate the center of the cell in the table view's coordinate system
//            let cellCenter = self.convert(cell.center, to: self)
//
//            // Calculate the distance from the cell's center to the visible rect center
//            let distance = sqrt(pow(cellCenter.x - visibleRectCenter.x, 2) +
//                                pow(cellCenter.y - visibleRectCenter.y, 2))
//
//            // Update the closest cell if this one is closer
//            if distance < minimumDistance {
//                minimumDistance = distance
//                closestCell = cell
//            }
//        }
//
//        return closestCell as? MyCell
//    }
//}

import UIKit

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
