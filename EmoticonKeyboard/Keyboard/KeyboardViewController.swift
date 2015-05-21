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
import TTTAttributedLabel
import ReactiveUI

let reuseIdentifier = "Cell", headerIdentifier = "header", footerIdentifier = "footer"
let appGroupId = "group.com.axcel.EmoticonKeyboard"

class KeyboardViewController: UIInputViewController {

    var collectionViews = UIView()
    var controlViews = UIView()

    var nextKeyboardButton: UIButton!
    var menuButton: UIButton!
    var recentButton: UIButton!
    var spaceButton: UIButton!
    var enterButton: UIButton!
    var deleteButton: UIButton!
    
    var openAccessLabel = UILabel()

    var categoriesCollectionView: UICollectionView!
    var emoticonsCollectionView: UICollectionView!
    
    var categoriesCollectionViewDataSourceDelegate = EKCategoriesCollectionViewDataSourceDelegate()
    var emoticonsCollectionViewDataSourceDelegate = EKEmoticonsCollectionViewDataSourceDelegate()
    var queryEmoticonsCollectionViewDataSourceDelegate = EKQueryEmoticonsCollectionViewDataSourceDelegate()
    
    var primaryCategories : Results<PrimaryCategory>! {
        didSet {
            categoriesCollectionViewDataSourceDelegate.primaryCategories = primaryCategories
            categoriesCollectionView?.reloadData()
        }
    }
    var currentCategory: Category? {
        didSet {
            emoticonsCollectionViewDataSourceDelegate.category = currentCategory
            emoticonsCollectionView?.delegate = emoticonsCollectionViewDataSourceDelegate
            emoticonsCollectionView?.dataSource = emoticonsCollectionViewDataSourceDelegate
            emoticonsCollectionView?.reloadData()
            emoticonsCollectionView.setContentOffset(CGPointZero, animated: false)
        }
    }
    
    var notificationToken: NotificationToken?
    
    // MARK: Input View Constraints
    let portraitHeight = 300, landscapeHeight = 200
    var heightConstraint: NSLayoutConstraint?
    var widthConstraint: NSLayoutConstraint?
    var isProtrait = true
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
        updateInputViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        view.setNeedsUpdateConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isOpenAccessGranted() {
            openAccessLabel.hidden = true
        } else {
            openAccessLabel.hidden = false
        }
        
        isProtrait = UIScreen.mainScreen().bounds.width < UIScreen.mainScreen().bounds.height
        var height = isProtrait ? portraitHeight : landscapeHeight
        heightConstraint = NSLayoutConstraint(item: view!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: CGFloat(height))
        heightConstraint!.priority = 900
        view.addConstraint(heightConstraint!)
        
        widthConstraint = NSLayoutConstraint(item: view!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: UIScreen.mainScreen().bounds.width)
        widthConstraint!.priority = 950
        view.addConstraint(widthConstraint!)
    }
    
    func updateInputViewConstraints() {
        if self.view.frame.size.width == 0 || self.view.frame.size.height == 0 || isProtrait == (UIScreen.mainScreen().bounds.width < UIScreen.mainScreen().bounds.height) {
            return
        }
        if var heightConstraint = heightConstraint, widthConstraint = widthConstraint {
            view!.removeConstraint(heightConstraint)
            isProtrait = UIScreen.mainScreen().bounds.width < UIScreen.mainScreen().bounds.height
            var height = isProtrait ? portraitHeight : landscapeHeight
            self.heightConstraint!.constant = CGFloat(height)
            view!.addConstraint(heightConstraint)
            
            view!.removeConstraint(widthConstraint)
            self.widthConstraint!.constant = UIScreen.mainScreen().bounds.width
            view!.addConstraint(widthConstraint)
        }
    }
    
    // MARK: Life Cycle
    deinit {
        if let notificationToken = notificationToken {
            Realm().removeNotification(notificationToken)
        }
    }
    
    var deleteTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Top level view containers
        for subview in [collectionViews, controlViews, openAccessLabel] {
            subview.setTranslatesAutoresizingMaskIntoConstraints(false)
            view.addSubview(subview)
        }
        view.backgroundColor = UIColor.whiteColor()
        
        openAccessLabel.text = "Please allow full access in Settings > General > Keyboard > Keyboards"
        openAccessLabel.numberOfLines = 0
        openAccessLabel.textColor = UIColor.blackColor()
        openAccessLabel.sizeToFit()
        openAccessLabel.hidden = true
        view.addSubview(openAccessLabel)
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        layout(collectionViews, controlViews) { view1, view2 in
            view1.left == view1.superview!.left
            view2.left == view1.left
            view1.right == view1.superview!.right
            view2.right == view1.right
            
            view1.top == view1.superview!.top
            view1.bottom  == view2.top
            view2.bottom == view2.superview!.bottom ~ 100
            view2.height  == 40 ~ 200
        }
        
        layout(openAccessLabel, collectionViews) { view1, view2 in
            view1.centerX == view2.centerX
            view1.centerY == view2.centerY
            view1.left == view1.superview!.left
            view1.right == view1.superview!.right
        }
        
        // Buttons: next menu space return delete
        nextKeyboardButton = UIButton.buttonWithType(.System) as! UIButton
        nextKeyboardButton.setTitle(NSLocalizedString("🌐", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        
        menuButton = UIButton.buttonWithType(.System) as! UIButton
        menuButton.setTitle(NSLocalizedString("🚀", comment: "Title for 'Menu' button"), forState: .Normal)
        menuButton.addTarget(self, action: "showMenu", forControlEvents: .TouchUpInside)
        
        recentButton = UIButton.buttonWithType(.System) as! UIButton
        recentButton.setTitle(NSLocalizedString("🕘", comment: "Title for 'Recent' button"), forState: .Normal)
        recentButton.addTarget(self, action: "showRecent", forControlEvents: .TouchUpInside)
        
        spaceButton = UIButton.buttonWithType(.System) as! UIButton
        spaceButton.setTitle(NSLocalizedString("Space", comment: "Title for 'Space' button"), forState: .Normal)
        spaceButton.addTarget(self, action: "insertSpace", forControlEvents: .TouchUpInside)

        enterButton = UIButton.buttonWithType(.System) as! UIButton
        enterButton.setTitle(NSLocalizedString("⏎", comment: "Title for 'Enter' button"), forState: .Normal)
        enterButton.addTarget(self, action: "insertReturn", forControlEvents: .TouchUpInside)
        
        deleteButton = UIButton.buttonWithType(.System) as! UIButton
        deleteButton.setTitle(NSLocalizedString("⌫", comment: "Title for 'Delete' button"), forState: .Normal)
        deleteButton.addAction({button in
            self.deleteText()
            self.deleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, action: {timer in
                self.deleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, action: {timer in
                    self.deleteText()
                    }, repeats: true)
                }, repeats: false)
            }, forControlEvents: .TouchDown)
        deleteButton.addAction({button in
            self.deleteTimer?.invalidate()
            }, forControlEvents: .TouchUpInside | .TouchUpOutside | .TouchCancel)
        
        for button in [nextKeyboardButton, menuButton, recentButton, spaceButton, enterButton, deleteButton] {
            button.sizeToFit()
            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 18)
            controlViews.addSubview(button)
        }
        
        // layout
        layout(nextKeyboardButton, controlViews) { view1, view2 in
            view1.left == view2.left+10
            view1.centerY == view2.centerY
        }
        
        layout(menuButton, nextKeyboardButton) { view1, view2 in
            view1.centerX == view2.centerX + 35
            view1.centerY == view2.centerY
        }

        layout(recentButton, menuButton) { view1, view2 in
            view1.centerX == view2.centerX + 35
            view1.centerY == view2.centerY
        }
        
        layout(spaceButton, controlViews) { view1, view2 in
            view1.centerX == view2.centerX
            view1.centerY == view2.centerY
        }

        layout(enterButton, deleteButton) { view1, view2 in
            view1.centerX == view2.centerX - 40
            view1.centerY == view2.centerY
        }
        
        layout(deleteButton, controlViews) { view1, view2 in
            view1.right == view2.right-10
            view1.centerY == view2.centerY
        }

        if isOpenAccessGranted() {
            initializeRealm()
        }
    }
    
    func initializeRealm() {
        
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupId)!
        let realmPath = directory.path!.stringByAppendingPathComponent("default.realm")
        if Realm.defaultPath != realmPath {
            Realm.defaultPath = realmPath
            migrate()
        }

        primaryCategories = Realm().objects(PrimaryCategory)
        
        // init collection views
        categoriesCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ZLBalancedFlowLayout.layoutForMainKeyboard())
        categoriesCollectionView?.backgroundColor = UIColor.whiteColor()
        categoriesCollectionView?.registerClass(EKCategoryCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        categoriesCollectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        categoriesCollectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        categoriesCollectionView?.delegate = categoriesCollectionViewDataSourceDelegate
        categoriesCollectionView?.dataSource = categoriesCollectionViewDataSourceDelegate
        categoriesCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)

        emoticonsCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: ZLBalancedFlowLayout.layoutForEmoticons())
        emoticonsCollectionView?.backgroundColor = UIColor.whiteColor()
        emoticonsCollectionView?.registerClass(EKEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        emoticonsCollectionView?.registerClass(EKSectionHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        emoticonsCollectionView?.registerClass(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerIdentifier)
        emoticonsCollectionView?.delegate = emoticonsCollectionViewDataSourceDelegate
        emoticonsCollectionView?.dataSource = emoticonsCollectionViewDataSourceDelegate
        emoticonsCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)

        collectionViews.addSubview(emoticonsCollectionView!)
        collectionViews.addSubview(categoriesCollectionView!)
        
        // callbacks
        categoriesCollectionViewDataSourceDelegate.sectionHeaderFontSize = "3em"
        categoriesCollectionViewDataSourceDelegate.didSelectCategory = {category in
            self.currentCategory = category
            self.categoriesCollectionView?.hidden = true
        }
        emoticonsCollectionViewDataSourceDelegate.didSelectEmoticon = {emoticon in
            self.insertText(emoticon.value)
        }
        queryEmoticonsCollectionViewDataSourceDelegate.didSelectEmoticon = {emoticon in
            self.insertText(emoticon.value)
        }
        
        // layout
        for collectionView in [categoriesCollectionView!, emoticonsCollectionView!] {
            layout(collectionView, collectionViews) { view1, view2 in
                view1.top == view2.top
                view1.bottom == view2.bottom
                view1.left == view2.left
                view1.right == view2.right
            }
            collectionView.reloadData()
        }
        
        // Set realm notification block
        notificationToken = Realm().addNotificationBlock { [unowned self] note, realm in
            self.categoriesCollectionView?.reloadData()
            if let currentCategory = self.currentCategory {
                self.emoticonsCollectionView?.reloadData()
            }
        }
        
    }
    
    func isOpenAccessGranted() -> Bool {
        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
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
    func insertSpace() {
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText(" ")
    }
    func insertReturn() {
        var proxy = self.textDocumentProxy as! UITextDocumentProxy
        proxy.insertText("\n")
    }
    func showMenu() {
        categoriesCollectionView?.hidden = false
    }
    func showRecent() {
        categoriesCollectionView?.hidden = true
        currentCategory = nil
        
        queryEmoticonsCollectionViewDataSourceDelegate.sectionHeaderTitle = "Recent"
        queryEmoticonsCollectionViewDataSourceDelegate.emoticons = Realm.recentlyUsedEmoticons()
        emoticonsCollectionView?.delegate = queryEmoticonsCollectionViewDataSourceDelegate
        emoticonsCollectionView?.dataSource = queryEmoticonsCollectionViewDataSourceDelegate
        emoticonsCollectionView?.reloadData()
    }

    // MARK: UIInputController
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
