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

class EKCategoriesCollectionViewDataSourceDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var rootCategories : Results<RootCategory>!
    var didSelectCategory: (Category -> ())?
    var sectionHeaderFontSize = "5em"
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let rootCategories = rootCategories {
            return rootCategories.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let rootCategories = rootCategories {
            return rootCategories[section].values.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKCategoryCollectionViewCell
        
        let category = categoryForIndexPath(indexPath)
        cell.title = category.name
        
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
        if let didSelectCategory = didSelectCategory {
            didSelectCategory(categoryForIndexPath(indexPath))
        }
    }
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if var cell = collectionView.cellForItemAtIndexPath(indexPath) {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                cell.alpha = 0.5
            })
        }
    }
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        if var cell = collectionView.cellForItemAtIndexPath(indexPath) {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                cell.alpha = 1
            })
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForString(categoryForIndexPath(indexPath).name)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return headerSizeForSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    func headerSizeForSection(section: Int) -> CGSize {
        if let attributedString = attributedStringForSection(section) {
            var size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: EKSectionHeaderView.labelMaxSize, limitedToNumberOfLines: 0)
            return size
        }
        return CGSizeZero
    }
    
    // MARK: - ()
    func categoryForIndexPath(indexPath: NSIndexPath) -> Category {
        return rootCategories[indexPath.section].values[indexPath.item]
    }
    
    var attributedStringCache = [Int: NSAttributedString]()
    func attributedStringForSection(section:Int) -> NSAttributedString? {
        if let cached = attributedStringCache[section] {
            return cached
        }
        let name = rootCategories[section].name
        let style = "font-family: 'HelveticaNeue-Light';font-size:\(sectionHeaderFontSize);"
        let outputHtml = "<h2 style=\"\(style)\">\(name)</h2>"
        if let string = NSAttributedString(data: outputHtml.dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil) {
            attributedStringCache[section] = string
            return string
        }
        return nil
    }
    
    var sizeCache = [String: CGSize]()
    let maxStringWidth = min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
    func sizeForString(text: String) -> CGSize {
        if let cached = sizeCache[text] {
            return cached
        }
        var size = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        size = CGSize(width: min(maxStringWidth, size.width), height: size.height)
        sizeCache[text] = size
        return size
    }
    
}