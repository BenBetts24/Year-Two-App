//
//  BucketListItemComplete.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/15/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import Foundation

class BucketListItemComplete: BucketListItem {
    var completeDescription: String?
    var completeDate: Date
    var picture: UIImage?
    
    init(title: String, dateAdded: Date, added: String, completeDate: Date, key: String) {
        self.completeDate = completeDate
        super.init(title: title, dateAdded: dateAdded, added: added, key: key)
    }
}
