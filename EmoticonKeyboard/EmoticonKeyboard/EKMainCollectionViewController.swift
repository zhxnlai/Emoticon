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
import ReactiveUI

let reuseIdentifier = "Cell", headerIdentifier = "header", footerIdentifier = "footer"

class EKMainCollectionViewController: UICollectionViewController {

    var notificationToken: NotificationToken?

    var dataSourceDelegate = EKCategoriesCollectionViewDataSourceDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Emoticon Keyboard"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain) { button in
            self.navigationController?.pushViewController(EKSettingsTableViewController(style: .Grouped), animated: true)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Recent", style: .Plain) { button in
            var queryEmoticonsCVC = EKQueryEmoticonsCollectionViewController(collectionViewLayout:  ZLBalancedFlowLayout.layoutForEmoticons())
            queryEmoticonsCVC.title = "Recent"
            queryEmoticonsCVC.dataSourceDelegate.emoticons = Realm.recentlyUsedEmoticons()
            self.navigationController?.pushViewController(queryEmoticonsCVC, animated: true)
        }

        // Register cell classes
        collectionView!.registerClass(EKCategoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)

        var primaryCategories = Realm().objects(PrimaryCategory)
        dataSourceDelegate.primaryCategories = primaryCategories
        dataSourceDelegate.didSelectCategory = {category in
            var emoticonsController = EKEmoticonsCollectionViewController(collectionViewLayout: ZLBalancedFlowLayout.layoutForEmoticons())
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
