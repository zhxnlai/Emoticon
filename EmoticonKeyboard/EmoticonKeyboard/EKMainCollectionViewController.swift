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

class EKMainCollectionViewController: UICollectionViewController {

    var notificationToken: NotificationToken?

    var dataSourceDelegate = EKCategoriesCollectionViewDataSourceDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Emoticon Keyboard"
        
        // Register cell classes
        collectionView!.registerClass(EKCategoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        var rootCategories = Realm().objects(RootCategory)
        dataSourceDelegate.rootCategories = rootCategories
        dataSourceDelegate.didSelectCategory = {category in
            var layout = ZLBalancedFlowLayout()
            layout.headerReferenceSize = CGSizeZero
            layout.footerReferenceSize = CGSizeZero
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.rowHeight = 25
            layout.enforcesRowHeight = true
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 5
            var emoticonsController = EKEmoticonsCollectionViewController(collectionViewLayout: layout)
            emoticonsController.category = category
            self.navigationController?.pushViewController(emoticonsController, animated: true)
        }
        
        // Set realm notification block
        notificationToken = Realm().addNotificationBlock { [unowned self] note, realm in
            self.collectionView?.reloadData()
        }
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.dataSource = dataSourceDelegate
        collectionView?.delegate = dataSourceDelegate
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
