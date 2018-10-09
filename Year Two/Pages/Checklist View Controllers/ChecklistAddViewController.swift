//
//  ChecklistAddViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/24/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class ChecklistAddViewController: UIViewController {
    @IBOutlet var startDatePicker: UIDatePicker!
    @IBOutlet var endDatePicker: UIDatePicker!
    
    var newSemesterNum: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Semester \(self.newSemesterNum!)"
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSave))
        self.navigationItem.rightBarButtonItem = saveButton
    }

    @objc func didPressSave() {
        let databaseRef = Constants.refs.databaseSemester.child("semester\(self.newSemesterNum!)")
        var item = ["semesterNumber": String(self.newSemesterNum!)]
        item["startDate"] = String(self.startDatePicker.date.timeIntervalSinceReferenceDate)
        item["endDate"] = String(self.endDatePicker.date.timeIntervalSinceReferenceDate)
        databaseRef.setValue(item)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
