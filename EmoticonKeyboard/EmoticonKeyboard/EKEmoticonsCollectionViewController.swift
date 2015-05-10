//
//  EKCategoryCollectionViewController.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift

class EKEmoticonsCollectionViewController: UICollectionViewController {

    var category: Category? {
        didSet {
            dataSourceDelegate.category = category
            collectionView?.reloadData()
        }
    }
    
    var dataSourceDelegate = EKEmoticonsCollectionViewDataSourceDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category!.name

        // Register cell classes
        self.collectionView!.registerClass(EKEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        dataSourceDelegate.category = category
        dataSourceDelegate.hideSectionHeader = true
        dataSourceDelegate.didSelectEmoticon = {emoticon in
            let text = emoticon.value
            var pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = text
        }
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.dataSource = dataSourceDelegate
        collectionView?.delegate = dataSourceDelegate
        
        // Do any additional setup after loading the view.
        collectionView?.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
