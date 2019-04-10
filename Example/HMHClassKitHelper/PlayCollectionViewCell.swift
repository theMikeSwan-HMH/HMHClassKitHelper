//
//  PlayCollectionViewCell.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/27/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class PlayCollectionViewCell: UICollectionViewCell {
    var play: Play? {
        didSet {
            configureCell()
        }
    }
    
    
    @IBOutlet private weak var playCoverImage: UIImageView!
    @IBOutlet private weak var playLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    private func configureCell() {
        playLabel.text = play?.title
        playCoverImage.image = UIImage(named: play?.title.lowercased() ?? "")
    }
}
