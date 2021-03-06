//
//  MyDialogueViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/22/19.
//  Copyright © 2019 CS371L. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyDialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let db = Firestore.firestore()
    private var groupListener : ListenerRegistration? = nil
    private var groups:[String] = []
    private var updated: Bool = false
    
    deinit {
        groupListener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DialogueTableViewCell.identifier, for: indexPath as IndexPath) as! DialogueTableViewCell
        cell.titleLabel?.text = groups[indexPath.row]
        // TODO: In future show preview of conversation
        cell.subLabel?.text = "Tap to see messages!"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NetworkHelper.getGroup(groupID: groups[indexPath.row]) { (group, error) in
            NetworkHelper.getUser { (user, error) in
                let vc = ChatViewController(user: user!, group: group)
                vc.nc = self.navigationController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NetworkHelper.updateCurrentInAppUser()
        
        groupListener = db.document("users/"+NetworkHelper.getCurrentUser()!.uid).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("ERROR fetching user document for group listener")
                return
            }
            self.groups = document.get("groupList") as! [String]
            self.reloadTableView()
        }
    }
    
    func reloadTableView() {
        if self.groups.count < 1 {
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            messageLabel.text = "You don't have any Dialogues yet."
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
        } else {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onProfile(_ sender: Any) {
        if let userEmail = NetworkHelper.getCurrentUserEmail() {
            Alerts.singleChoiceAlert(title: "Login Status", message: "\(userEmail) is logged in.", vc: self)
        } else {
            Alerts.singleChoiceAlert(title: "Error", message: "The user is not logged in!", vc: self)
        }
    }
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        Loading.show()
        NetworkHelper.updateCurrentInAppUser() {
            Loading.hide()
            self.performSegue(withIdentifier: "manualFromMyDialoguesToProfile", sender: nil)
        }
    }
}
