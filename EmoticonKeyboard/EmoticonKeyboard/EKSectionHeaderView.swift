//
//  EKSectionHeaderView.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class EKSectionHeaderView: UICollectionReusableView {
    static let labelInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    static let labelMaxSize = CGSize(width: UIScreen.mainScreen().bounds.width-EKSectionHeaderView.labelInset.left-EKSectionHeaderView.labelInset.right, height: CGFloat.max)
    
    var label = TTTAttributedLabel()
    var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText {
                label.setText(attributedText.string, afterInheritingLabelAttributesAndConfiguringWithBlock: { (string) -> NSMutableAttributedString in
                    NSMutableAttributedString(attributedString: attributedText)
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        label.numberOfLines = 0
        label.userInteractionEnabled = true
        label.enabledTextCheckingTypes = NSDataDetector(types: NSTextCheckingType.Link.rawValue | NSTextCheckingType.Dash.rawValue, error: nil)!.checkingTypes
        addSubview(label)
        self.userInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = UIEdgeInsetsInsetRect(self.bounds, EKSectionHeaderView.labelInset)
    }
    
}