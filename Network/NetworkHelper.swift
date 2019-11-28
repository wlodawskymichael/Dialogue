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
    var followable: Bool
    
    init(groupID: String, speakers: [SpeakerStruct], spectators: [String], followable: Bool) {
        self.groupID = groupID
        self.speakers = speakers
        self.spectators = spectators
        self.followable = followable
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
    var hasProfilePicture: Bool
    var followingNotifications: Bool
    var myNotifications: Bool
    
    let userId: String
    
    init(userId: String, displayName: String, friendList: [String], groupList: [String]) {
        self.userId = userId
        self.displayName = displayName
        self.friendList = friendList
        self.groupList = groupList
        self.hasProfilePicture = false
        self.followingNotifications = true
        self.myNotifications = true
        
    }
    
    static func == (lhs: UserStruct, rhs: UserStruct) -> Bool {
        return lhs.userId == rhs.userId
    }
}

class InAppCurrentUser {
    var displayName: String
    var profilePicture: UIImage?
    var userOptions: (hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool)
    
    init(displayName: String, profilePicture: UIImage?, userOptions: (hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool)) {
        self.displayName = displayName
        self.profilePicture = profilePicture
        self.userOptions = userOptions
    }
    
    func update(displayName: String, profilePicture: UIImage?, userOptions: (hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool)) {
        self.displayName = displayName
        self.profilePicture = profilePicture
        self.userOptions = userOptions
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
    
    var content: String?
    
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "content": content ?? "*** NO CONTENT ***",
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        return rep
    }

    private init(kind: MessageKind, user: UserStruct, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(user: UserStruct, text: String) {
        self.init(kind: .text(text), user: user, messageId: UUID().uuidString, date: Date())
        content = text
    }

    init(text: String, user: UserStruct, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
        content = text
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let sentDate = (data["created"] as? Timestamp)?.dateValue() else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }

        messageId = document.documentID

        self.sentDate = sentDate
        user = UserStruct(userId: senderID, displayName: senderName, friendList: [], groupList: [])

        if let content = data["content"] as? String {
            self.content = content
            kind = .text(content)
        } else {
            return nil
        }
    }

}

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
    private static let pictureStorageRef = Storage.storage().reference(withPath: "profiles")
    public static var currentInAppUserData: InAppCurrentUser?
    
    static func getUserProfilePicture(completion: ((UIImage?, Error?) -> Void)? = nil) {
        getUserProfilePicture(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserProfilePicture(userId: String, completion: ((UIImage?, Error?) -> Void)? = nil) {
        let userImageRef = pictureStorageRef.child("\(userId).jpg")
        userImageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if completion != nil {
                if let error = error {
                    print("Error downloading profile image")
                    completion!(nil, error)
                }
                else {
                    completion!(UIImage(data: data!)!, nil)
                }
            }
        }
    }
    
    static func setProfilePicture(image: UIImage, completion: (() -> Void)? = nil) {
        setProfilePicture(image: image, userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func setProfilePicture(image: UIImage, userId: String, completion: (() -> Void)? = nil) {
        let userImageRef = pictureStorageRef.child("\(userId).jpg")
        let data = image.pngData()
        userImageRef.putData(data!, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("error in upload")
                return
            }
            self.updateCurrentInAppUser()
        }
    }
    
    static func writeGroup(group: GroupStruct, completion: (() -> Void)? = nil) {
        var speakers: [[String: Any]] = []
        for speaker in group.speakers {
            speakers.append([
                "userID": speaker.userID,
                "admin": speaker.admin
            ])
        }
        dbRef.collection("groups").document(group.groupID).setData([
            "speakers": speakers,
            "spectators": group.spectators,
            "followable": group.followable
        ]) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                if completion != nil  {
                    completion!()
                }
            }
        }
    }
    
    static func writeUser(user: UserStruct, completion: (() -> Void)? = nil) {
        dbRef.collection("users").document(user.userId).setData([
            "displayName": user.displayName,
            "friendList": user.friendList,
            "groupList": user.groupList,
            "hasProfilePicture": user.hasProfilePicture,
            "followingNotifications": user.followingNotifications,
            "myNotifications": user.myNotifications
        ]) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                if completion != nil {
                    completion!()
                }
            }
        }
    }
    
    static func getGroup(groupID: String, completion: ((GroupStruct, Error?) -> Void)? = nil) {
        var group = GroupStruct(groupID: "None", speakers: [], spectators: [], followable: false)
        self.dbRef.collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                for document in snapshot!.documents {
                    if document.documentID == groupID {
                        // Conform group to Group struct
                        var speakers: [SpeakerStruct] = []
                        var spectators: [String] = []
                        
                        let followable = document["followable"] as? Bool ?? false
                        
                        let speakerData = document["speakers"] as? [NSDictionary]
                        for speaker in speakerData ?? [] {
                            let admin: Bool = speaker["admin"] as? Bool ?? false
                            let userID: String = speaker["userID"] as? String ?? "None"
                            speakers.append(SpeakerStruct(userID: userID, admin: admin))
                        }
                        spectators = document["spectators"] as? [String] ?? []
                        
                        group = GroupStruct(groupID: document.documentID, speakers: speakers, spectators: spectators, followable: followable)
                        
                        // Call completion handler
                        if completion != nil {
                            completion!(group, nil)
                        }
                    }
                }
            }
        }
    }
    
    static func getUser(completion: ((UserStruct, Error?) -> Void)? = nil) {
        getUser(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUser(userId: String, completion: ((UserStruct, Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let displayName: String = snapshot?.get("displayName") as? String ?? userId
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                if completion != nil {
                    completion!(UserStruct(userId: userId, displayName: displayName, friendList: friends, groupList: groups), nil)
                }
            }
        }
    }
    
    static func getAllUsers(completion: (([UserStruct], Error?) -> Void)? = nil) {
        dbRef.collection("users").getDocuments { (snapshot, error) in
            if error != nil {
               print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
           } else {
                var usersToDisplay: [UserStruct] = []
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    if document.get("displayName") != nil {
                        let displayName: String = (document.get("displayName") as? String)!
                        let friends: [String] = document.get("friendList") as? [String] ?? []
                        let groups: [String] = document.get("groupList") as? [String] ?? []
                        let userId: String = document.documentID
                        usersToDisplay.append(UserStruct(userId: userId, displayName: displayName, friendList: friends, groupList: groups))
                    }
                }
                completion!(usersToDisplay, nil)
           }
       }
    }
    
    static func getUserFriendList(completion: (([String], Error?) -> Void)? = nil) {
        getUserFriendList(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserFriendList(userId: String, completion: (([String], Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let friends: [String] = snapshot?.get("friendList") as? [String] ?? []
                if completion != nil {
                    completion!(friends, nil)
                }
            }
        }
    }
    
    static func getUserGroupList(completion: (([String], Error?) -> Void)? = nil) {
        getUserGroupList(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserGroupList(userId: String, completion: (([String], Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                if completion != nil {
                    completion!(groups, nil)
                }
            }
        }
    }
    
    static func getUserDisplayName(completion: ((String, Error?) -> Void)? = nil) {
        getUserDisplayName(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserDisplayName(userId: String, completion: ((String, Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let displayName: String = snapshot?.get("displayName") as? String ?? ""
                if completion != nil {
                    completion!(displayName, nil)
                }
            }
        }
    }
    
    static func getUserOptions(completion: (((hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool), Error?) -> Void)? = nil) {
        getUserOptions(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserOptions(userId: String, completion: (((hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool), Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let profPic: Bool = snapshot?.get("hasProfilePicture") as? Bool ?? false
                let followNotifs: Bool = snapshot?.get("followingNotifications") as? Bool ?? false
                let myNotifs: Bool = snapshot?.get("myNotifications") as? Bool ?? false
                let userOptions = (hasProfilePicture: profPic, followingNotifications: followNotifs, myNotifications: myNotifs)
                if completion != nil {
                    completion!(userOptions, nil)
                }
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
    
    static func updateCurrentInAppUser() {
        if getCurrentUser() != nil {
            var displayName: String?
            var userOptions: (hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool)?
            var profilePicture: UIImage?
            getUserDisplayName() { fetchedName, error in
                displayName = fetchedName
                getUserOptions() { fetchedOptions, error in
                    userOptions = fetchedOptions
                    if userOptions!.hasProfilePicture {
                        getUserProfilePicture() { fetchedImage, error in
                            profilePicture = fetchedImage
                            self.currentInAppUserData = InAppCurrentUser(displayName: displayName!, profilePicture: profilePicture, userOptions: userOptions!)
                        }
                    }
                }
            }
        }
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
