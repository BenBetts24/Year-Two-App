//
//  ChecklistViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/13/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class ChecklistViewController: UIViewController {
    @IBOutlet var semesterCompleteLabel: UILabel!
    @IBOutlet var semesterCompleteTextLabel: UITextView!
    @IBOutlet var longDistanceCompleteLabel: UILabel!
    @IBOutlet var longDistanceDaysLabel: UILabel!
    @IBOutlet var currentSemesterLabel: UILabel!
    @IBOutlet var semesterPercentLabel: UILabel!
    @IBOutlet var daysLeftLabel: UILabel!
    @IBOutlet var daysLeftTextLabel: UILabel!
    @IBOutlet var semesterProgressBar: UIProgressView!
    @IBOutlet var startSemesterButton: UIButton!
    
    let query = Constants.refs.databaseSemester.queryOrdered(byChild: "semesterNumber")
    var refreshTimer: Timer?
    
    var semesters: [SemesterItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.backBarButtonItem?.title = "Cancel"
        self.startSemesterButton.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.semesters.removeAll()
        self.query.observe(.childAdded) { [weak self] snapshot in
            if let data = snapshot.value as? [String: String] {
                let newItem = SemesterItem(number: data["semesterNumber"]!, start: data["startDate"]!, end: data["endDate"]!)
                self?.semesters.append(newItem)
                self?.semesters.sort(by: {$0.semesterNumber < $1.semesterNumber})
                self?.updateLabels()
                print(newItem.semesterNumber)
            }
        }
        
        self.refreshTimer = Timer(timeInterval: 1.0, repeats: true, block: { (Timer) in
            if self.daysLeftTextLabel.text != "day(s) left!" {
                self.updateLabels()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.query.removeAllObservers()
        self.refreshTimer?.invalidate()
    }
    
    func updateLabels() {
        let semesterCurrent = self.semesters[self.semesters.count - 1]
        let semesterNumber = semesterCurrent.semesterNumber
        let calendar = Calendar(identifier: .gregorian)
        
        self.semesterCompleteLabel.text = "\(semesterCurrent.semesterNumber - 1)"
        self.longDistanceCompleteLabel.text = "\(((Double(semesterNumber) - 1.0)/8.0) * 100)%"
        self.semesterCompleteLabel.font = self.longDistanceCompleteLabel.font
        
        if self.semesterCompleteLabel.text == "1" {
            self.semesterCompleteTextLabel.text = "semester complete!"
        } else {
            self.semesterCompleteTextLabel.text = "semesters complete!"
        }
        
        let days = calendar.dateComponents([.day], from: semesters[0].startDate, to: Date())
        self.longDistanceDaysLabel.text = "\(days.day ?? 0)"
        
        self.currentSemesterLabel.text = "Current Semester: \(semesterNumber)"
        
        let semesterDays = calendar.dateComponents([.day], from: semesterCurrent.startDate, to: semesterCurrent.endDate)
        let currentDays = calendar.dateComponents([.day], from: semesterCurrent.startDate, to: Date())
        var percentComplete = Int((Double(currentDays.day ?? 0)/Double(semesterDays.day!)) * 100)
        var daysLeft = semesterDays.day! - (currentDays.day ?? 0)
        
        if percentComplete >= 100 { percentComplete = 100 } else if percentComplete <= 0 { percentComplete = 0 }
        if daysLeft <= 0 { daysLeft = 0 }
        
        self.semesterPercentLabel.text = "\(percentComplete)%"
        self.daysLeftLabel.text = "\(daysLeft)"
        if self.daysLeftLabel.text == "1" {
            self.daysLeftTextLabel.text = "day left!"
        } else {
            self.daysLeftTextLabel.text = "days left!"
        }
        self.semesterProgressBar.progress = Float(percentComplete)
    }

    @IBAction func didStartSemester(_ sender: Any) {
        self.performSegue(withIdentifier: "startNextSemester", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ChecklistAddViewController
        if !self.semesters.isEmpty {
            destination.newSemesterNum = semesters[semesters.count - 1].semesterNumber + 1
        } else {
            destination.newSemesterNum = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
