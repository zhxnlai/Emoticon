 //
//  AppDelegate.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/6/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import ZLBalancedFlowLayout

let appGroupId = "group.com.axcel.EmoticonKeyboard"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            var viewController = EKMainCollectionViewController(collectionViewLayout: ZLBalancedFlowLayout.layoutForMain())
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
        }
        
        initRealmIfNeeded()
        
        let sharedDefaults = NSUserDefaults(suiteName: appGroupId)!
        sharedDefaults.setBool(true, forKey: "fullAccess")
        sharedDefaults.synchronize()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func initRealmIfNeeded() {
        let directory: NSURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroupId)!
        let realmPath = directory.path!.stringByAppendingPathComponent("default.realm")
        Realm.defaultPath = realmPath

        migrate()
        
        let realm = Realm()
//        realm.write {
//            realm.deleteAll()
//        }

        if realm.objects(Category).count > 0 && realm.objects(Emoticon).count > 0 {
            return
        }
        
        if let path = NSBundle.mainBundle().pathForResource("result", ofType: "json"), data = NSData(contentsOfFile: path) {
            let result = JSON(data: data)
            realm.write {
                if let primaryCategories = result["categories"].array {
                    for primaryCategory in primaryCategories {
                        var primC = PrimaryCategory()
                        primC.name = primaryCategory["name"].stringValue
                        realm.add(primC)
                        if let secondaryCategories = primaryCategory["values"].array {
                            for secondaryCategory in secondaryCategories {
                                var sndC = SecondaryCategory()
                                sndC.name = secondaryCategory["name"].stringValue
                                sndC.parent = primC
                                realm.add(sndC)
                                primC.values.append(sndC)
                                if let categories = secondaryCategory["values"].array {
                                    for category in categories {
                                        if let category = category.string {
                                            var c = Category()
                                            c.name = category
                                            c.parent = sndC
                                            realm.add(c)
                                            sndC.values.append(c)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                let emoticons = result["emoticons"]
                for (category: String, emoticonsArray: JSON) in emoticons {
                    var c = realm.objects(Category).filter("name = '\(category)'").first!
                    if let emoticonsArray = emoticonsArray.array {
                        for value in emoticonsArray {
                            if let value = value.string {
                                var e = Emoticon()
                                e.value = value
                                e.owner = c
                                realm.add(e)
                                c.values.append(e)
                            }
                        }
                    }

                }

            }
            
            println("added categories: \(realm.objects(Category).count)")
            println("added emoticons: \(realm.objects(Emoticon).count)")
        }
    }

}

