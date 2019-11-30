//
//  DialogueSettingsViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class DialogueSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // TODOs:
    // Add profile image to cell
    
    @IBOutlet weak var GroupNameTextField: UITextField!
    @IBOutlet weak var groupMembersTableView: UITableView!
    
    var selectedContacts: [UserStruct] = []
    var followable: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        groupMembersTableView.rowHeight = 104
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberSettingTableViewCell.identifier, for: indexPath as IndexPath) as! GroupMemberSettingTableViewCell
        cell.memberDisplayName?.text = selectedContacts[indexPath.row].displayName
        NetworkHelper.getUserProfilePicture(userId: selectedContacts[indexPath.row].userId) { image, error in
            if image != nil {
                cell.memberProfilePicture.image = image
            }
        }
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveDialogueToMyDialogues" {
            if GroupNameTextField.text?.isEmpty ?? true {
                Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
                return false
            } else {
                let owner = SpeakerStruct(userID: NetworkHelper.getCurrentUser()!.uid, admin: true)
                var speakers = [owner]
                for cell in groupMembersTableView.visibleCells {
                    let groupMemberCell = cell as! GroupMemberSettingTableViewCell
                    let indexPath = groupMembersTableView.indexPath(for: cell)
                    let groupMember = selectedContacts[indexPath!.row]
                    speakers.append(SpeakerStruct(userID: groupMember.userId, admin: groupMemberCell.memberAdminToggle.isOn))
                }
                print(speakers)
                NetworkHelper.writeGroup(group: GroupStruct(groupID: GroupNameTextField.text!, speakers: speakers, spectators: [], followable: followable)) { // TODO add spectators support
                    for speaker in speakers {
                        print("HELLO +++>>>"+speaker.userID)
                        NetworkHelper.getUser(userId: speaker.userID, completion: { (user, error) in
                            var newUser = user
                            newUser.groupList.append(self.GroupNameTextField.text!)
                            NetworkHelper.writeUser(user: newUser, completion: nil)
                        })
                    }
                }
                return true
            }
        }
        return false
    }
    
    @IBAction func followableChanged(sender: UISwitch) {
        followable = sender.isOn
    }
    
    @IBAction func leaveGroup(sender: UIButton) {
        print("Leaving group...")
        NetworkHelper.getUser(completion: { (user, error) in
            var newUser = user
            if let index = newUser.groupList.firstIndex(of: self.GroupNameTextField.text!) {
                newUser.groupList.remove(at: index)
            }
            NetworkHelper.writeUser(user: newUser, completion: nil)
        })
    }
    
    @IBAction func deleteGroup(sender: UIButton) {
        print("Delete group triggered")
    }
    
    

}
