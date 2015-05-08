//
//  EKMainCollectionViewController.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift
import TTTAttributedLabel
import ZLBalancedFlowLayout

let reuseIdentifier = "Cell", headerIdentifier = "header", footerIdentifier = "footer"

class EKMainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var rootCategories = Realm(path:NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.axcel.EmoticonKeyboard")!.path!.stringByAppendingPathComponent("default.realm")).objects(RootCategory)
    var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Emoticon Keyboard"
        collectionView?.backgroundColor = UIColor.whiteColor()

        // Register cell classes
        collectionView!.registerClass(EKCategoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        // Set realm notification block
        notificationToken = Realm().addNotificationBlock { [unowned self] note, realm in
            self.collectionView?.reloadData()
        }
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return rootCategories.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return rootCategories[section].values.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKCategoryCollectionViewCell
    
        let category = categoryForIndexPath(indexPath)
        cell.title = category.name
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
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
    
    func attributedStringForSection(section:Int) -> NSAttributedString? {
        let name = rootCategories[section].name
        let style = "font-family: 'HelveticaNeue-Light';font-size:5em;"
        let outputHtml = "<h2 style=\"\(style)\">\(name)</h2>"
        if let string = NSAttributedString(data: outputHtml.dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil, error: nil) {
            return string
        }
        return nil
    }
    
    var sizeCache = [String: CGSize]()
    func sizeForString(text: String) -> CGSize {
        if let cached = sizeCache[text] {
            return cached
        }
        var size = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        size = CGSize(width: min(320, size.width), height: size.height)
        sizeCache[text] = size
//        println("\(text): \(size)")
        return size
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        var layout = ZLBalancedFlowLayout()
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.rowHeight = 25
        layout.enforcesRowHeight = true
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        var emoticonsController = EKEmoticonsCollectionViewController(collectionViewLayout: layout)
        emoticonsController.category = categoryForIndexPath(indexPath)
        navigationController?.pushViewController(emoticonsController, animated: true)
    }

}
