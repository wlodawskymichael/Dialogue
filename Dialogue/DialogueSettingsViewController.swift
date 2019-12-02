//
//  DialogueSettingsViewController.swift
//  Dialogue
//
//  Created by William Lemens on 12/1/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class DialogueSettingsViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate : ChatViewController?
    
    let groupNameLabel = UILabel()
    let followingLabel = UILabel()
    let followingSwitch = UISwitch()
    let groupMembersTableView = UITableView()
    //    let leaveButton = UIButton()
    //    let deleteButton = UIButton()
    
    var groupId:String = ""
    var selectedContacts:[SpeakerStruct] = []
    var followable: Bool = true
    //    var userId:String = ""
    //    var userIsAdmin:Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        print("DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedContacts)
        setUpUI()
        setUpDelegates()
    }
    
    func setVariables(groupId:String, selectedContacts:[SpeakerStruct], followable:Bool/*, userId:String, userIsAdmin:Bool*/) {
        self.groupId = groupId
        self.selectedContacts = selectedContacts
        self.followable = followable
        //        self.userId = userId
        //        self.userIsAdmin = userIsAdmin
    }
    
    private func setUpUI() {
        let margins = view.layoutMarginsGuide
        let guide = view.safeAreaLayoutGuide
        
        //        if !userIsAdmin {
        //            view.addSubview(leaveButton)
        //            leaveButton.translatesAutoresizingMaskIntoConstraints = false
        //            NSLayoutConstraint.activate([
        //                leaveButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
        //                leaveButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        //                leaveButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
        //                leaveButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20)
        //            ])
        //        } else {
        view.addSubview(groupNameLabel)
        view.addSubview(followingLabel)
        view.addSubview(followingSwitch)
        view.addSubview(groupMembersTableView)
        //            view.addSubview(leaveButton)
        //            view.addSubview(deleteButton)
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingSwitch.translatesAutoresizingMaskIntoConstraints = false
        groupMembersTableView.translatesAutoresizingMaskIntoConstraints = false
        //            leaveButton.translatesAutoresizingMaskIntoConstraints = false
        //            deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            groupNameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            groupNameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            groupNameLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20),
            groupNameLabel.bottomAnchor.constraint(equalTo: followingLabel.topAnchor, constant: -20),
            groupNameLabel.bottomAnchor.constraint(equalTo: followingSwitch.topAnchor, constant: -20),
            
            followingLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 70),
            followingLabel.trailingAnchor.constraint(equalTo: followingSwitch.leadingAnchor, constant:  100),
            
            followingSwitch.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -70),
            
            groupMembersTableView.topAnchor.constraint(equalTo: followingSwitch.bottomAnchor, constant: 20),
            groupMembersTableView.topAnchor.constraint(equalTo: followingLabel.bottomAnchor, constant: 20),
            groupMembersTableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            //                groupMembersTableView.bottomAnchor.constraint(equalTo: leaveButton.topAnchor, constant: -20),
            groupMembersTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            groupMembersTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)//,
            
            //                leaveButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            //                leaveButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            //                leaveButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -20),
            //
            //                deleteButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            //                deleteButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            //                deleteButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20)
        ])
        
        groupNameLabel.text = groupId
        
        followingLabel.text = "Followable"
        
        followingSwitch.isOn = followable
        followingSwitch.addTarget(self, action: #selector(followableChanged(_:)), for: .valueChanged)
        
        groupMembersTableView.rowHeight = 104
        groupMembersTableView.separatorStyle = .singleLine
        
        //            leaveButton.setTitle("Leave Group", for: .normal)
        //            leaveButton.setTitleColor(.red, for: .normal)
        //            leaveButton.addTarget(self, action: #selector(leaveGroup), for: .touchUpInside)
        //
        //            deleteButton.setTitle("Delete Group", for: .normal)
        //            deleteButton.setTitleColor(.red, for: .normal)
        //            deleteButton.addTarget(self, action: #selector(deleteGroup), for: .touchUpInside)
        //        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
    }
    
    private func setUpDelegates() {
        groupMembersTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        groupMembersTableView.delegate = self
        groupMembersTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("hm...")
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
        
        NetworkHelper.getUserDisplayName(userId: selectedContacts[indexPath.row].userId, completion: { (name, error) in
            cell.nameLabel.text = name
        })
        
        NetworkHelper.getUserProfilePicture(userId: selectedContacts[indexPath.row].userId) { image, error in
            if image != nil {
                cell.userImage.image = image
            }
        }
        
        cell.adminToggle.isOn = selectedContacts[indexPath.row].admin
        //        cell.labUserName.text = "Name"
        //        cell.labMessage.text = "Message \(indexPath.row)"
        //        cell.labTime.text = "TIIIME"
        
        return cell
    }
    
    @IBAction func followableChanged(_ sender: UISwitch) {
        followable = sender.isOn
        print(followable)
    }
    
    //    @IBAction func leaveGroup(sender: UIButton) {
    //        print("Leaving group...")
    //        NetworkHelper.getUser(completion: { (user, error) in
    //            if error != nil {
    //                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
    //            } else {
    //                var newUser = user
    //                if let index = newUser.groupList.firstIndex(of: self.groupNameTextField.text!) {
    //                    newUser.groupList.remove(at: index)
    //                }
    //                NetworkHelper.writeUser(user: newUser, completion: nil)
    //
    //                NetworkHelper.getGroup(groupID: self.groupId, completion: { (group, error) in
    //                    if error != nil {
    //                        print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
    //                    } else {
    //                        var newSpeakers:[SpeakerStruct] = []
    //                        for speaker in group.speakers {
    //                            if speaker.userId != user.userId {
    //                                newSpeakers.append(speaker)
    //                            }
    //                        }
    //                        NetworkHelper.writeGroup(group: GroupStruct.init(groupID: group.groupID, speakers: newSpeakers, spectators: group.spectators, followable: group.followable))
    //                    }
    //                })
    //            }
    //        })
    //        exitToDialogues()
    //    }
    //
    //    @IBAction func deleteGroup(sender: UIButton) {
    //        print("Delete group triggered")
    //    }
    //
    //    func exitToDialogues() {
    //        let barButtonItem = navigationItem.leftBarButtonItem
    //        UIApplication.shared.sendAction(barButtonItem!.action!, to: barButtonItem!.target, from: self, for: nil)
    //    }
    
    @IBAction func saveTapped() {
        print("saveTapped")
        
        if groupNameLabel.text?.isEmpty ?? true {
            Alerts.singleChoiceAlert(title: "Error", message: "Group Name cannot be empty or a duplicate.", vc: self)
        } else {
            NetworkHelper.getGroup(groupID: groupId, completion: { (group, error) in
                if error != nil {
                    Alerts.singleChoiceAlert(title: "Error", message: "Failed to save.", vc: self)
                } else {
                    var speakers:[SpeakerStruct] = []
                    for cell in self.groupMembersTableView.visibleCells {
                        let groupMemberCell = cell as! SettingsTableViewCell
                        let indexPath = self.groupMembersTableView.indexPath(for: cell)
                        let groupMember = self.selectedContacts[indexPath!.row]
                        speakers.append(SpeakerStruct(userId: groupMember.userId, admin: groupMemberCell.adminToggle.isOn))
                    }
                    let newGroup = GroupStruct(groupID: self.groupId, speakers: speakers, spectators: group.spectators, followable: self.followable)
                    NetworkHelper.writeGroup(group: newGroup)
                    self.delegate?.group = newGroup
                }
            })
        }
    }
}
