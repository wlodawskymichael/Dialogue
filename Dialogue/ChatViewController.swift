//
//  ChatViewController.swift
//  Dialogue
//
//  Created by William Lemens on 11/5/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource {
    
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
        
        reference = db.collection(["groups", group.groupID, "thread"].joined(separator: "/"))
        print("\n\nREF:\n")
        print(reference)
        print("\nEND\n\n")
        
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
//        print(messageList)
        messageList.append(message)
//        print(messageList)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
//        print(messageList)
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
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        print("Play button tapped")
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let message = Message(user: user, text: text)
        
        save(message)
        
        inputBar.inputTextView.text = ""
    }
    
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                let message = Message(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }/* else if let img = component as? UIImage {
             let message = Message(image: img, user: user, messageId: UUID().uuidString, date: Date())
             insertMessage(message)
             }*/
        }
    }
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            print("returning")
            return
        }
        print("here")
        switch change.type {
        case .added:
            print("added")
            insertMessage(message)
            
        default:
            print("default doc changef")
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
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

// MARK: - UIColor Extension
extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    static let incomingMessage = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
}
