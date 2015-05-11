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
    
    var category: Category? {
        didSet {
            if let category = category  {
                sectionHeaderTitle = category.name
            }
            clearCache()
        }
    }
    var sectionHeaderTitle: String?
    
    func clearCache() {
        attributedStringCache.removeAll()
    }
    
    var didSelectEmoticon: (Emoticon -> ())?
    var sectionHeaderFontSize = "2em"
    var hideSectionHeader = false
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfEmoticons()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKEmoticonCollectionViewCell
        
        // Configure the cell
        cell.title = emoticonForIndexPath(indexPath).value
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch (kind) {
        case UICollectionElementKindSectionHeader:
            var view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, forIndexPath: indexPath) as! EKSectionHeaderView
            if let attributedString = attributedStringForSection(indexPath.section) {
                view.attributedText = attributedString
            }
            return view
        case UICollectionElementKindSectionFooter:
            var view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier, forIndexPath: indexPath) as! UICollectionReusableView
            return view
        default:
            break
        }
        return UICollectionReusableView(frame: CGRectZero)
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        var emoticon = emoticonForIndexPath(indexPath)
        var realm = Realm()
        realm.write {
            emoticon.useCount++
            emoticon.lastUsed = NSDate()
        }
        if let didSelectEmoticon = didSelectEmoticon {
            didSelectEmoticon(emoticon)
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
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForString(emoticonForIndexPath(indexPath).value)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerSizeForSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    func headerSizeForSection(section: Int) -> CGSize {
        if hideSectionHeader {
            return CGSizeZero
        }
        if let attributedString = attributedStringForSection(section) {
            var size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: EKSectionHeaderView.labelMaxSize, limitedToNumberOfLines: 0)
            return size
        }
        return CGSizeZero
    }

    // MARK: - ()
    func numberOfEmoticons() -> Int {
        if let category = category {
            return category.values.count
        }
        return 0
    }
    func emoticonForIndexPath(indexPath: NSIndexPath) -> Emoticon {
        return category!.values[indexPath.item]
    }
    
    var attributedStringCache = [Int: NSAttributedString]()
    func attributedStringForSection(section:Int) -> NSAttributedString? {
        if let cached = attributedStringCache[section] {
            return cached
        }
        if let name = sectionHeaderTitle {
            let style = "font-family: 'HelveticaNeue-Light';font-size:\(sectionHeaderFontSize);"
            let outputHtml = "<h2 style=\"\(style)\">\(name)</h2>"
            if let string = NSAttributedString(data: outputHtml.dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil) {
                attributedStringCache[section] = string
                return string
            }
        }
        return nil
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