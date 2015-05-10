//
//  RealmModels.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import RealmSwift

let schemaVersion = UInt(1)
let migrate = { () in
    setSchemaVersion(schemaVersion, Realm.defaultPath, { migration, oldSchemaVersion in
        if oldSchemaVersion < schemaVersion {
            //                migration.enumerate(Category.className()) { oldObject, newObject in
            //                }
        }
    })
}

// PrimaryCategory model
class PrimaryCategory: Object {
    dynamic var name = ""
    let values = List<SecondaryCategory>()
}

// SecondaryCategory model
class SecondaryCategory: Object {
    dynamic var name = ""
    dynamic var parent: PrimaryCategory?
    let values = List<Category>()
}

// Category model
class Category: Object {
    dynamic var name = ""
    dynamic var parent: SecondaryCategory?
    let values = List<Emoticon>()
}

// Emoticon model
class Emoticon: Object {
    dynamic var value = ""
    dynamic var owner: Category? // Can be optional
    dynamic var useCount = 0
    dynamic var lastUsed = NSDate()
}
