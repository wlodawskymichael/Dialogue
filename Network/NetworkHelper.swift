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


struct SpeakerStruct {
    var admin: Bool
    var userID: String
    
    init(userID: String, admin: Bool) {
        self.userID = userID
        self.admin = admin
    }
}

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

// TODO
struct Message: MessageType {
    
    let id: String?
    let content: String
    let sentDate: Date
    let sender: SenderType
    let kind: MessageKind
    
    //    var data: StringMessageData {
    //    if let image = image {
    //      return .photo(image)
    //    } else {
    //      return .text(content)
    //    }
    //  }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    //  var image: UIImage? = nil
    //  var downloadURL: URL? = nil
    
    init(user: User, content: String) {
        sender = Sender(id: user.uid, displayName: user.uid /*AppSettings.displayName*/)
        self.content = content
        sentDate = Date()
        id = nil
        kind = MessageKind.text(content)
    }
    
    //  init(user: User, image: UIImage) {
    //    sender = Sender(id: user.uid, displayName: AppSettings.displayName)
    //    self.image = image
    //    content = ""
    //    sentDate = Date()
    //    id = nil
    //  }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["created"] as? Date else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate
        sender = Sender(id: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            kind = MessageKind.text(content)
            //      downloadURL = nil
            //    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            //      downloadURL = url
            //      content = ""
        } else {
            return nil
        }
    }
    
}

//extension Message: DatabaseRepresentation {
//
//  var representation: [String : Any] {
//    var rep: [String : Any] = [
//      "created": sentDate,
//      "senderID": sender.id,
//      "senderName": sender.displayName
//    ]
//
//    if let url = downloadURL {
//      rep["url"] = url.absoluteString
//    } else {
//      rep["content"] = content
//    }
//
//    return rep
//  }
//
//}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}


struct UserStruct {
    var displayName: String
    var friendList: [String]
    var groupList: [String]
    
    init(displayName: String, friendList: [String], groupList: [String]) {
        self.displayName = displayName
        self.friendList = friendList
        self.groupList = groupList
    }
}

class NetworkHelper {
    
    private static let dbRef = Firestore.firestore()
    
    static func writeGroup(group: GroupStruct) {
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
            }
        }
    }
    
    static func writeUser(user: UserStruct) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).setData([
            "displayName": user.displayName,
            "friendList": user.friendList,
            "groupList": user.groupList
        ]) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
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
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                let displayName: String = snapshot?.get("displayName") as? String ?? ""
                completion(UserStruct(displayName: displayName, friendList: friends, groupList: groups), nil)
            }
        }
    }
    
    static func getUserFriendList(completion: @escaping ([String], Error?) -> Void) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                completion(friends, nil)
            }
        }
    }
    
    static func getUserGroupList(completion: @escaping ([String], Error?) -> Void) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                completion(groups, nil)
            }
        }
    }
    
    static func getUserDisplayName(completion: @escaping (String, Error?) -> Void) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let displayName: String = snapshot?.get("displayName") as? String ?? ""
                completion(displayName, nil)
            }
        }
    }
    
    
}
