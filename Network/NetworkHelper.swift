//
//  NetworkHelper.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/5/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import MessageKit

// MARK: - SpeakerStruct
struct SpeakerStruct {
    var admin: Bool
    var userID: String
    
    init(userID: String, admin: Bool) {
        self.userID = userID
        self.admin = admin
    }
}

// MARK: - GroupStruct
struct GroupStruct {
    var groupID: String
    var speakers: [SpeakerStruct]
    var spectators: [String]
    
    init(groupID: String, speakers: [SpeakerStruct], spectators: [String]) {
        self.groupID = groupID
        self.speakers = speakers
        self.spectators = spectators
    }
}

// MARK: - UserStruct
struct UserStruct: SenderType, Equatable {
    var senderId: String {
        return userId
    }
    var displayName: String
    var friendList: [String]
    var groupList: [String]
    
    let userId: String
    
    init(userId: String, displayName: String, friendList: [String], groupList: [String]) {
        self.userId = userId
        self.displayName = displayName
        self.friendList = friendList
        self.groupList = groupList
    }
}

// MARK: - Message
struct Message: MessageType {
    
    var sender: SenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind
    var messageId: String
    let user: UserStruct

    private init(kind: MessageKind, user: UserStruct, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(user: UserStruct, text: String) {
        self.init(kind: .text(text), user: user, messageId: UUID().uuidString, date: Date())
    }

    init(text: String, user: UserStruct, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
//
//    init?(document: QueryDocumentSnapshot) {
//        let data = document.data()
//
//        guard let sentDate = data["created"] as? Date else {
//            return nil
//        }
//        guard let senderID = data["senderID"] as? String else {
//            return nil
//        }
//        guard let senderName = data["senderName"] as? String else {
//            return nil
//        }
//
//        id = document.documentID
//
//        self.sentDate = sentDate
//        sender = Sender(id: senderID, displayName: senderName)
//
//        if let content = data["content"] as? String {
//            self.content = content
//            kind = MessageKind.text(content)
//        } else {
//            return nil
//        }
//    }
//
}

//extension Message: DatabaseRepresentation {
//
//    var representation: [String : Any] {
//        let rep: [String : Any] = [
//            "content": content,
//            "created": sentDate,
//            "senderID": sender.senderId,
//            "senderName": sender.displayName
//        ]
//
//        //    if let url = downloadURL {
//        //      rep["url"] = url.absoluteString
//        //    } else {
//        //      rep["content"] = content
//        //    }
//        //
//        return rep
//    }
//}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}

// MARK: - NetworkHelper
class NetworkHelper {
    
    private static let dbRef = Firestore.firestore()
    
    static func writeGroup(group: GroupStruct, completion: @escaping () -> Void) {
        var speakers: [[String: Any]] = []
        for speaker in group.speakers {
            speakers.append([
                "userID": speaker.userID,
                "admin": speaker.admin
            ])
        }
        dbRef.collection("groups").document(group.groupID).setData([
            "speakers": speakers,
            "spectators": group.spectators
        ]) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                completion()
            }
        }
    }
    
    static func writeUser(user: UserStruct, completion:  @escaping () -> Void) {
        dbRef.collection("users").document(getCurrentUser()!.uid).setData([
            "displayName": user.displayName,
            "friendList": user.friendList,
            "groupList": user.groupList
        ]) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                completion()
            }
        }
    }
    
    static func getGroup(groupID: String, completion:  @escaping (GroupStruct, Error?) -> Void) {
        var group = GroupStruct(groupID: "None", speakers: [], spectators: [])
        self.dbRef.collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                for document in snapshot!.documents {
                    if document.documentID == groupID {
                        // Conform group to Group struct
                        var speakers: [SpeakerStruct] = []
                        var spectators: [String] = []
                        
                        let speakerData = document["speakers"] as? [NSDictionary]
                        for speaker in speakerData ?? [] {
                            let admin: Bool = speaker["admin"] as? Bool ?? false
                            let userID: String = speaker["userID"] as? String ?? "None"
                            speakers.append(SpeakerStruct(userID: userID, admin: admin))
                        }
                        spectators = document["spectators"] as? [String] ?? []
                        
                        group = GroupStruct(groupID: document.documentID, speakers: speakers, spectators: spectators)
                        
                        // Call completion handler
                        completion(group, nil)
                    }
                }
            }
        }
    }
    
    static func getUser(completion: @escaping (UserStruct, Error?) -> Void) {
        dbRef.collection("users").document(getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let userId: String = getCurrentUser()!.uid
                let displayName: String = snapshot?.get("displayName") as? String ?? userId
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                completion(UserStruct(userId: userId, displayName: displayName, friendList: friends, groupList: groups), nil)
            }
        }
    }
    
    static func getUserFriendList(completion: @escaping ([String], Error?) -> Void) {
        dbRef.collection("users").document(getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                completion(friends, nil)
            }
        }
    }
    
    static func getUserGroupList(completion: @escaping ([String], Error?) -> Void) {
        dbRef.collection("users").document(getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                completion(groups, nil)
            }
        }
    }
    
    static func getUserDisplayName(completion: @escaping (String, Error?) -> Void) {
        dbRef.collection("users").document(getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let displayName: String = snapshot?.get("displayName") as? String ?? ""
                completion(displayName, nil)
            }
        }
    }
    
    static func getCurrentUser() -> User? {
        var out = Auth.auth().currentUser
        if out == nil {
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    out = user
                }
            }
        }
        return out
    }
    
    static func isUserSignedIn() -> Bool {
        if getCurrentUser() != nil {
            return true
        }
        return false
    }
    
    static func getCurrentUserEmail() -> String? {
        if let currentUser = getCurrentUser() {
            return currentUser.email
        }
        return nil
    }
    
    static func attemptLogin(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
