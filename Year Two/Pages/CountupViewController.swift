//
//  CountupViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/13/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class CountupViewController: UIViewController {
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    let startDate = Date(timeIntervalSinceReferenceDate: 481968000.0)
    //481968000 is number of seconds between 1/1/2001 0:00 and 4/10/16 4:00
    
    enum timeSetting {
        case cumulative
        case distinct  }
    
    var setting: timeSetting = .cumulative
    var updateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        updateLabels()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            self.updateLabels() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateTimer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateTimes() -> (Years: Int, Months: Int, Weeks: Int, Days: Int, Hours: Int, Minutes: Int, Seconds: Int) {
        var yearNum, monthNum, weekNum, dayNum, hourNum, minuteNum, secondNum: Int
        let calendar = Calendar(identifier: .gregorian)

        
        if self.setting == .cumulative {
            let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: startDate, to: Date())
            yearNum = components.year ?? 0
            monthNum = components.month ?? 0
            weekNum = components.weekOfYear ?? 0
            dayNum = components.day ?? 0
            hourNum = components.hour ?? 0
            minuteNum = components.minute ?? 0
            secondNum = components.second ?? 0
        } else {
            yearNum = calendar.dateComponents([.year], from: startDate, to: Date()).year ?? 0
            monthNum = calendar.dateComponents([.month], from: startDate, to: Date()).month ?? 0
            weekNum = calendar.dateComponents([.weekOfYear], from: startDate, to: Date()).weekOfYear ?? 0
            dayNum = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
            hourNum = calendar.dateComponents([.hour], from: startDate, to: Date()).hour ?? 0
            minuteNum = calendar.dateComponents([.minute], from: startDate, to: Date()).minute ?? 0
            secondNum = calendar.dateComponents([.second], from: startDate, to: Date()).second ?? 0
        }
        
        return (yearNum, monthNum, weekNum, dayNum, hourNum, minuteNum, secondNum)
        
    }
    
    func updateLabels() {
        
        //setting the labels
        let timeTuple = calculateTimes()
        let tupleArray: [NSNumber] = [NSNumber(value: timeTuple.Years), NSNumber(value: timeTuple.Months), NSNumber(value: timeTuple.Weeks), NSNumber(value: timeTuple.Days), NSNumber(value: timeTuple.Hours), NSNumber(value: timeTuple.Minutes), NSNumber(value: timeTuple.Seconds)]
        
        //lets get to formatting
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        var labelText: [String] = [formatter.string(from: tupleArray[0])! + " year", formatter.string(from: tupleArray[1])! + " month", formatter.string(from: tupleArray[2])! + " week", formatter.string(from: tupleArray[3])! + " day", formatter.string(from: tupleArray[4])! + " hour", formatter.string(from: tupleArray[5])! + " minute", formatter.string(from: tupleArray[6])! + " second"]
        
        
        //making sure the words are in the correct form
        if timeTuple.Years != 1 { labelText[0] += "s" }
        if timeTuple.Months != 1 { labelText[1] += "s" }
        if timeTuple.Weeks != 1 { labelText[2] += "s" }
        if timeTuple.Days != 1 { labelText[3] += "s" }
        if timeTuple.Hours != 1 { labelText[4] += "s" }
        if timeTuple.Minutes != 1 { labelText[5] += "s" }
        if timeTuple.Seconds != 1 { labelText[6] += "s" }

        yearLabel.text = labelText[0]
        monthLabel.text = labelText[1]
        weekLabel.text = labelText[2]
        dayLabel.text = labelText[3]
        hourLabel.text = labelText[4]
        minuteLabel.text = labelText[5]
        secondLabel.text = labelText[6]
    }
    
    @IBAction func didChangeTimes(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.setting = .cumulative
        } else {
            self.setting = .distinct
        }
        
        updateLabels()
    }
    
}
