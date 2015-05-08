//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift
import ZLBalancedFlowLayout
import Cartography

let reuseIdentifier = "Cell", headerIdentifier = "header", footerIdentifier = "footer"
let appGroupId = "group.com.axcel.EmoticonKeyboard"

class KeyboardViewController: UIInputViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var nextKeyboardButton: UIButton!
    var menuButton: UIButton!
    var enterButton: UIButton!
    var deleteButton: UIButton!
    
    var openAccessLabel: UILabel?

    let group = ConstraintGroup()

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
        
    }
    
    var rootCategories : Results<RootCategory>!
    var currentCategory: Category? {
        didSet {
            emoticonsCollectionView?.reloadData()
        }
    }
    var notificationToken: NotificationToken?

    var categoriesCollectionView: UICollectionView?
    var emoticonsCollectionView: UICollectionView?

    var collectionViews = UIView()
    var controlViews = UIView()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        let screenSize = UIScreen.mainScreen().bounds.size
//        let screenH = screenSize.height;
//        let screenW = screenSize.width;
//        let isLandscape =  view.frame.size.width >= screenW-10
//        println(isLandscape ? "Screen: Landscape" : "Screen: Potriaint")
//        var height = isLandscape ? 125 : 300
//        
//        layout(view!, replace: group) { view1 in
//            view1.height == CGFloat(height) ~ 901
//            view1.width == screenW  ~ 900
//        }

//        view.setNeedsUpdateConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        // next menu space return delete
        
        // Perform custom UI setup here
        nextKeyboardButton = UIButton.buttonWithType(.System) as! UIButton
        nextKeyboardButton.setTitle(NSLocalizedString("🌐", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        nextKeyboardButton.sizeToFit()
        nextKeyboardButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        menuButton = UIButton.buttonWithType(.System) as! UIButton
        menuButton.setTitle(NSLocalizedString("✔️", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        menuButton.sizeToFit()
        menuButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        menuButton.addTarget(self, action: "showMenu", forControlEvents: .TouchUpInside)
        
        enterButton = UIButton.buttonWithType(.System) as! UIButton
        enterButton.setTitle(NSLocalizedString("➕", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        enterButton.sizeToFit()
        enterButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        enterButton.addTarget(self, action: "insertReturn", forControlEvents: .TouchUpInside)
        
        deleteButton = UIButton.buttonWithType(.System) as! UIButton
        deleteButton.setTitle(NSLocalizedString("🔚", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        deleteButton.sizeToFit()
        deleteButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        deleteButton.addTarget(self, action: "deleteText", forControlEvents: .TouchUpInside)
        
        controlViews.addSubview(nextKeyboardButton)
        controlViews.addSubview(menuButton)
        controlViews.addSubview(enterButton)
        controlViews.addSubview(deleteButton)
        
        layout(nextKeyboardButton, controlViews) { view1, view2 in
            view1.left == view2.left
            view1.centerY == view2.centerY
        }
        
        layout(deleteButton, controlViews) { view1, view2 in
            view1.right == view2.right
            view1.centerY == view2.centerY
        }
        
        layout(menuButton, nextKeyboardButton) { view1, view2 in
            view1.left == view2.right + 20
            view1.bottom == view2.bottom
        }
        
        layout(enterButton, deleteButton) { view1, view2 in
            view1.right == view2.left - 20
            view1.bottom == view2.bottom
        }
        
//        collectionViews.backgroundColor = UIColor.redColor()
//        controlViews.backgroundColor = UIColor.blueColor()
        
        view.addSubview(collectionViews)
        view.addSubview(controlViews)
        collectionViews.setTranslatesAutoresizingMaskIntoConstraints(false)
        controlViews.setTranslatesAutoresizingMaskIntoConstraints(false)
//        view.setTranslatesAutoresizingMaskIntoConstraints(false)

        layout(collectionViews, controlViews) { view1, view2 in
//            view1.width   == (view1.superview!.width)
//            view2.width   == view1.width
            view1.left == view1.superview!.left
            view2.left == view1.left
            view1.right == view1.superview!.right
            view2.right == view1.right

            view1.top == view1.superview!.top
            view1.bottom  == view2.top
            view2.bottom == view2.superview!.bottom ~ 100
            
//            view1.height  == view1.superview!.height - 40  ~ 100
            view2.height  == 40 ~ 100
        }
        

//        if !isOpenAccessGranted() {
//            openAccessLabel = UILabel()
//            openAccessLabel!.text = "Please allow full access in Settings > General > Keyboard > Keyboards"
//            openAccessLabel!.numberOfLines = 0
//            openAccessLabel!.textColor = UIColor.blackColor()
//            openAccessLabel!.sizeToFit()
//            collectionViews.addSubview(openAccessLabel!)
//
//            layout(openAccessLabel!, collectionViews) { view1, view2 in
//                view1.top == view2.top
//                view1.bottom == view2.bottom
//                view1.left == view2.left
//                view1.right == view2.right
//            }
//            return
//        } else {
//            initializeRealm()
//        }
        
        initializeRealm()

        
    }
    
    func initializeRealm() {
        
        openAccessLabel?.removeFromSuperview()
        openAccessLabel = nil
        
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupId)!
        let realmPath = directory.path!.stringByAppendingPathComponent("default.realm")
        Realm.defaultPath = realmPath
        rootCategories = Realm().objects(RootCategory)
        
        // init collection views
        var layout1 = ZLBalancedFlowLayout()
        layout1.headerReferenceSize = CGSizeZero
        layout1.footerReferenceSize = CGSizeZero
        layout1.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout1.rowHeight = 30
        layout1.enforcesRowHeight = true
        layout1.minimumLineSpacing = 0
        layout1.minimumInteritemSpacing = 5
        
        categoriesCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout1)
        categoriesCollectionView?.backgroundColor = UIColor.whiteColor()
        categoriesCollectionView!.registerClass(EKCategoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        categoriesCollectionView?.delegate = self
        categoriesCollectionView?.dataSource = self
        
        var layout2 = ZLBalancedFlowLayout()
        layout2.headerReferenceSize = CGSizeZero
        layout2.footerReferenceSize = CGSizeZero
        layout2.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout2.rowHeight = 25
        layout2.enforcesRowHeight = true
        layout2.minimumLineSpacing = 0
        layout2.minimumInteritemSpacing = 5
        
        emoticonsCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout2)
        emoticonsCollectionView?.backgroundColor = UIColor.whiteColor()
        emoticonsCollectionView!.registerClass(EKEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        emoticonsCollectionView?.delegate = self
        emoticonsCollectionView?.dataSource = self
        
        collectionViews.addSubview(emoticonsCollectionView!)
        collectionViews.addSubview(categoriesCollectionView!)
        
        emoticonsCollectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        categoriesCollectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        layout(categoriesCollectionView!, collectionViews) { view1, view2 in
            view1.top == view2.top
            view1.bottom == view2.bottom
            view1.left == view2.left
            view1.right == view2.right
        }
        
        layout(emoticonsCollectionView!, collectionViews) { view1, view2 in
            view1.top == view2.top
            view1.bottom == view2.bottom
            view1.left == view2.left
            view1.right == view2.right
        }
        
        // Set realm notification block
        notificationToken = Realm().addNotificationBlock { [unowned self] note, realm in
            self.categoriesCollectionView?.reloadData()
            self.emoticonsCollectionView?.reloadData()
        }
        
        categoriesCollectionView?.reloadData()
        emoticonsCollectionView?.reloadData()

        view.layoutSubviews()
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == categoriesCollectionView! {
            return rootCategories!.count
        } else if collectionView == emoticonsCollectionView! {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView! {
            return rootCategories![section].values.count
        } else if collectionView == emoticonsCollectionView! {
            if let currentCategory = currentCategory {
                return currentCategory.values.count
            }
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView! {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKCategoryCollectionViewCell
            
            let category = categoryForIndexPath(indexPath)
            cell.title = category.name
            
            return cell
        } else if collectionView == emoticonsCollectionView! {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EKEmoticonCollectionViewCell
            
            // Configure the cell
            cell.title = emoticonForIndexPath(indexPath).value
            return cell
        }
        return UICollectionViewCell()
    }
    
    func emoticonForIndexPath(indexPath: NSIndexPath) -> Emoticon {
        return currentCategory!.values[indexPath.item]
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        if collectionView == categoriesCollectionView! {
            currentCategory = categoryForIndexPath(indexPath)
            categoriesCollectionView?.hidden = true
        } else {
            let emoticon = emoticonForIndexPath(indexPath)
            insertText(emoticon.value)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == categoriesCollectionView! {
            return sizeForString(categoryForIndexPath(indexPath).name)
        } else {
            return sizeForString(emoticonForIndexPath(indexPath).value)
        }

    }

    // MARK: - ()
    func categoryForIndexPath(indexPath: NSIndexPath) -> Category {
        return rootCategories![indexPath.section].values[indexPath.item]
    }

    var sizeCache = [String: CGSize]()
    func sizeForString(text: String) -> CGSize {
        if let cached = sizeCache[text] {
            return cached
        }
        var size = (text as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        size = CGSize(width: min(320, size.width), height: size.height)
        sizeCache[text] = size
        return size
    }
    
//    func isOpenAccessGranted() -> Bool {
//        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
//    }
    
    func isOpenAccessGranted() -> Bool {
        let fm = NSFileManager.defaultManager()
        let containerPath = fm.containerURLForSecurityApplicationGroupIdentifier(appGroupId)?.path!.stringByAppendingPathComponent("default.realm")
        var error: NSError?
        fm.contentsOfDirectoryAtPath(containerPath!, error: &error)
        if (error != nil) {
            NSLog("Full Access: Off")
            return false
        }
        NSLog("Full Access: On");
        return true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    // MARK: Actions
    func insertText(text:String) {
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText(text)
    }
    func deleteText() {
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.deleteBackward()
    }
    func insertReturn() {
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText("\n")
    }
    func showMenu() {
        categoriesCollectionView?.hidden = false
    }


    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
    
        var textColor: UIColor
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    
}
