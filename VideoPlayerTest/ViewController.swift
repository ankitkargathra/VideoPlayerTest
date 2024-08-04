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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        if let cell = tableView.mostVisibleCell() {
            if previousCell != cell {
                previousCell?.removePlayer()
                previousCell = nil
            } else {
                print("Same cell")
            }
        }
    }
    

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stopScroll()
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
        if (!decelerate) {
            stopScroll()
        }
    }
}

import UIKit

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
