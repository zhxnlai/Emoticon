//
//  RealmModels.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import RealmSwift

// Emoticon model
class Emoticon: Object {
    dynamic var value = ""
    dynamic var owner: Category? // Can be optional
}

// Category model
class Category: Object {
    dynamic var name = ""
    let values = List<Emoticon>()
}

// RootCategory model
class RootCategory: Object {
    dynamic var name = ""
    let values = List<Category>()
}
