//
//  RealmModels.swift
//  EmoticonKeyboard
//
//  Created by Zhixuan Lai on 5/7/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//

import RealmSwift

// Dog model
class Dog: Object {
    dynamic var name = ""
    dynamic var owner: Person? // Can be optional
}

// Person model
class Person: Object {
    dynamic var name = ""
    dynamic var birthdate = NSDate(timeIntervalSince1970: 1)
    let dogs = List<Dog>()
}
