//
//  CountdownViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/13/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    @IBOutlet var countdownView: UIView!
    @IBOutlet var togetherView: UIView!
    
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var hourLabel: UILabel!
    @IBOutlet var minuteLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    
    enum mode {
        case cumulative
        case distinct
    }
    
    var visit: CountdownItem?
    var updateTimer: Timer?
    var labelMode: mode = .cumulative
    var together: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        
        let button: UIButton = UIButton(type: .custom)
        button.setTitle("View", for: .normal)
        button.setTitleColor(Constants.colors.textColor, for: .normal)
        button.addTarget(self, action: #selector(didPressView), for: .touchUpInside)
        let rightButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.visit = nil
        self.findItem()
        self.setView(state: 0, setLabel: false)
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if self.monthLabel.text != "__ months" {
                self.setLabels()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.updateTimer?.invalidate()
    }
    
    func findItem() {
        Constants.refs.databaseCountdown.queryOrdered(byChild: "arrivalDate").observe(.childAdded) { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                let arrivalDate = Date(timeIntervalSinceReferenceDate: Double(data["arrivalDate"]!)!)
                let item = CountdownItem(key: snapshot.key, arrival: arrivalDate, person: data["personTraveling"]!)
                if data["leavingDate"] != "" {
                    let departureDate = Date(timeIntervalSinceReferenceDate: Double(data["leavingDate"]!)!)
                    item.leavingDate = departureDate
                }
                if data["visitDetails"] != "" {
                    item.visitDetails = data["visitDetails"]
                }
                if data["travelDetails"] != "" {
                    item.travelDetails = data["travelDetails"]
                }
                
                if let visitCheck = self.visit {
                    if item.arrivalDate < visitCheck.arrivalDate { self.visit = item }
                } else {
                    self.visit = item
                }
                
                if let departure = self.visit?.leavingDate {
                    if (self.visit?.arrivalDate)! < Date() && Date() < departure {
                        self.setView(state: 1, setLabel: false)
                    } else {
                        self.setView(state: 0, setLabel: true)
                    }
                } else {
                    self.setView(state: 0, setLabel: true)
                }
                
            }
        }
    }
    
    func setView(state: Int, setLabel: Bool) {
        if state == 0 {
            self.countdownView.isHidden = false
            self.countdownView.isUserInteractionEnabled = true
            self.togetherView.isHidden = true
            self.togetherView.isUserInteractionEnabled = false
            if setLabel {self.setLabels()}
        } else {
            self.countdownView.isHidden = true
            self.countdownView.isUserInteractionEnabled = false
            self.togetherView.isHidden = false
            self.togetherView.isUserInteractionEnabled = true
        }
    }
    
    func setLabels() {
        let calendar = Calendar(identifier: .gregorian)
        var monthNum, weekNum, dayNum, hourNum, minuteNum, secondNum: Int
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if labelMode == .cumulative {
            let components = calendar.dateComponents([.month, .weekOfYear, .day, .hour, .minute, .second], from: Date(), to: (self.visit?.arrivalDate)!)
            
            monthNum = components.month ?? 0
            weekNum = components.weekOfYear ?? 0
            dayNum = components.day ?? 0
            hourNum = components.hour ?? 0
            minuteNum = components.minute ?? 0
            secondNum = components.second ?? 0
            
        } else {
            let months = calendar.dateComponents([.month], from: Date(), to: (self.visit?.arrivalDate)!)
            let weeks = calendar.dateComponents([.weekOfYear], from: Date(), to: (self.visit?.arrivalDate)!)
            let days = calendar.dateComponents([.day], from: Date(), to: (self.visit?.arrivalDate)!)
            let hours = calendar.dateComponents([.hour], from: Date(), to: (self.visit?.arrivalDate)!)
            let minutes = calendar.dateComponents([.minute], from: Date(), to: (self.visit?.arrivalDate)!)
            let seconds = calendar.dateComponents([.second], from: Date(), to: (self.visit?.arrivalDate)!)
            
            monthNum = months.month ?? 0
            weekNum = weeks.weekOfYear ?? 0
            dayNum = days.day ?? 0
            hourNum = hours.hour ?? 0
            minuteNum = minutes.minute ?? 0
            secondNum = seconds.second ?? 0
        }
        
        self.monthLabel.text = formatter.string(from: NSNumber(value: monthNum))! + " month"
        self.weekLabel.text = formatter.string(from: NSNumber(value: weekNum))! + " week"
        self.dayLabel.text = formatter.string(from: NSNumber(value: dayNum))! + " day"
        self.hourLabel.text = formatter.string(from: NSNumber(value: hourNum))! + " hour"
        self.minuteLabel.text = formatter.string(from: NSNumber(value: minuteNum))! + " minute"
        self.secondLabel.text = formatter.string(from: NSNumber(value: secondNum))! + " second"
        
        if monthNum != 1 { self.monthLabel.text?.append("s")}
        if weekNum != 1 { self.weekLabel.text?.append("s")}
        if dayNum != 1 { self.dayLabel.text?.append("s")}
        if hourNum != 1 { self.hourLabel.text?.append("s")}
        if minuteNum != 1 { self.minuteLabel.text?.append("s")}
        if secondNum != 1 { self.secondLabel.text?.append("s")}
    }
    
    @IBAction func didChangeMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.labelMode = .cumulative
        } else {
            self.labelMode = .distinct
        }
        
        self.setLabels()
    }
    
    @objc func didPressView() {
        self.performSegue(withIdentifier: "showCountdownItems", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
