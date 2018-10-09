//
//  BucketAddViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/15/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class BucketAddViewController: UIViewController {
    @IBOutlet var titleField: UITextField!
    @IBOutlet var locationField: UITextField!
    @IBOutlet var descView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSave))
        descView.layer.borderWidth = 0.6
        descView.layer.borderColor = Constants.colors.borderColor.cgColor
        descView.layer.cornerRadius = 5.0
    }
    
    @objc func didPressSave() {
        if let title = titleField.text {
            if title != "" {
                var item = ["title": title]
                if let location = locationField.text {
                    item["location"] = location
                }
                if let description = descView.text {
                    item["description"] = description
                }
                item["addedBy"] = Constants.userName
                
                let currentDate = Date()
                let dateString = String(currentDate.timeIntervalSinceReferenceDate)
                
                item["date"] = dateString
                
                let ref = Constants.refs.databaseBucketIncomplete.childByAutoId()
                ref.setValue(item)
                
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        createTitleAlert()
    }
    
    func createTitleAlert() {
        let emptyAlert: UIAlertController = UIAlertController(title: "Title Missing", message: "Please enter a title", preferredStyle: .alert)
        let okayAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default) { (_:UIAlertAction) in
            return
        }
        emptyAlert.addAction(okayAction)
        self.present(emptyAlert, animated: true) {
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
