//
//  EKEmoticonCollectionViewCell.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class EKEmoticonCollectionViewCell: UICollectionViewCell {
    var title = "" {
        didSet {
            titleLabel.text = title
            // titleLabel.sizeToFit()
            layoutSubviews()
        }
    }
    
    private var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
//        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 18)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let titleInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        let titleInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel.frame = UIEdgeInsetsInsetRect(contentView.frame, titleInset)
    }
    

}
