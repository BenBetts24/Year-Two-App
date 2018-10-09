//
//  CountdownViewViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/21/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class CountdownViewViewController: UIViewController {
    @IBOutlet var visitTitle: UILabel!
    @IBOutlet var arrivalDate: UILabel!
    @IBOutlet var arrivalTime: UILabel!
    @IBOutlet var departureDate: UILabel!
    @IBOutlet var departureTime: UILabel!
    @IBOutlet var travelInfo: UILabel!
    @IBOutlet var visitInfo: UITextView!
    
    var item: CountdownItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button: UIButton = UIButton(type: .custom)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(Constants.colors.textColor, for: .normal)
        button.addTarget(self, action: #selector(didPressEdit), for: .touchUpInside)
        let rightButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = rightButton
        
        let backButton = UIBarButtonItem()
        backButton.title = "Cancel"
        navigationItem.backBarButtonItem = backButton
        
        if let info = item {
            let dateFormatter = DateFormatter()
            let timeFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            timeFormatter.dateStyle = .none
            timeFormatter.timeStyle = .short
            
            if info.personTraveling == "Beano" { self.visitTitle.text = "Beano visits Vivi!" } else { self.visitTitle.text = "Vivi visits Beano!" }
            self.arrivalDate.text = dateFormatter.string(from: info.arrivalDate)
            self.arrivalTime.text = timeFormatter.string(from: info.arrivalDate)
            if let date = info.leavingDate {
                self.departureDate.text = dateFormatter.string(from: date)
                self.departureTime.text = timeFormatter.string(from: date)
            } else {
                self.departureDate.text = "N/A"
                self.departureTime.text = "N/A"
            }
            if let travel = info.travelDetails { self.travelInfo.text = travel } else { self.travelInfo.text = "N/A" }
            if let visit = info.visitDetails { self.visitInfo.text = visit } else { self.visitInfo.text = "N/A"}
        }
    }
    
    @objc func didPressEdit() {
        self.performSegue(withIdentifier: "editCountdownItem", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CountdownEditViewController
        destination.item = self.item
        destination.editMode = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
