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
    
    var groupId:String = ""
    var selectedContacts:[SpeakerStruct] = []
    var followable: Bool = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedContacts)
        setUpUI()
        setUpDelegates()
    }
    
    func setVariables(groupId:String, selectedContacts:[SpeakerStruct], followable:Bool) {
        self.groupId = groupId
        self.selectedContacts = selectedContacts
        self.followable = followable
    }
    
    private func setUpUI() {
        let margins = view.layoutMarginsGuide
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(groupNameLabel)
        view.addSubview(followingLabel)
        view.addSubview(followingSwitch)
        view.addSubview(groupMembersTableView)
        
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        followingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingSwitch.translatesAutoresizingMaskIntoConstraints = false
        groupMembersTableView.translatesAutoresizingMaskIntoConstraints = false
        
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
            groupMembersTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            groupMembersTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
        
        groupNameLabel.text = groupId
        groupNameLabel.textAlignment = .center
        groupNameLabel.font = .boldSystemFont(ofSize: groupNameLabel.font.pointSize)
        
        followingLabel.text = "Followable"
        
        followingSwitch.isOn = followable
        followingSwitch.addTarget(self, action: #selector(followableChanged(_:)), for: .valueChanged)
        
        groupMembersTableView.rowHeight = 104
        groupMembersTableView.separatorStyle = .singleLine
        
        
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
}
