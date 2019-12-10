//
//  AddMembersViewController.swift
//  
//
//  Created by William Lemens on 12/9/19.
//

import UIKit
import Firebase

class AddMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var searchBar = UISearchBar()
    private var tableView = UITableView()
    private let db = Firestore.firestore()
    private var contacts:[UserStruct] = []
    private var selected:[UserStruct] = []
    
    var delegate:DialogueSettingsViewController!
    
    var filteredUsers: [UserStruct]!
    
    var userId:String = ""
    var groupId:String = ""
    var followable: Bool = true
    
    override func viewWillDisappear(_ animated: Bool) {
        var speakers:[SpeakerStruct] = []
        for user in self.selected {
            speakers.append(SpeakerStruct(userId: user.userId, admin: true))
        }
        delegate.addContacts = speakers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.identifier)
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        filteredUsers = []
        
        setUpUI()
        initTableView()
    }
    
    func setUpUI() {
        let margins = view.layoutMarginsGuide
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: guide.topAnchor, constant: 5),
            searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -5),
            
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        tableView.rowHeight = CGFloat(70)
        
    }
    
    func initTableView() {
        NetworkHelper.getAllUsers { (users, error) in
            self.contacts = users
            self.filteredUsers = self.contacts
            if self.contacts.count < 1 {
                let frame = CGRect(origin: CGPoint(x: 0, y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
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
    
    func setVariables(groupId:String, followable:Bool, userId:String) {
        self.groupId = groupId
        self.followable = followable
        self.userId = userId
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath as IndexPath) as! ContactTableViewCell
        cell.titleLabel.text = filteredUsers[indexPath.row].displayName
        NetworkHelper.getUserProfilePicture(userId: filteredUsers[indexPath.row].userId) { image, error in
            if image != nil {
                cell.profilePicture.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = filteredUsers[indexPath.row]
        if !selected.contains(contact) {
            selected.append(filteredUsers[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let contact = filteredUsers[indexPath.row]
        if selected.contains(contact) {
            selected.removeAll {$0 == contact}
        }
    }
    
    func updateSelectedStates() {
        let selectedCellDisplayNames = selected.map {$0.displayName}
        for cell in tableView.visibleCells {
            let contactCell = cell as! ContactTableViewCell
            if selectedCellDisplayNames.contains(contactCell.titleLabel.text!) {
                let indexPath = tableView.indexPath(for: cell)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredUsers = searchText.isEmpty ? contacts : contacts.filter { (item: UserStruct) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return item.displayName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
        updateSelectedStates()
    }
    
}
