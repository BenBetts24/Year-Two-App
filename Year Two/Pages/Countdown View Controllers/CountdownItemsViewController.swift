//
//  CountdownItemsViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/21/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class CountdownItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var countdownTable: UITableView!
    
    var visits: [CountdownItem] = []
    let titles = ["Beano visits Vivi!", "Vivi visits Beano!"]
    var selectedItem: CountdownItem?
    var pressedItem = false
    let tableQuery = Constants.refs.databaseCountdown.queryOrdered(byChild: "arrivalDate")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAdd))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = "Visits"
        self.visits.removeAll()
        self.tableQuery.observe(.childAdded) { [weak self] snapshot in
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
                
                self?.visits.append(item)
                self?.visits.sort(by: { $0.arrivalDate < $1.arrivalDate } )
                self?.countdownTable.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.visits.removeAll()
        self.tableQuery.removeAllObservers()
    }
    
    @objc func didPressAdd() {
        self.performSegue(withIdentifier: "addCountdownItem", sender: nil)
        self.navigationItem.backBarButtonItem?.title = "Cancel"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedItem = visits[indexPath.row]
        self.pressedItem = true
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "viewCountdownItem", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.pressedItem {
            let destination = segue.destination as! CountdownViewViewController
            destination.item = self.selectedItem
        }
        self.pressedItem = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell")!
        
        if visits[indexPath.row].personTraveling == "Beano" {
            cell.textLabel?.text = titles[0]
        } else {
            cell.textLabel?.text = titles[1]
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        cell.detailTextLabel?.text = formatter.string(from: visits[indexPath.row].arrivalDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            let deleteRef = Constants.refs.databaseCountdown.child(self.visits[indexPath.row].firebaseKey)
            deleteRef.removeValue()
            self.visits.remove(at: indexPath.row)
            tableView.reloadData()
        })
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
