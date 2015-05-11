//
//  EKRecentEmoticonsCollectionViewDataSourceDelegate.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/10/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift

class EKQueryEmoticonsCollectionViewDataSourceDelegate: EKEmoticonsCollectionViewDataSourceDelegate {
    
    var emoticons : Results<Emoticon>! {
        didSet {
            clearCache()
        }
    }
    var displayLimit = 100
    
    override func numberOfEmoticons() -> Int {
        if let emoticons = emoticons {
            return min(emoticons.count, displayLimit)
        }
        return 0
    }
    override func emoticonForIndexPath(indexPath: NSIndexPath) -> Emoticon {
        return emoticons[indexPath.item]
    }

}
