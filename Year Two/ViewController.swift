//
//  ViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/12/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var menuTable: UITableView!
    
    let data: [String] = ["Messaging System", "Keeping Track of Time", "Visit Countdown", "Are We There Yet?", "Bucket List", "World Map"]
    let pictures: [String] = ["Message", "Heart", "Stopwatch", "Check", "List", "Globe"]
    let segues: [String] = ["showMessaging", "showCountup", "showCountdown", "showChecklist", "showBucketList", "showWorldMap"]
    let newGreen: UIColor = UIColor(red: 38.0/255.0, green: 214.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    var colors: [UIColor] = [.red, .black, .purple, .blue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.backBarButtonItem?.title = "Back"
        menuTable.backgroundView = UIImageView(image: UIImage(named: "placeholder")!)
        
        colors.insert(newGreen, at: 2)
        colors.insert(newGreen, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "protoCell")!
        cell.textLabel?.text = data[indexPath.row]
        cell.imageView?.image = UIImage(named: pictures[indexPath.row])?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = colors[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: segues[indexPath.row], sender: nil)
    }
    
}

