//
//  CountdownEditViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/21/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class CountdownEditViewController: UIViewController {
    @IBOutlet var personTraveling: UISegmentedControl!
    @IBOutlet var travelInfoField: UITextField!
    @IBOutlet var visitInfoView: UITextView!
    @IBOutlet var arrivalDate: UIDatePicker!
    @IBOutlet var departureDate: UIDatePicker!
    
    var item: CountdownItem?
    var editMode: Bool = false
    var saveDeparture: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSave))
        self.visitInfoView.layer.borderWidth = 0.6
        self.visitInfoView.layer.borderColor = Constants.colors.borderColor.cgColor
        self.visitInfoView.layer.cornerRadius = 5.0
        self.departureDate.isHidden = true
        self.departureDate.isUserInteractionEnabled = false
        
        if self.editMode {
            self.title = "Edit Visit"
        } else {
            self.title = "Add Visit"
        }
        
        if self.editMode {
            if self.item?.personTraveling == "Beano" { self.personTraveling.selectedSegmentIndex = 0 } else { self.personTraveling.selectedSegmentIndex = 1 }
            self.arrivalDate.date = (self.item?.arrivalDate)!
            if let travel = self.item?.travelDetails { self.travelInfoField.text = travel }
            if let visit = self.item?.visitDetails { self.visitInfoView.text = visit}
            if let date = self.item?.leavingDate { self.departureDate.date = date }
        }
    }
    
    @objc func didPressSave() {
        createSaveAlert()
    }
    
    func save() {
        var personTravelingText: String
        if self.personTraveling.selectedSegmentIndex == 0 {personTravelingText = "Beano"} else {personTravelingText = "Vivi"}
        var databaseRef = Constants.refs.databaseCountdown.childByAutoId()
        if self.editMode { databaseRef = Constants.refs.databaseCountdown.child((self.item?.firebaseKey)!)}
        var databaseItem = ["personTraveling": personTravelingText]
        databaseItem["arrivalDate"] = String(self.arrivalDate.date.timeIntervalSinceReferenceDate)
        if self.saveDeparture && self.arrivalDate.date < self.departureDate.date {
            databaseItem["leavingDate"] = String(self.departureDate.date.timeIntervalSinceReferenceDate)
        } else { databaseItem["leavingDate"] = ""}
        if let travel = self.travelInfoField.text { databaseItem["travelDetails"] = travel } else { databaseItem["travelDetails"] = ""}
        if let visit = self.visitInfoView.text { databaseItem["visitDetails"] = visit } else {databaseItem["visitDetails"] = ""}
        
        databaseRef.setValue(databaseItem)
        
        if !self.editMode {
            self.navigationController?.popViewController(animated: true)
        } else {
            var viewControllers = navigationController?.viewControllers
            viewControllers?.removeLast(2)
            navigationController?.setViewControllers(viewControllers!, animated: true)
        }
    }
    
    func createSaveAlert() {
        let saveAlert = UIAlertController(title: "Do you want to save both dates, or just the arrival date?", message: nil, preferredStyle: .alert)
        let bothAction = UIAlertAction(title: "Arrival and Departure", style: .default) { (_:UIAlertAction) in
            self.saveDeparture = true
            self.save()
        }
        let singleAction = UIAlertAction(title: "Just Arrival", style: .default) { (_:UIAlertAction) in
            self.saveDeparture = false
            self.save()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_:UIAlertAction) in
            return
        }
        
        saveAlert.addAction(bothAction)
        saveAlert.addAction(singleAction)
        saveAlert.addAction(cancelAction)
        self.present(saveAlert, animated: true)
    }
    
    @IBAction func dateSelectionChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.arrivalDate.isHidden = false
            self.arrivalDate.isUserInteractionEnabled = true
            self.departureDate.isHidden = true
            self.departureDate.isUserInteractionEnabled = false
        } else {
            self.arrivalDate.isHidden = true
            self.arrivalDate.isUserInteractionEnabled = false
            self.departureDate.isHidden = false
            self.departureDate.isUserInteractionEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
