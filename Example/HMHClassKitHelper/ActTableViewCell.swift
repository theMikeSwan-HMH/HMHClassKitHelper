//
//  ActTableViewCell.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ActTableViewCell: UITableViewCell {

    var act: Act? {
        didSet {
            configureCell()
        }
    }
    
    
    @IBOutlet private weak var actLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    private func configureCell() {
        actLabel.text = act?.displayTitle
    }

}
