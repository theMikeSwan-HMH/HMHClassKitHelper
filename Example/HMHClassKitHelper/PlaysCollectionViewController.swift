//
//  PlaysCollectionViewController.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit


class PlaysCollectionViewController: UICollectionViewController {
    
    var plays = [Play]() {
        didSet {
            collectionView.reloadData()
        }
    }
    private let reuseIdentifier = "playCell"

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? PlayCollectionViewCell else {
            print("prepare for seque sender is not a play collection view cell!!")
            return
        }
        if segue.identifier == "showPlay" {
            let vc = segue.destination as! ActsTableViewController
            vc.play = cell.play
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plays.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlayCollectionViewCell
    
        // Configure the cell
        cell.play = plays[indexPath.row]
    
        return cell
    }

}
