//
//  FollowADialogueViewController.swift
//  Dialogue
//
//  Created by Dylan Ramage on 10/24/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseFirestore

class FollowADialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let db = Firestore.firestore()
    private var groups:[GroupStruct] = []
    private var followingList:[String] = []
    
    var filteredGroups: [GroupStruct]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filteredGroups = []
        
        NetworkHelper.getUserFollowingList { (following, error) in
            self.followingList = following
            self.initTableView()
        }

        // Do any additional setup after loading the view.
    }
    
    func initTableView() {
        NetworkHelper.getAllGroups { (groups, error) in
            self.groups = groups.filter { $0.followable == true }
            self.filteredGroups = self.groups
            if self.groups.count < 1 {
                let frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                let messageLabel = UILabel(frame: frame)
                messageLabel.textColor = UIColor.black
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                messageLabel.sizeToFit()
                messageLabel.text = "There are no dialogues to follow at this time, coming soon!"
                self.tableView.backgroundView = messageLabel
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowDialogueTableViewCell.identifier, for: indexPath as IndexPath) as! FollowDialogueTableViewCell
        let groupID = filteredGroups[indexPath.row].groupID
        cell.titleLabel?.text = groupID
        if followingList.contains(groupID) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        // TODO: Added icon and group picture
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var group = filteredGroups[indexPath.row]
        if !followingList.contains(group.groupID) {
            NetworkHelper.getUser(userId: NetworkHelper.getCurrentUser()!.uid, completion: { (user, error) in
                var newUser = user!
                newUser.followingList.append(group.groupID)
                NetworkHelper.writeUser(user: newUser, completion: nil)
                self.followingList = newUser.followingList
                group.spectators.append(newUser.userId)
                NetworkHelper.writeGroup(group: GroupStruct(groupID: group.groupID, speakers: group.speakers, spectators: group.spectators, followable: group.followable))
            })
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var group = filteredGroups[indexPath.row]
        if followingList.contains(group.groupID) {
            NetworkHelper.getUser(userId: NetworkHelper.getCurrentUser()!.uid, completion: { (user, error) in
                var newUser = user!
                newUser.followingList.removeAll {$0 == group.groupID}
                NetworkHelper.writeUser(user: newUser, completion: nil)
                self.followingList = newUser.followingList
                group.spectators.removeAll {$0 == newUser.userId}
                NetworkHelper.writeGroup(group: GroupStruct(groupID: group.groupID, speakers: group.speakers, spectators: group.spectators, followable: group.followable))
            })
            
        }
    }
    
    func updateSelectedStates() {
        let selectedCellDisplayNames = followingList
        for cell in tableView.visibleCells {
            let groupCell = cell as! FollowDialogueTableViewCell
            if selectedCellDisplayNames.contains(groupCell.titleLabel!.text!) {
                let indexPath = tableView.indexPath(for: cell)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        print("in search bar method")
        filteredGroups = searchText.isEmpty ? groups : groups.filter { (item: GroupStruct) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.groupID.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }

        tableView.reloadData()
        updateSelectedStates()
    }

}

