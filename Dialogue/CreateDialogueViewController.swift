//
//  CreateDialogueViewController.swift
//  Dialogue
//
//  Created by Dylan Ramage on 10/24/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateDialogueViewController: UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initTableView()
    }
    
    func initTableView() {
        let frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        let messageLabel = UILabel(frame: frame)
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        messageLabel.text = "There are no contacts to add at this time, coming soon!"
        
        contactsTableView.backgroundView = messageLabel
        contactsTableView.separatorStyle = .none
    }

}
