//
//  BucketListViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/13/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class BucketListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var bucketTable: UITableView!
    @IBOutlet var segmentedOrder: UISegmentedControl!
    
    let titles: [String] = ["Incomplete", "Complete"]
    var incompleteItems: [BucketListItem] = []
    var completeItems: [BucketListItemComplete] = []
    var selectedPath: IndexPath = IndexPath(row: -1, section: -1)
    var sortBy = 0
    
    var dateIncompleteItems: [BucketListItem]?
    var dateCompleteItems: [BucketListItemComplete]?
    var alphIncompleteItems: [BucketListItem]?
    var alphCompleteItems: [BucketListItemComplete]?
    
    let incompleteQuery = Constants.refs.databaseBucketIncomplete.queryLimited(toLast: 50)
    let completeQuery = Constants.refs.databaseBucketComplete.queryLimited(toLast: 50)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        self.bucketTable.backgroundView = UIImageView(image: UIImage(named: "placeholder")!)
        self.segmentedOrder.layer.cornerRadius = 5.0

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAdd))
        self.navigationItem.backBarButtonItem?.title = "Cancel"
    }
    
    func startQuery() {
        //querying to fill the arrays
        //starting with incomplete:
        _ = self.incompleteQuery.observe(.childAdded, with: { [weak self] snapshot in
            if  let data    = snapshot.value as? [String: String],
                let title   = data["title"] {
                
                let newItem = BucketListItem(title: title, dateAdded: Date(timeIntervalSinceReferenceDate: Double(data["date"]!)!), added: data["addedBy"]!, key: snapshot.key)
                
                if data["location"] != "" {
                    newItem.location = data["location"]
                }
                if data["description"] != "" {
                    newItem.description = data["description"]
                }
                
                self?.incompleteItems.append(newItem)
                
                if self?.sortBy == 0 {
                    self?.sortChronologically()
                } else {
                    self?.sortAlphabetically()
                }

                self?.bucketTable.reloadData()
            }
        })
        
        //now to the complete query
        _ = self.completeQuery.observe(.childAdded, with: { [weak self] snapshot in
            if  let data    = snapshot.value as? [String: String],
                let title   = data["title"] {
                
                let newItem = BucketListItemComplete(title: title, dateAdded: Date(timeIntervalSinceReferenceDate: Double(data["date"]!)!), added: data["addedBy"]!, completeDate: Date(timeIntervalSinceReferenceDate: Double(data["completeDate"]!)!), key: snapshot.key)
                
                if data["location"] != "" {
                    newItem.location = data["location"]
                }
                if data["description"] != "" {
                    newItem.description = data["description"]
                }
                if data["completeDescription"] != "" {
                    newItem.completeDescription = data["completeDescription"]
                }
                
                self?.completeItems.append(newItem)
                
                if self?.sortBy == 0 {
                    self?.sortChronologically()
                } else {
                    self?.sortAlphabetically()
                }
                
                self?.bucketTable.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //getting item info
        self.incompleteItems = []
        self.completeItems = []
        selectedPath.section = -1
        startQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.incompleteQuery.removeAllObservers()
        self.completeQuery.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPressAdd() {
        self.performSegue(withIdentifier: "addBucketItem", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem()
        if selectedPath.section == -1 {
            backButton.title = "Cancel"
        } else if selectedPath.section == 0 {
            backButton.title = "Back"
            let destination = segue.destination as! BucketViewViewController
            destination.incompleteItem = self.incompleteItems[selectedPath.row]
        } else if selectedPath.section == 1 {
            backButton.title = "Back"
            let destination = segue.destination as! BucketViewViewController
            destination.completeItem = self.completeItems[selectedPath.row]
        }
    
        navigationItem.backBarButtonItem = backButton
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return incompleteItems.count
        } else {
            return completeItems.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titles[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sample")
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = incompleteItems[indexPath.row].title
            cell?.detailTextLabel?.text = "Added by \(incompleteItems[indexPath.row].added) on \(formatter.string(from: incompleteItems[indexPath.row].dateAdded))"
        } else {
            cell?.textLabel?.text = completeItems[indexPath.row].title
            cell?.detailTextLabel?.text = "Completed \(formatter.string(from: completeItems[indexPath.row].completeDate))"
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "viewBucketItem", sender: nil)
    }
    
    @IBAction func didChangeOrder(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.sortBy = 0
            self.sortChronologically()
        } else {
            self.sortBy = 1
            self.sortAlphabetically()
        }
        
        self.bucketTable.reloadData()
    }
    
    func sortChronologically() {
        dateIncompleteItems = incompleteItems.sorted(by: { $0.dateAdded < $1.dateAdded })
        dateCompleteItems = completeItems.sorted(by: { $0.completeDate < $1.completeDate })
        incompleteItems = dateIncompleteItems!
        completeItems = dateCompleteItems!
    }
    
    func sortAlphabetically() {
        alphIncompleteItems = incompleteItems.sorted(by: { $0.title < $1.title })
        alphCompleteItems = completeItems.sorted(by: { $0.title < $1.title })
        incompleteItems = alphIncompleteItems!
        completeItems = alphCompleteItems!
    }

}
