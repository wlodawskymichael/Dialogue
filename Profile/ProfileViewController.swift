//
//  ProfileViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var DisplayNameButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkHelper.getUserDisplayName { (displayName, error) in
            self.DisplayNameButton.setTitle(displayName, for: .normal)
        }
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
