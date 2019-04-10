//
//  SceneTableViewCell.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SceneTableViewCell: UITableViewCell {

    var scene: Scene? {
        didSet {
            configureCell()
        }
    }
    
    @IBOutlet private weak var sceneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    private func configureCell() {
        sceneLabel.text = scene?.title
    }

}
