//
//  CreateDialogueViewController.swift
//  Dialogue
//
//  Created by Dylan Ramage on 10/24/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateDialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private let db = Firestore.firestore()
    private var contacts:[UserStruct] = []
    private var selected:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        initTableView()
    }

    func initTableView() {
//        NetworkHelper.getUser(completion: { (user, error) in
//            self.contacts = user.friendList
//            if self.contacts.count < 1 {
//                let frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
//                let messageLabel = UILabel(frame: frame)
//                messageLabel.textColor = UIColor.black
//                messageLabel.numberOfLines = 0
//                messageLabel.textAlignment = .center
//                        messageLabel.sizeToFit()
//                messageLabel.text = "There are no contacts to add at this time, coming soon!"
//
//                self.tableView.backgroundView = messageLabel
//                self.tableView.separatorStyle = .none
//            } else {
//                self.tableView.reloadData()
//            }
//        })
        NetworkHelper.getAllUsers { (users, error) in
            print("in create dialogue controller")
            print("users are")
            print("\(users)")
            self.contacts = users
            if self.contacts.count < 1 {
                let frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: frame)
                messageLabel.textColor = UIColor.black
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                        messageLabel.sizeToFit()
                messageLabel.text = "There are no contacts to add at this time, coming soon!"

                self.tableView.backgroundView = messageLabel
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath as IndexPath) as! ContactTableViewCell
        cell.titleLabel?.text = contacts[indexPath.row].displayName
        // TODO: Added icon and contact picture
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row].userId
        if selected.contains(contact) {
            selected.removeAll{ $0 == contact }
        }
        else {
            selected.append(contacts[indexPath.row].userId)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DialogueSettingsViewController {
            vc.selectedContacts = []
            for speakerName in selected {
                vc.selectedContacts.append(SpeakerStruct.init(userID: speakerName, admin: true)) // TODO add support for not having speakers as admins
            }
        }
    }

}
