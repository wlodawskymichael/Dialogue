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
    
//    private let db = Firestore.firestore()
//    private var reference: CollectionReference?
//
//    private var messages: [Message] = []
//    private var messageListener: ListenerRegistration?
//
//    private let user: User
//    private let group: GroupStruct
//
//    deinit {
//      messageListener?.remove()
//    }
//
//    init(user: User, group: GroupStruct) {
//      self.user = user
//      self.group = group
//      super.init(nibName: nil, bundle: nil)
//
//      title = group.groupID
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//
//        reference = db.collection(["groups", group.groupID, "thread"].joined(separator: "/"))
//
//        messageListener = reference?.addSnapshotListener { querySnapshot, error in
//          guard let snapshot = querySnapshot else {
//            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
//            return
//          }
//
//          snapshot.documentChanges.forEach { change in
//            self.handleDocumentChange(change)
//          }
//        }
//
//        navigationItem.largeTitleDisplayMode = .never
//
//        maintainPositionOnKeyboardFrameChanged = true
//        messageInputBar.inputTextView.tintColor = .primary
//        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
//
//        messageInputBar.delegate = self
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//
//        let cameraItem = InputBarButtonItem(type: .system) // 1
//        cameraItem.tintColor = .primary
//        cameraItem.image = #imageLiteral(resourceName: "camera")
//        cameraItem.addTarget(
//          self,
//          action: #selector(cameraButtonPressed), // 2
//          for: .primaryActionTriggered
//        )
//        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
//
//        messageInputBar.leftStackView.alignment = .center
//        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
//        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
//    }
//
//    private func handleDocumentChange(_ change: DocumentChange) {
//      guard var message = Message(document: change.document) else {
//        return
//      }
//
//      switch change.type {
//      case .added:
////        if let url = message.downloadURL {
////          downloadImage(at: url) { [weak self] image in
////            guard let `self` = self else {
////              return
////            }
////            guard let image = image else {
////              return
////            }
////
////            message.image = image
////            self.insertNewMessage(message)
////          }
////        } else {
//          insertNewMessage(message)
////        }
//
//      default:
//        break
//      }
//    }
//
//    private func insertNewMessage(_ message: Message) {
//      guard !messages.contains(message) else {
//        return
//      }
//
//      messages.append(message)
//      messages.sort()
//
//      let isLatestMessage = messages.index(of: message) == (messages.count - 1)
//      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
//
//      messagesCollectionView.reloadData()
//
//      if shouldScrollToBottom {
//        DispatchQueue.main.async {
//          self.messagesCollectionView.scrollToBottom(animated: true)
//        }
//      }
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
