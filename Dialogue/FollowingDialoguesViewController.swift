//
//  FollowingDialoguesViewController.swift
//  Dialogue
//
//  Created by Sahil Parikh on 10/23/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FollowingDialoguesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let db = Firestore.firestore()
    private var userSnapshotListener:ListenerRegistration?
    private var following:[String] = []
    private var updated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        initTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initTableView()
    }
    
    func initTableView() {
        NetworkHelper.updateCurrentInAppUser()
        NetworkHelper.getUser(completion: { (user, error) in
            self.following = user!.followingList
            self.tableView.reloadData()
            if self.following.count < 1 {
                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: rect)
                messageLabel.textColor = UIColor.black
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                messageLabel.sizeToFit()
                messageLabel.text = "You aren't following any Dialogues yet."
                
                self.tableView.backgroundView = messageLabel
                self.tableView.separatorStyle = .none
            }
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DialogueTableViewCell.identifier, for: indexPath as IndexPath) as! DialogueTableViewCell
        
        cell.titleLabel?.text = following[indexPath.row]
        cell.subLabel?.text = "Tap to see messages!"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NetworkHelper.getGroup(groupID: following[indexPath.row]) { (group, error) in
            NetworkHelper.getUser { (user, error) in
                let vc = ChatViewController(user: user!, group: group)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        if let userEmail = NetworkHelper.getCurrentUserEmail() {
            Alerts.singleChoiceAlert(title: "Login Status", message: "\(userEmail) is logged in.", vc: self)
        } else {
            Alerts.singleChoiceAlert(title: "Error", message: "The user is not logged in!", vc: self)
        }
    }
    
}
