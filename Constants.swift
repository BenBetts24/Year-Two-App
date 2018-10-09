//
//  Constants.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/15/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import Foundation
import Firebase

struct Constants {
    struct refs {
        //database references
        static let databaseRoot = Database.database().reference()
        
        static let databaseChats = databaseRoot.child("chats")
        
        static let databaseCountdown = databaseRoot.child("countdown")
        
        static let databaseSemester = databaseRoot.child("semester")
        
        static let databaseBucket = databaseRoot.child("bucketList")
        static let databaseBucketIncomplete = databaseBucket.child("incomplete")
        static let databaseBucketComplete = databaseBucket.child("complete")
        
        //storage references
        static let storageRoot = Storage.storage().reference()
        static let storageBucketComplete = storageRoot.child("bucketComplete")
    }
    
    struct colors {
        static let borderColor: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        static let textColor: UIColor = UIColor(red: 41.0/255.0, green: 124.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    }
    
    static let userName = "Beano"
    static let messageId = "1234"
}
