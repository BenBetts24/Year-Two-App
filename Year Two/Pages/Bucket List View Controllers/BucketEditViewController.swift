//
//  BucketEditViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/17/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit
import Firebase

class BucketEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var inputImageView: UIImageView!
    @IBOutlet var imageButton: UIButton!
    @IBOutlet var newImageButton: UIButton!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var locationField: UITextField!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var completeDescriptionView: UITextView!
    
    var pickerData: [String] = ["Title", "Location", "Description", "Completion Info", "Picture"]
    let incompletePickerData: [String] = ["Title", "Location", "Description"]
    let modeData: [editMode] = [.title, .location, .description, .completeDescription, .image]
    var completeMode: Bool = true
    
    var completeItem: BucketListItemComplete?
    var incompleteItem: BucketListItem?
    
    enum editMode {
        case title
        case location
        case description
        case completeDescription
        case image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSave))
        self.descriptionView.layer.borderWidth = 0.6
        self.descriptionView.layer.borderColor = Constants.colors.borderColor.cgColor
        self.descriptionView.layer.cornerRadius = 5.0
        self.completeDescriptionView.layer.borderWidth = 0.6
        self.completeDescriptionView.layer.borderColor = Constants.colors.borderColor.cgColor
        self.completeDescriptionView.layer.cornerRadius = 5.0
        self.inputImageView.layer.borderWidth = 0.6
        self.inputImageView.layer.borderColor = Constants.colors.borderColor.cgColor
        self.inputImageView.layer.cornerRadius = 5.0
        self.newImageButton.layer.borderWidth = 0.6
        self.newImageButton.layer.borderColor = Constants.colors.borderColor.cgColor
        self.newImageButton.layer.cornerRadius = 5.0
        
        self.hideAllInput()
        self.showInput(inputType: .title)
        
        if completeMode {
            self.titleField.text = completeItem?.title
            if let location = completeItem?.location { self.locationField.text = location }
            if let description = completeItem?.description { self.descriptionView.text = description }
            if let complete = completeItem?.completeDescription { self.completeDescriptionView.text = complete }
            if let image = completeItem?.picture { self.inputImageView.image = image }
        } else {
            self.titleField.text = incompleteItem?.title
            if let location = incompleteItem?.location { self.locationField.text = location }
            if let description = incompleteItem?.description { self.descriptionView.text = description }
        }
        
        if !completeMode { self.pickerData = self.incompletePickerData }
    }
    
    @objc func didPressSave() {
        if let title = self.titleField.text {
            if title != "" {
                
                //change the data of the item
                if self.completeMode {
                    self.completeItem?.title = self.titleField.text!
                    if let location = locationField.text { self.completeItem?.location = location }
                    if let description = descriptionView.text { self.completeItem?.description = description }
                    if let complete = completeDescriptionView.text { self.completeItem?.completeDescription = complete }
                    if let image = inputImageView.image { self.completeItem?.picture = image }
                } else {
                    self.incompleteItem?.title = self.titleField.text!
                    if let location = locationField.text { self.incompleteItem?.location = location }
                    if let description = descriptionView.text { self.incompleteItem?.description = description }
                }
                
                //now save to database
                if self.completeMode {
                    let editRef = Constants.refs.databaseBucketComplete.child((self.completeItem?.firebaseKey)!)
                    var item = ["title": title]
                    item["addedBy"] = completeItem?.added
                    item["date"] = String((completeItem?.dateAdded.timeIntervalSinceReferenceDate)!)
                    item["completeDate"] = String((completeItem?.completeDate.timeIntervalSinceReferenceDate)!)
                    if let location = completeItem?.location { item["location"] = location} else { item["location"] = "" }
                    if let description = completeItem?.description { item["description"] = description } else { item["description"] = "" }
                    if let complete = completeItem?.completeDescription { item["completeDescription"] = complete } else { item["completeDescription"] = "" }
                    editRef.setValue(item)
                } else {
                    let editRef = Constants.refs.databaseBucketIncomplete.child((self.incompleteItem?.firebaseKey)!)
                    var item = ["title": title]
                    item["addedBy"] = incompleteItem?.added
                    item["date"] = String((incompleteItem?.dateAdded.timeIntervalSinceReferenceDate)!)
                    if let location = incompleteItem?.location { item["location"] = location } else { item["location"] = "" }
                    if let description = incompleteItem?.description { item["description"] = description } else { item["description"] = "" }
                    editRef.setValue(item)
                }
                
                //last thing is to change/add picture in storage
                if self.completeMode {
                    if let image = completeItem?.picture {
                        let metaData = StorageMetadata()
                        if let data = UIImageJPEGRepresentation(image, 1.0) {
                            let imageRef = Constants.refs.storageBucketComplete.child("\((completeItem?.firebaseKey)!).jpg")
                            metaData.contentType = "image/jpeg"
                            imageRef.putData(data, metadata: metaData) { (metadata, error) in
                                if let _ = error {
                                    print("error uploading")
                                }
                                guard let _ = metadata else {
                                    print("error with metadata")
                                    return
                                }
                            }
                        }
                    }
                }
                var viewControllers = navigationController?.viewControllers
                viewControllers?.removeLast(2)
                navigationController?.setViewControllers(viewControllers!, animated: true)
                return
            }
        }
        self.createTitleAlert()
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
    
    //working prepping UI elements
    func hideAllInput() {
        //imageView
        self.inputImageView.isHidden = true
        self.inputImageView.isUserInteractionEnabled = false
        self.imageButton.isEnabled = false
        self.imageButton.isHidden = true
        self.newImageButton.isEnabled = false
        self.newImageButton.isHidden = true
        //titleField
        self.titleField.isEnabled = false
        self.titleField.isHidden = true
        //locationField
        self.locationField.isEnabled = false
        self.locationField.isHidden = true
        //descriptionView
        self.descriptionView.isUserInteractionEnabled = false
        self.descriptionView.isHidden = true
        //completeDescriptionView
        self.completeDescriptionView.isUserInteractionEnabled = false
        self.completeDescriptionView.isHidden = true
    }
    
    func showInput(inputType: editMode) {
        self.hideAllInput()
        switch (inputType) {
        case .title:
            self.titleField.isEnabled = true
            self.titleField.isHidden = false
        case .location:
            self.locationField.isEnabled = true
            self.locationField.isHidden = false
        case .description:
            self.descriptionView.isUserInteractionEnabled = true
            self.descriptionView.isHidden = false
        case .completeDescription:
            self.completeDescriptionView.isUserInteractionEnabled = true
            self.completeDescriptionView.isHidden = false
        case .image:
            self.inputImageView.isUserInteractionEnabled = true
            self.inputImageView.isHidden = false
            self.newImageButton.isEnabled = true
            self.newImageButton.isHidden = false
            if self.completeMode && self.completeItem?.picture != nil {
                self.imageButton.isEnabled = true
                self.imageButton.isHidden = false
            }
        }
    }
    
    //Image interaction
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer) {
        if self.completeItem?.picture != nil {
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
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func didChangeImage(_ sender: Any) {
        let pictureMenu: UIAlertController = UIAlertController(title: "Add a picture", message: nil, preferredStyle: .actionSheet)
        let cameraAction: UIAlertAction = UIAlertAction(title: "Open Camera", style: .default) { (_:UIAlertAction) in
            self.openCamera()
        }
        let libraryAction: UIAlertAction = UIAlertAction(title: "Open Photo Library", style: .default) { (_:UIAlertAction) in
            self.openPhotoLibrary()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (_:UIAlertAction) in
            return
        }
        pictureMenu.addAction(cameraAction)
        pictureMenu.addAction(libraryAction)
        pictureMenu.addAction(cancelAction)
        self.present(pictureMenu, animated: true) {
            return
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.completeItem?.picture = image
        self.inputImageView.image = self.completeItem?.picture!
        self.imageButton.isHidden = false
        self.imageButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didDeleteImage(_ sender: Any) {
        self.completeItem?.picture = nil
        self.inputImageView.image = nil
        self.imageButton.isEnabled = false
        self.imageButton.isHidden = true
    }
    
    //Picker View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.showInput(inputType: modeData[row])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
