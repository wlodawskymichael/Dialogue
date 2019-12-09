//
//  EditProfileViewController.swift
//  Dialogue
//
//  Created by Sahil Parikh on 11/27/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import AVFoundation

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var changeProfilePictureButton: UIButton!
    @IBOutlet weak var changeDisplayNameButton: UIButton!
    let picker = UIImagePickerController()
    var changeNameAlertController: UIAlertController!
    var saveNameAction: UIAlertAction!
    var newNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        self.displayNameLabel.text = "Current display name: \(NetworkHelper.currentInAppUserData!.displayName)"
        if let profilePicture = NetworkHelper.currentInAppUserData?.profilePicture {
            self.profilePictureImageView.image = profilePicture
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeProfilePictureButton.layer.cornerRadius = 20
        changeDisplayNameButton.layer.cornerRadius = 20
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            Loading.show()
            NetworkHelper.setProfilePicture(image: chosenImage) {
                self.profilePictureImageView.image = chosenImage;
                Loading.hide()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func changeDisplayNamePressed(_ sender: Any) {
        changeNameAlertController = UIAlertController(title: "Change display name", message: "Please enter your new display name", preferredStyle: .alert)
        changeNameAlertController.addTextField { (textField) in
            self.newNameTextField = textField
            self.newNameTextField.addTarget(self, action: #selector(EditProfileViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
            self.newNameTextField.delegate = self
            self.newNameTextField.placeholder = "New display name"
        }
        saveNameAction = UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let newDisplayName = self.changeNameAlertController!.textFields![0].text // Force unwrapping because we know it exists.
            Loading.show()
            NetworkHelper.changeUserDisplayName(newDisplayName: newDisplayName!) {
                self.displayNameLabel.text = "Current display name: \(newDisplayName!)"
                Loading.hide()
            }
        })
        changeNameAlertController.addAction(saveNameAction)
        changeNameAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        changeNameAlertController.actions[0].isEnabled = false
        self.present(changeNameAlertController, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (!(newNameTextField.text?.isEmpty)!) {
            saveNameAction.isEnabled = true
        } else {
            saveNameAction.isEnabled = false
        }
    }
    
    
    @IBAction func changeProfilePicturePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Change profile picture", message: "Set a new profile picture.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            if UIImagePickerController.availableCaptureModes(for: .front) != nil {
                        
                // camera exists, check authoriation status
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) {
                        accessGranted in
                        guard accessGranted == true else {return}
                    }
                case .authorized:
                    break
                default:
                    print("Access denied!")
                    return
                }
                
                self.picker.allowsEditing = true
                self.picker.sourceType = .camera
                self.picker.cameraCaptureMode = .photo
                
                self.present(self.picker, animated: true, completion: nil)
                
            } else {
                // no camera is available, pop up alert
                
                let alertVC = UIAlertController(
                    title: "No camera",
                    message: "Sorry, this device has no camera",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: nil)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { (_) in
            self.picker.allowsEditing = true
            self.picker.sourceType = .photoLibrary
            
            self.present(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
