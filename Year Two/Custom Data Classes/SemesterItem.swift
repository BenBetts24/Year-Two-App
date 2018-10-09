//
//  SemesterItem.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/24/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import Foundation

class SemesterItem {
    let semesterNumber: Int
    let startDate: Date
    let endDate: Date
    
    init(number: String, start: String, end: String) {
        self.semesterNumber = Int(number)!
        self.startDate = Date(timeIntervalSinceReferenceDate: Double(start)!)
        self.endDate = Date(timeIntervalSinceReferenceDate: Double(end)!)
    }
}
