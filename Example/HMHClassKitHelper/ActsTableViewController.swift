//
//  ActsTableViewController.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ActsTableViewController: UITableViewController {
    
    var play: Play? {
        didSet {
            if let play = play {
                acts = play.acts
                self.title = play.title
            }
        }
    }
    
    var acts = [Act]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actCell", for: indexPath) as! ActTableViewCell

        // Configure the cell...
        cell.act = acts[indexPath.row]

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? ActTableViewCell else {
            print("prepare for seque sender is not an act table view cell!!")
            return
        }
        if segue.identifier == "showAct" {
            let vc = segue.destination as! ScenesTableViewController
            vc.act = cell.act
            vc.play = play
        }
    }

}
