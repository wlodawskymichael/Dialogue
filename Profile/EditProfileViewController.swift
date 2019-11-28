//
//  EditProfileViewController.swift
//  Dialogue
//
//  Created by Sahil Parikh on 11/27/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import AVFoundation

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        self.displayNameLabel.text = NetworkHelper.currentInAppUserData?.displayName
        if let profilePicture = NetworkHelper.currentInAppUserData?.profilePicture {
            self.profilePictureImageView.image = profilePicture
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            NetworkHelper.setProfilePicture(image: chosenImage)
            profilePictureImageView.image = chosenImage;
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
