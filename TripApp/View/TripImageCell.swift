//
//  TripImageCell.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/3/1.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import UIKit
import SDWebImage

class TripImageCell: UICollectionViewCell {
    
    @IBOutlet private weak var tripImageView: UIImageView!
    public var imageURL: String? {
        didSet {
            guard let imageURL = imageURL else { return }
            tripImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "placeholder"))
        }
    }
}
