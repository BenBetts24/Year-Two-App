//
//  BucketViewViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/15/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit

class BucketViewViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var detailView: UITextView!
    @IBOutlet var picture: UIImageView!
    @IBOutlet var outlineView: UIView!
    @IBOutlet var activitySpinner: UIActivityIndicatorView!
    
    var completeItem: BucketListItemComplete?
    var incompleteItem: BucketListItem?
    var completeMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button: UIButton = UIButton(type: .custom)
        button.setImage(UIImage(named: "typing"), for: .normal)
        button.addTarget(self, action: #selector(createActionSheet), for: .touchUpInside)
        let rightButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.picture.layer.borderWidth = 0.6
        self.picture.layer.borderColor = Constants.colors.borderColor.cgColor
        self.picture.layer.cornerRadius = 6.0
        self.picture.isUserInteractionEnabled = false
        self.picture.isHidden = true
        self.activitySpinner.isHidden = true

        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        detailView.isScrollEnabled = false
        detailView.translatesAutoresizingMaskIntoConstraints = true
        
        if let complete = completeItem {
            self.completeMode = true
            titleLabel.text = complete.title
            infoLabel.text = "Completed on \(formatter.string(from: complete.completeDate))"
            
            //setting labels
            if let location = complete.location {
                locationLabel.text = location
            } else {
                locationLabel.text = "Somewhere :P"
            }
            if let completeInfo = complete.completeDescription {
                detailView.text = completeInfo
            } else {
                detailView.isHidden = true
            }
            
            //setting imageView
            let imageRef = Constants.refs.storageBucketComplete.child("\(complete.firebaseKey).jpg")
            let download = imageRef.getData(maxSize: 1 * 4024 * 4024) { (imageData, error) in
                if let _ = error {
                    print("no picture found")
                    self.activitySpinner.isHidden = true
                    self.activitySpinner.stopAnimating()
                } else {
                    self.picture.image = UIImage(data: imageData!)
                    self.picture.isUserInteractionEnabled = true
                    self.picture.isHidden = false
                    self.activitySpinner.isHidden = true
                    self.activitySpinner.stopAnimating()
                    self.completeItem?.picture = self.picture.image
                }
            }
            _ = download.observe(.progress, handler: { (snapshot) in
                self.activitySpinner.startAnimating()
                self.activitySpinner.isHidden = false
            })
            
        } else if let incomplete = incompleteItem {
            self.completeMode = false
            titleLabel.text = incomplete.title
            infoLabel.text = "Added by \(incomplete.added) on \(formatter.string(from: incomplete.dateAdded))"
            
            //setting labels
            if let location = incomplete.location {
                locationLabel.text = location
            } else {
                locationLabel.text = "Somewhere :P"
            }
            if let description = incomplete.description {
                detailView.text = description
            } else {
                detailView.isHidden = true
            }
        }
        
        detailView.sizeToFit()
        detailView.center.x = outlineView.center.x
    }
    
    @objc func createActionSheet() {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let complete = UIAlertAction(title: "Complete", style: .default) { (_:UIAlertAction) in
            self.didPressComplete()
        }
        let incomplete = UIAlertAction(title: "Make Incomplete", style: .default) { (_:UIAlertAction) in
            self.didPressIncomplete()
        }
        let edit = UIAlertAction(title: "Edit", style: .default) { (_:UIAlertAction) in
            self.didPressEdit()
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_:UIAlertAction) in
            self.didPressDelete()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_:UIAlertAction) in
            return
        }
        
        menu.addAction(edit)
        if self.completeItem == nil { menu.addAction(complete) }
        if self.incompleteItem == nil { menu.addAction(incomplete)}
        menu.addAction(delete)
        menu.addAction(cancel)
        self.present(menu, animated: true)
    }
    
    func didPressComplete() {
        let backButton = UIBarButtonItem()
        backButton.title = "Cancel"
        navigationItem.backBarButtonItem = backButton
        self.performSegue(withIdentifier: "completeBucketItem", sender: nil)
    }
    
    func didPressIncomplete() {
        let incompleteAlert = UIAlertController(title: "Are you sure you want to make this item incomplete?", message: "The completed information for this item will be lost forever", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_:UIAlertAction) in
            return
        }
        let incompleteAction = UIAlertAction(title: "Make Incomplete", style: .default) { (_:UIAlertAction) in
            let incompleteRef = Constants.refs.databaseBucketIncomplete.child((self.completeItem?.firebaseKey)!)
            let completeRef = Constants.refs.databaseBucketComplete.child((self.completeItem?.firebaseKey)!)
            completeRef.removeValue()
            
            //resetting database
            var item = ["title": self.completeItem?.title]
            item["addedBy"] = self.completeItem?.added
            item["date"] = String((self.completeItem?.dateAdded.timeIntervalSinceReferenceDate)!)
            if let location = self.completeItem?.location { item["location"] = location } else { item["location"] = "" }
            if let description = self.completeItem?.description { item["description"] = description} else { item["description"] = "" }
            
            incompleteRef.setValue(item)
            self.navigationController?.popViewController(animated: true)
            
            //clearing out picture
            let imageDeleteRef = Constants.refs.storageBucketComplete.child("\((self.completeItem?.firebaseKey)!).jpg")
            imageDeleteRef.delete { (error) in
                if let _ = error {
                    print("Picture could not be deleted")
                }
            }
        }
        
        incompleteAlert.addAction(cancelAction)
        incompleteAlert.addAction(incompleteAction)
        self.present(incompleteAlert, animated: true)
        
    }
    
    func didPressEdit() {
        let backButton = UIBarButtonItem()
        backButton.title = "Cancel"
        navigationItem.backBarButtonItem = backButton
        self.performSegue(withIdentifier: "editBucketItem", sender: nil)
    }
    
    func didPressDelete() {
        let deleteAlert = UIAlertController(title: "Are you sure you want to delete this item?", message: "Deleted items are lost forever", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_:UIAlertAction) in
            return
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_:UIAlertAction) in
            if self.completeMode {
                let deleteRef = Constants.refs.databaseBucketComplete.child((self.completeItem?.firebaseKey)!)
                deleteRef.removeValue()
                let imageDeleteRef = Constants.refs.storageBucketComplete.child("\((self.completeItem?.firebaseKey)!).jpg")
                imageDeleteRef.delete { (error) in
                    if let _ = error {
                        print("Picture could not be deleted")
                    }
                }
            } else {
                let deleteRef = Constants.refs.databaseBucketIncomplete.child((self.incompleteItem?.firebaseKey)!)
                deleteRef.removeValue()
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)
        self.present(deleteAlert, animated: true)
    }
    
    @IBAction func didTapPicture(_ sender: UITapGestureRecognizer) {
        let newImageView = sender.view as! UIImageView
        let currentImageView = UIImageView(image: newImageView.image)
        currentImageView.frame = UIScreen.main.bounds
        currentImageView.backgroundColor = .black
        currentImageView.contentMode = .scaleAspectFit
        currentImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        currentImageView.addGestureRecognizer(tap)
        self.view.addSubview(currentImageView)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "completeBucketItem" {
            let next = segue.destination as! BucketCompleteViewController
            next.incompleteItemKey = incompleteItem?.firebaseKey
        } else if segue.identifier == "editBucketItem" {
            let next = segue.destination as! BucketEditViewController
            next.completeMode = completeMode
            if self.completeMode {
                next.completeItem = self.completeItem
            } else {
                next.incompleteItem = self.incompleteItem
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
