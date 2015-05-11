//
//  ZLBalancedFlowLayout+CustomLayout.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/10/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import ZLBalancedFlowLayout

extension ZLBalancedFlowLayout {
    class func layoutForMain() -> ZLBalancedFlowLayout {
        var layout = ZLBalancedFlowLayout()
        layout.headerReferenceSize = CGSize(width: 100, height: 100)
        layout.footerReferenceSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.rowHeight = 40
        layout.minimumLineSpacing = 5
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    class func layoutForEmoticons() -> ZLBalancedFlowLayout {
        var layout = ZLBalancedFlowLayout()
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.rowHeight = 25
        layout.enforcesRowHeight = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        return layout
    }
    
    class func layoutForMainKeyboard() -> ZLBalancedFlowLayout {
        var layout = ZLBalancedFlowLayout()
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.rowHeight = 30
        layout.enforcesRowHeight = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        return layout
    }

    class func layoutForEmoticonsKeyboard() -> ZLBalancedFlowLayout {
        return ZLBalancedFlowLayout.layoutForEmoticons()
    }

}
