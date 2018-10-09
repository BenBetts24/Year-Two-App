//
//  CountdownItem.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/21/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import Foundation

class CountdownItem {
    let firebaseKey: String
    var arrivalDate: Date
    let personTraveling: String
    var leavingDate: Date?
    var travelDetails: String?
    var visitDetails: String?
    
    init(key: String, arrival: Date, person: String) {
        self.firebaseKey = key
        self.arrivalDate = arrival
        self.personTraveling = person
    }
}
