//
//  ChatViewController.swift
//  Dialogue
//
//  Created by William Lemens on 11/5/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore

class ChatViewController: MessagesViewController {
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    private let user: User
    private let group: Group

    deinit {
      messageListener?.remove()
    }
    
    init(user: User, group: Group) {
      self.user = user
      self.group = group
      super.init(nibName: nil, bundle: nil)
      
      title = group.groupID
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
