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
    
    @IBOutlet weak var dialoguesTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    var groups:[Group] = []
    
    private let db = Firestore.firestore()
    private var userSnapshotListener:ListenerRegistration?
    
    deinit {
      userSnapshotListener?.remove()
    }
    
    // TODO
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    // TODO
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DialogueTableViewCell.identifier, for: indexPath as IndexPath) as! DialogueTableViewCell
        cell.titleLabel?.text = groups[indexPath.row].groupID
        cell.subLabel?.text = "temp val"
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup listener for user data
        userSnapshotListener = db.collection("users").document(UserHandling.getCurrentUser()!.uid).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("***ERROR: Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
            document.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        groups = NetworkHelper.getMyGroups()
        print(groups)
        //TODO: Remove
        NetworkHelper.getUserFriendList { (friends, error) in
            print("\(friends)")
        }

        // Do any additional setup after loading the view.
        initTableView()
    }
    
    func initTableView() {
        if groups.count < 1 {
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            messageLabel.text = "You don't have any Dialogues yet."
            dialoguesTableView.backgroundView = messageLabel
            dialoguesTableView.separatorStyle = .none
        } else {
            print("HELLO FUCKER")
            print(groups)
            tableView.reloadData()
        }
    }

    @IBAction func onProfile(_ sender: Any) {
        if let userEmail = UserHandling.getCurrentUserEmail() {
            Alerts.singleChoiceAlert(title: "Login Status", message: "\(userEmail) is logged in.", vc: self)
        } else {
            Alerts.singleChoiceAlert(title: "Error", message: "The user is not logged in!", vc: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
