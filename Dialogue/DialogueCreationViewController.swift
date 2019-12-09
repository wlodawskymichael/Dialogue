//
//  DialogueSettingsViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/6/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class DialogueCreationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // TODOs:
    // Add profile image to cell
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupMembersTableView: UITableView!
    
    var selectedContacts: [SpeakerStruct] = []
    var followable: Bool = true
    
//    init(selectedContacts: [SpeakerStruct]) {
//        super.init(nibName: nil, bundle: nil)
//        self.selectedContacts = selectedContacts
//        print("hi")
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    deinit {
        print("Deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedContacts)
        setUpDelegates()
    }
    
    private func setUpDelegates() {
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
        groupMembersTableView.rowHeight = 104
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupMemberSettingTableViewCell.identifier, for: indexPath as IndexPath) as! GroupMemberSettingTableViewCell
        
        NetworkHelper.getUserDisplayName(userId: selectedContacts[indexPath.row].userId, completion: { (name, error) in
            cell.memberDisplayName?.text = name
        })
            
        NetworkHelper.getUserProfilePicture(userId: selectedContacts[indexPath.row].userId) { image, error in
            if image != nil {
                cell.memberProfilePicture.image = image
            }
        }
        
        cell.memberAdminToggle.isOn = selectedContacts[indexPath.row].admin
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveDialogueToMyDialogues" {
            if groupNameTextField.text?.isEmpty ?? true {
                Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
                return false
            } else {
                let owner = SpeakerStruct(userId: NetworkHelper.getCurrentUser()!.uid, admin: true)
                var speakers = [owner]
                for cell in groupMembersTableView.visibleCells {
                    let groupMemberCell = cell as! GroupMemberSettingTableViewCell
                    let indexPath = groupMembersTableView.indexPath(for: cell)
                    let groupMember = selectedContacts[indexPath!.row]
                    speakers.append(SpeakerStruct(userId: groupMember.userId, admin: groupMemberCell.memberAdminToggle.isOn))
                }
                //print(speakers)
                NetworkHelper.writeGroup(group: GroupStruct(groupID: groupNameTextField.text!, speakers: speakers, spectators: [], followable: followable)) { // TODO add spectators support
                    for speaker in speakers {
                        print("HELLO +++>>>"+speaker.userId)
                        NetworkHelper.getUser(userId: speaker.userId, completion: { (user, error) in
                            var newUser = user
                            newUser!.groupList.append(self.groupNameTextField.text!)
                            NetworkHelper.writeUser(user: newUser!, completion: nil)
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
    
    // code to dismiss keyboard when user clicks on background
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
