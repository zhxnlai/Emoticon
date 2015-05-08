//
//  EKEmoticonsCollectionViewDataSourceDelegate.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/8/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift
import TTTAttributedLabel

class EKEmoticonsCollectionViewDataSourceDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var category: Category?
    var didSelectEmoticon: (Emoticon -> ())?

    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let category = category {
            return category.values.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKEmoticonCollectionViewCell
        
        // Configure the cell
        cell.title = emoticonForIndexPath(indexPath).value
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForString(emoticonForIndexPath(indexPath).value)
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if let didSelectEmoticon = didSelectEmoticon {
            didSelectEmoticon(emoticonForIndexPath(indexPath))
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if var cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        if var cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.backgroundColor = UIColor.clearColor()
        }
    }
    
    // MARK: - ()
    func emoticonForIndexPath(indexPath: NSIndexPath) -> Emoticon {
        return category!.values[indexPath.item]
    }
    
    var sizeCache = [String: CGSize]()
    func sizeForString(text: String) -> CGSize {
        if let cached = sizeCache[text] {
            return cached
        }
        var size = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(18)])
        size = CGSize(width: min(320, size.width), height: size.height)
        sizeCache[text] = size
        return size
    }

}