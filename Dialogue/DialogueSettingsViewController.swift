//
//  DialogueSettingsViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class DialogueSettingsViewController: UIViewController {

    @IBOutlet weak var GroupNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveDialogueToMyDialogues" {
            if GroupNameTextField.text?.isEmpty ?? true {
                Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
                return false
            } else {
                let owner = SpeakerStruct(userID: NetworkHelper.getCurrentUser()!.uid, admin: true)
                NetworkHelper.writeGroup(group: GroupStruct(groupID: GroupNameTextField.text!, speakers: [owner], spectators: [])) {}
                return true
            }
        }
        return false
    }
    
    @IBAction func onFollowable(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This switch will toggle if this Group to be public in future releases.", vc: self)
    }
    
    @IBAction func onSave(_ sender: Any) {
        if GroupNameTextField.text?.isEmpty ?? true {
            Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
            return
        } else {
            let owner = SpeakerStruct(userID: NetworkHelper.getCurrentUser()!.uid, admin: true)
            NetworkHelper.writeGroup(group: GroupStruct(groupID: GroupNameTextField.text!, speakers: [owner], spectators: [])) {
                self.performSegue(withIdentifier: "saveDialogueToMyDialogues", sender: self)
            }
        }
    }

}
