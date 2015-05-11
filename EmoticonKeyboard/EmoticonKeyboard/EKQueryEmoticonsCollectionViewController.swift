//
//  EKRecentEmoticonsCollectionViewController.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/10/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit

class EKQueryEmoticonsCollectionViewController: UICollectionViewController {
    
    var dataSourceDelegate = EKQueryEmoticonsCollectionViewDataSourceDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.registerClass(EKEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        
        dataSourceDelegate.sectionHeaderTitle = title
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

}
