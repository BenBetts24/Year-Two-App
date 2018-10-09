//
//  BucketListItem.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/15/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import Foundation

class BucketListItem {
    var title: String
    var description: String?
    var location: String?
    var added: String
    let dateAdded: Date
    let firebaseKey: String
    
    
    init(title: String, dateAdded: Date, added: String, key: String) {
        self.title = title
        self.dateAdded = dateAdded
        self.added = added
        self.firebaseKey = key
    }
}
