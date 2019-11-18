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
    var selectedContacts:[SpeakerStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveDialogueToMyDialogues" {
            if GroupNameTextField.text?.isEmpty ?? true {
                Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
                return false
            } else {
                let owner = SpeakerStruct(userID: NetworkHelper.getCurrentUser()!.uid, admin: true)
                let speakers = [owner] + selectedContacts
                NetworkHelper.writeGroup(group: GroupStruct(groupID: GroupNameTextField.text!, speakers: speakers, spectators: [])) { // TODO add spectators support
                    NetworkHelper.getUser(completion: { (user, error) in
                        var newUser = user
                        newUser.groupList.append(self.GroupNameTextField.text!)
                        NetworkHelper.writeUser(user: newUser, completion: nil)
                    })
                }
                return true
            }
        }
        return false
    }
    
    @IBAction func onFollowable(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This switch will toggle if this Group to be public in future releases.", vc: self)
    }

}
