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
    
    var primaryCategories : Results<PrimaryCategory>! {
        didSet {
            categoryIndexCached = [NSIndexPath : (Int, Int)]()
            numberOfItemsCache = [Int: Int]()
            attributedStringCache = [Int: NSAttributedString]()
        }
    }
    var didSelectCategory: (Category -> ())?
    var sectionHeaderFontSize = "5em"
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let primaryCategories = primaryCategories {
            return primaryCategories.count
        }
        return 0
    }
    
    var numberOfItemsCache = [Int: Int]()
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let primaryCategories = primaryCategories {
            if let cached = numberOfItemsCache[section] {
                return cached
            }
            var numberOfItems = 0
            for secondaryCategory in primaryCategories[section].values {
                numberOfItems += secondaryCategory.values.count
            }
            numberOfItemsCache[section] = numberOfItems
            return numberOfItems
        }
        return 0
    }
    
    let colors = [
        UIColor(red:  83/255.0, green:  89/255.0, blue:  91/255.0, alpha: 1),
        UIColor(red: 142/255.0, green: 146/255.0, blue: 148/255.0, alpha: 1),
        UIColor(red: 110/255.0, green: 115/255.0, blue: 117/255.0, alpha: 1),
        UIColor(red:  57/255.0, green:  62/255.0, blue:  64/255.0, alpha: 1),
        UIColor(red:  23/255.0, green:  26/255.0, blue:  28/255.0, alpha: 1),
    ]
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKCategoryCollectionViewCell
        
        let (sndCategory, p, category, i) = secondaryCategoryAndCategoryForIndexPath(indexPath)
        cell.title = category.name
        cell.color = colors[p%colors.count]
        
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
    var categoryIndexCached = [NSIndexPath : (Int, Int)]()
    func secondaryCategoryAndCategoryForIndexPath(indexPath: NSIndexPath) -> (SecondaryCategory, Int, Category, Int) {
        let secondaryCategories = primaryCategories[indexPath.section].values
        if let cached = categoryIndexCached[indexPath] {
            let (p, s) = cached
            return (secondaryCategories[p], p, secondaryCategories[p].values[s], s)
        }
        var item = indexPath.item
        for i in 0..<secondaryCategories.count {
            let secondaryCategory = secondaryCategories[i]
            if item - secondaryCategory.values.count < 0 {
                categoryIndexCached[indexPath] = (i, item)
               return (secondaryCategory, i, secondaryCategory.values[item], item)
            } else {
                item -= secondaryCategory.values.count
            }
        }
        return (secondaryCategories.first!, 0, secondaryCategories.first!.values.first!, 0)
    }
    func categoryForIndexPath(indexPath: NSIndexPath) -> Category {
        let (_, _, c, _) = secondaryCategoryAndCategoryForIndexPath(indexPath)
        return c
    }
    
    var attributedStringCache = [Int: NSAttributedString]()
    func attributedStringForSection(section:Int) -> NSAttributedString? {
        if let cached = attributedStringCache[section] {
            return cached
        }
        let name = primaryCategories[section].name
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