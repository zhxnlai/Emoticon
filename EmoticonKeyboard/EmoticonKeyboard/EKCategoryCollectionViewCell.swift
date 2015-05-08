//
//  EKCategoryCollectionViewCell.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class EKCategoryCollectionViewCell: UICollectionViewCell {
    var title = "" {
        didSet {
            titleLabel.text = title
//            titleLabel.sizeToFit()
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
//        contentView.backgroundColor = UIColor(white: 0.918, alpha: 1)
//        titleLabel.textColor = UIColor(white: 1, alpha: 0.85)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
//        titleLabel.shadowColor = UIColor(white: 0, alpha: 0.85)
//        titleLabel.shadowOffset = CGSize(width: 0.5, height: 1)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 100)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let titleInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
//        let titleInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel.frame = UIEdgeInsetsInsetRect(bounds, titleInset)
    }
    

}