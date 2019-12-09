//
//  ProfileViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkHelper.getUserDisplayName { (displayName, error) in
            self.displayNameLabel?.text = displayName
        }
        
        if let profilePicture = NetworkHelper.currentInAppUserData?.profilePicture {
            self.profileImageView.image = profilePicture
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingsButton.layer.cornerRadius = 20
        logoutButton.layer.cornerRadius = 20
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    @IBAction func onLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance().signOut()
            try LoginManager().logOut()
        } catch {
            print("Failed to sign-out user")
        }
    }
    
}
