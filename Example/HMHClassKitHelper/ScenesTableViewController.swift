//
//  ScenesTableViewController.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ScenesTableViewController: UITableViewController {
    
    var play: Play?
    var act: Act? {
        didSet {
            if let act = act {
                scenes = act.scenes
                self.title = act.displayTitle
            }
        }
    }
    var scenes = [Scene]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as! SceneTableViewCell

        // Configure the cell...
        cell.scene = scenes[indexPath.row]
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? SceneTableViewCell else {
            print("prepare for seque sender is not a scene table view cell!!")
            return
        }
        if segue.identifier == "showScene" {
            let vc = segue.destination as! SceneViewController
            vc.scene = cell.scene
            vc.play = play
            vc.act = act
        }
    }

}
