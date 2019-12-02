//
//  ChatViewController.swift
//  Dialogue
//
//  Created by William Lemens on 11/5/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var messageList: [Message] = []
    let user: UserStruct
    let group: GroupStruct
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private var messageListener: ListenerRegistration?
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    init(user: UserStruct, group: GroupStruct) {
        self.user = user
        self.group = group
        super.init(nibName: nil, bundle: nil)
        title = group.groupID
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup messages listener
        reference = db.collection(["groups", group.groupID, "thread"].joined(separator: "/"))
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        // Setup MessageView stuff
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        var contains:Bool = false
        for speaker in group.speakers {
            if speaker.userID == user.userId {
                contains = true
            }
        }
        
        if contains {
            messageInputBar.delegate = self
            messageInputBar.inputTextView.tintColor = .primaryColor
            messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
            messageInputBar.sendButton.setTitleColor(
                UIColor.primaryColor.withAlphaComponent(0.3),
                for: .highlighted
            )
        } else {
            messageInputBar.isHidden = true
        }
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
        messageList.append(message)
        messageList.sort()
        messagesCollectionView.reloadData()
        
        if !isLastSectionVisible() {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return user
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    // Handles messages being sent from the input bar by saving them remotely
    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                let message = Message(text: str, user: user, messageId: UUID().uuidString, date: Date())
                save(message)
            }
        }
    }
    
    // Handles new messages popping up remotely and loads them on screen
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            insertMessage(message)
            
        default:
            break
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : .incomingMessage
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: - UIColor Extension
extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    static let incomingMessage = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
}
