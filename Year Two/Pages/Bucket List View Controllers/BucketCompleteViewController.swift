//
//  BucketCompleteViewController.swift
//  Year Two
//
//  Created by Benjamin Betts on 5/16/18.
//  Copyright © 2018 Benjamin Betts. All rights reserved.
//

import UIKit
import Firebase

class BucketCompleteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoView: UITextView!
    @IBOutlet var cancelImageButton: UIButton!
    
    var incompleteItemKey: String?
    var completeItem: BucketListItemComplete?
    var imagePicked: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didPressSave))
        infoView.layer.borderWidth = 0.6
        infoView.layer.borderColor = Constants.colors.borderColor.cgColor
        infoView.layer.cornerRadius = 5.0
        imageView.layer.cornerRadius = 5.0
        imageView.layer.borderWidth = 0.6
        imageView.layer.borderColor = Constants.colors.borderColor.cgColor
        imageView.isHidden = true
        cancelImageButton.isHidden = true
        cancelImageButton.isEnabled = false
        
        let query = Constants.refs.databaseBucketIncomplete.queryOrderedByKey().queryEqual(toValue: incompleteItemKey)
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let data = snapshot.value as? [String: String] {
                self?.titleLabel.text = data["title"]
                self?.completeItem = BucketListItemComplete(title: data["title"]!, dateAdded: Date(timeIntervalSinceReferenceDate: Double(data["date"]!)!), added: data["addedBy"]!, completeDate: Date(), key: snapshot.key)
                
                if data["description"] != "" { self?.completeItem?.description = data["description"] }
                if data["location"] != "" { self?.completeItem?.location = data["location"]}
            }
        })
    }
    
    @objc func didPressSave() {
        
        //completing BucketListItemCompleting
        if let completeData = infoView.text {
            if completeData != "" { self.completeItem?.completeDescription = completeData}
        }
        if let savedImage = self.imagePicked { self.completeItem?.picture = savedImage }
        
        //removing the database item in the incomplete table
        let deleteData = Constants.refs.databaseBucketIncomplete.child((self.completeItem?.firebaseKey)!)
        deleteData.removeValue()
        
        //now creating the new item in the complete table
        let addingData = Constants.refs.databaseBucketComplete.child((self.completeItem?.firebaseKey)!)
        
        var itemNew = ["title": completeItem?.title]
        if let location = completeItem?.location { itemNew["location"] = location } else { itemNew["location"] = "" }
        if let description = completeItem?.description { itemNew["description"] = description } else { itemNew["description"] = ""}
        itemNew["date"] = String(Double((completeItem?.dateAdded.timeIntervalSinceReferenceDate)!))
        itemNew["completeDate"] = String(Double((completeItem?.completeDate.timeIntervalSinceReferenceDate)!))
        itemNew["addedBy"] = completeItem?.added
        if let completeDescription = completeItem?.completeDescription { itemNew["completeDescription"] = completeDescription } else { itemNew["completeDescription"] = ""}
        
        addingData.setValue(itemNew)
        
        //uploading the image file (optional)
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
        
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeLast(2)
        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
    
    //Code for the image picker and ImageView
    
    @IBAction func addPicturePressed(_ sender: Any) {
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
        self.imagePicked = image
        self.imageView.image = self.imagePicked
        self.imageView.isHidden = false
        self.cancelImageButton.isHidden = false
        self.cancelImageButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didDeleteImage(_ sender: Any) {
        self.imageView.isHidden = true
        self.imageView.image = nil
        self.cancelImageButton.isHidden = true
        self.cancelImageButton.isEnabled = false
        self.imagePicked = nil
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
