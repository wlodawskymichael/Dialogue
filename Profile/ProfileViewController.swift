//
//  ProfileViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var DisplayNameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkHelper.getUserDisplayName { (displayName, error) in
            self.displayNameLabel?.text = displayName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingsButton.layer.cornerRadius = 20
    }
    
    @IBAction func onProfilePic(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This button will allow you to change your profile picture in future releases.", vc: self)
    }
    
    @IBAction func onNotifications(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This button will allow you to toggle notification preferences in future releases", vc: self)
    }

    @IBAction func onDisplayName(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This button will allow you to change your display name in future releases", vc: self)
    }

    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Failed to sign-out user")
        }
    }
    
}
