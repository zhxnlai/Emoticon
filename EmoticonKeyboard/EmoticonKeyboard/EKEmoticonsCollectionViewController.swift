//
//  EKCategoryCollectionViewController.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift

class EKEmoticonsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var category: Category? {
        didSet {
            collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category!.name
        collectionView?.backgroundColor = UIColor.whiteColor()
        

        // Register cell classes
        self.collectionView!.registerClass(EKEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: UICollectionViewDataSource

//    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        //#warning Incomplete method implementation -- Return the number of sections
//        return 0
//    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return category!.values.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let text = emoticonForIndexPath(indexPath).value
        var pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = text
    }
    
    override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        if var cell = collectionView.cellForItemAtIndexPath(indexPath) {
            cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
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
