//
//  DialogueSettingsViewController.swift
//  Dialogue
//
//  Created by William Lemens on 12/1/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import Firebase

class DialogueSettingsViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate : ChatViewController?
    
    let groupNameLabel = UILabel()
    let followingLabel = UILabel()
    let followingSwitch = UISwitch()
    let groupMembersTableView = UITableView()
    let addButton = UIButton()
    let leaveButton = UIButton()
    let deleteButton = UIButton()
    
    private let db = Firestore.firestore()
    private var memberListener : ListenerRegistration? = nil
    
    var userId:String = ""
    var userIsAdmin:Bool = false
    var groupId:String = ""
    var selectedContacts:[SpeakerStruct] = []
    var followable: Bool = true
    
    private var removeUID = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        memberListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberListener = db.document("groups/"+groupId).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("ERROR fetching user document for group listener")
                return
            }
            self.selectedContacts = []
            let speakerData = document.get("speakers") as? [NSDictionary]
            for speaker in speakerData ?? [] {
                let admin: Bool = speaker["admin"] as? Bool ?? false
                let userID: String = speaker["userID"] as? String ?? "None"
                self.selectedContacts.append(SpeakerStruct(userId: userID, admin: admin))
            }
            self.groupMembersTableView.reloadData()
        }
        
        print(selectedContacts)
        setUpUI()
        setUpDelegates()
    }
    
    func setVariables(groupId:String, followable:Bool, userId:String, userIsAdmin:Bool) {
        self.groupId = groupId
        self.followable = followable
        self.userId = userId
        self.userIsAdmin = userIsAdmin
    }
    
    private func setUpUI() {
        let margins = view.layoutMarginsGuide
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(groupNameLabel)
        view.addSubview(followingLabel)
        view.addSubview(followingSwitch)
        view.addSubview(groupMembersTableView)
        view.addSubview(addButton)
        view.addSubview(leaveButton)
        view.addSubview(deleteButton)
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingSwitch.translatesAutoresizingMaskIntoConstraints = false
        groupMembersTableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        leaveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            //            groupMembersTableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            groupMembersTableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            groupMembersTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            groupMembersTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: leaveButton.topAnchor, constant: -5),
            
            leaveButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            leaveButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            leaveButton.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -5),
            
            deleteButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20)
        ])
        
        groupNameLabel.text = groupId
        groupNameLabel.textAlignment = .center
        groupNameLabel.font = .boldSystemFont(ofSize: groupNameLabel.font.pointSize)
        
        followingLabel.text = "Followable"
        
        followingSwitch.isOn = followable
        followingSwitch.addTarget(self, action: #selector(followableChanged(_:)), for: .valueChanged)
        
        groupMembersTableView.rowHeight = 104
        groupMembersTableView.separatorStyle = .singleLine
        
        addButton.setTitle("Add Member(s)", for: .normal)
        addButton.setTitleColor(.blue, for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        
        leaveButton.setTitleColor(.red, for: .normal)
        leaveButton.setTitle("Leave group", for: .normal)
        leaveButton.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)
        
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitle("Delete group", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        
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
        
        removeUID = selectedContacts[indexPath.row].userId
        cell.kickButton.addTarget(self, action: #selector(removeUser), for: .touchUpInside)
        
        return cell
    }
    
    @IBAction func followableChanged(_ sender: UISwitch) {
        followable = sender.isOn
        print(followable)
    }
    
    @IBAction func saveTapped() {
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
    
    @IBAction func addTapped() {
        print("add tapped")
        
    }
    
    @IBAction func leaveTapped() {
        removeUID = userId
        removeUser()
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func removeUser() {
        // write group without this user in their speakers list
        NetworkHelper.getGroup(groupID: groupId, completion: { (group, error) in
            if error == nil {
                var newSpeakers: [SpeakerStruct] = []
                for speaker in group.speakers {
                    if speaker.userId != self.removeUID {
                        newSpeakers.append(speaker)
                    }
                }
                if newSpeakers.count < 1 {
                    self.db.collection("groups").document(group.groupID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        }
                    }
                } else {
                    NetworkHelper.writeGroup(group: GroupStruct(groupID: group.groupID, speakers: newSpeakers, spectators: group.spectators, followable: group.followable))
                }
            }
        })
        // write user without this group in their group list
        NetworkHelper.getUser(userId: self.removeUID, completion: { (user, error) in
            if let user = user {
                var newGroups: [String] = []
                for group in user.groupList {
                    if group != self.groupId {
                        newGroups.append(group)
                    }
                }
                NetworkHelper.writeUser(user: UserStruct(userId: user.userId, displayName: user.displayName, groupList: newGroups, followList: user.followingList))
            }
        })
    }
    
    @IBAction func deleteTapped() {
        NetworkHelper.getGroup(groupID: groupId, completion: { (group, error) in
            if error == nil {
                for speaker in group.speakers {
                    // write user without this group in their group list
                    NetworkHelper.getUser(userId: speaker.userId, completion: { (user, error) in
                        if let user = user {
                            var newGroups: [String] = []
                            for group in user.groupList {
                                if group != self.groupId {
                                    newGroups.append(group)
                                }
                            }
                            NetworkHelper.writeUser(user: UserStruct(userId: user.userId, displayName: user.displayName, groupList: newGroups, followList: user.followingList))
                        }
                    })
                }
                
                self.db.collection("groups").document(group.groupID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    }
                }
            }
        })
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}
