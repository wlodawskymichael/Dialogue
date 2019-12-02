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

class CreateDialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let db = Firestore.firestore()
    private var contacts:[UserStruct] = []
    private var selected:[UserStruct] = []
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    var filteredUsers: [UserStruct]!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filteredUsers = []
        nextBarButton.isEnabled = false
        // Do any additional setup after loading the view.
        initTableView()
    }

    func initTableView() {
        NetworkHelper.getAllUsers { (users, error) in
            self.contacts = users
            self.filteredUsers = self.contacts
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
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath as IndexPath) as! ContactTableViewCell
        cell.titleLabel?.text = filteredUsers[indexPath.row].displayName
        NetworkHelper.getUserProfilePicture(userId: filteredUsers[indexPath.row].userId) { image, error in
            if image != nil {
                cell.profilePicture.image = image
            }
        }
        // TODO: Added icon and contact picture
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = filteredUsers[indexPath.row]
        if !selected.contains(contact) {
            selected.append(filteredUsers[indexPath.row])
        }
        nextBarButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contact = filteredUsers[indexPath.row]
        if selected.contains(contact) {
            selected.removeAll {$0 == contact}
        }
        if selected.isEmpty {
            nextBarButton.isEnabled = false
        }
    }
    
    func updateSelectedStates() {
        let selectedCellDisplayNames = selected.map {$0.displayName}
        for cell in tableView.visibleCells {
            let contactCell = cell as! ContactTableViewCell
            if selectedCellDisplayNames.contains(contactCell.titleLabel!.text!) {
                let indexPath = tableView.indexPath(for: cell)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(selected)
        if let vc = segue.destination as? DialogueCreationViewController {
            var speakers:[SpeakerStruct] = []
            for user in self.selected {
                speakers.append(SpeakerStruct(userId: user.userId, admin: true))
            }
            vc.selectedContacts = speakers
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredUsers = searchText.isEmpty ? contacts : contacts.filter { (item: UserStruct) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.displayName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }

        tableView.reloadData()
        updateSelectedStates()
    }

}
