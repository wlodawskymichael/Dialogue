//
//  NetworkHelper.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 11/5/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MessageKit

// MARK: - SpeakerStruct
struct SpeakerStruct {
    var admin: Bool
    var userId: String
    
    init(userId: String, admin: Bool) {
        self.userId = userId
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
    var groupList: [String]
    var hasProfilePicture: Bool
    var followingNotifications: Bool
    var myNotifications: Bool
    var followingList: [String]
    
    let userId: String
    
    init(userId: String, displayName: String, groupList: [String], followList: [String]) {
        self.userId = userId
        self.displayName = displayName
        self.groupList = groupList
        self.hasProfilePicture = false
        self.followingNotifications = true
        self.myNotifications = true
        
        self.followingList = followList
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
        user = UserStruct(userId: senderID, displayName: senderName, groupList: [], followList: [])

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
    private static var listeners: [(ref: CollectionReference?, listener: ListenerRegistration?)] = []
    private static var notificationRecord: [String:Int] = [:]
    
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
            NetworkHelper.setNewUserOption((field: "hasProfilePicture", value: true)) {
                self.updateCurrentInAppUser()
            }

            if completion != nil {
                completion!()
            }
        }
    }
    
    static func setNewUserOption(_ newOption: (field: String, value: Bool), completion: (() -> Void)? = nil) {
        setNewUserOption(userId: getCurrentUser()!.uid, newOption, completion: completion)
    }
    
    static func setNewUserOption(userId: String, _ newOption: (field: String, value: Bool), completion: (() -> Void)? = nil) {
        dbRef.collection("users").document(userId).setData([
            newOption.field: newOption.value
        ], merge: true) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                self.updateCurrentInAppUser()
                if completion != nil {
                    completion!()
                }
            }
        }
    }
    
//    static func fillNotificationRecord() {
//        let reference = dbRef.collection(["groups", "group", "thread"].joined(separator: "/"))
//        reference.get
//    }
    
    static func startNotificationMonitor() {
        var groupIds: [String]!
        getUserGroupList() { groups, error in
            groupIds = groups
            for group in groupIds {
                let reference = dbRef.collection(["groups", group, "thread"].joined(separator: "/"))
                let messageListener = reference.addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    
                    var messages: [Message] = []
                    snapshot.documentChanges.forEach { change in
                        messages.append(Message(document: change.document)!)
                    }
                    
                    if self.notificationRecord[group] == nil {
                        self.notificationRecord[group] = messages.count
                    }
                    
                    if messages.count > self.notificationRecord[group] ?? messages.count {
                        let sortedMessages = messages.sorted()
                        notificationRecord[group] = messages.count
                        print(notificationRecord)
                        if sortedMessages.last?.sender.senderId != getCurrentUser()?.uid {
                            self.handleDocumentChange(groupName: group, message: sortedMessages.last!)
                        }
                    }
                }
                self.listeners.append((ref: reference, listener: messageListener))
            }
        }
    }
    
    static func endNotificationMonitor() {
        for groupListener in self.listeners {
            groupListener.listener?.remove()
        }
    }
        
    static func handleDocumentChange(groupName: String, message: Message) {
        let senderName = message.sender.displayName
        let content = message.content
        let notification = UNMutableNotificationContent()
        notification.title = "New message in \(groupName)"
        notification.body = "\(senderName): \(content ?? "")"
        // set up the notification to trigger after a delay of "seconds"
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // set up a request to tell iOS to submit the notification with that trigger
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: notificationTrigger)
        
        // submit the request to iOS
        UNUserNotificationCenter.current().add(request) { (error) in
            print("Request error: ",error as Any)
        }
    }
    
    static func writeGroup(group: GroupStruct, completion: (() -> Void)? = nil) {
        var speakers: [[String: Any]] = []
        for speaker in group.speakers {
            speakers.append([
                "userID": speaker.userId,
                "admin": speaker.admin
            ])
        }
        let docRef = dbRef.collection("groups").document(group.groupID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                dbRef.collection("groups").document(group.groupID).updateData([
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
            else {
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
        }
    }
    
    static func writeUser(user: UserStruct, completion: (() -> Void)? = nil) {
        let docRef = dbRef.collection("users").document(user.userId)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Doc exists "+user.userId)
                dbRef.collection("users").document(user.userId).updateData([
                    "displayName": user.displayName,
                    "groupList": user.groupList,
                    "hasProfilePicture": user.hasProfilePicture,
                    "followingNotifications": user.followingNotifications,
                    "myNotifications": user.myNotifications,
                    "followingList": user.followingList
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
            else {
                print("Doc DNE, creation "+user.userId)
                print(user.displayName)
                dbRef.collection("users").document(user.userId).setData([
                    "displayName": user.displayName,
                    "groupList": user.groupList,
                    "hasProfilePicture": user.hasProfilePicture,
                    "followingNotifications": user.followingNotifications,
                    "myNotifications": user.myNotifications,
                    "followingList": user.followingList
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
        }
    }
    
//    static func changeUserAdminStatus(groupID: String, speakers: [SpeakerStruct], userID: String, newStatus: Bool, completion: (() -> Void)? = nil) {
//        for var speaker in speakers {
//            if speaker.userID == userID {
//                speaker.admin = newStatus
//            }
//        }
//        
//        dbRef.collection("groups").document(groupID).setData([
//            "speakers": speakers
//        ], merge: true) { (error) in
//            if error != nil {
//                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
//            } else {
//                if completion != nil {
//                    completion!()
//                }
//            }
//        }
//    }
    
    static func changeUserDisplayName(newDisplayName: String, completion: (() -> Void)? = nil) {
        changeUserDisplayName(userId: getCurrentUser()!.uid, newDisplayName: newDisplayName, completion: completion)
    }
    
    static func changeUserDisplayName(userId: String, newDisplayName: String, completion: (() -> Void)? = nil) {
        dbRef.collection("users").document(userId).setData([
            "displayName": newDisplayName
        ], merge: true) { (error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                if completion != nil {
                    completion!()
                }
                updateCurrentInAppUser()
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
                            speakers.append(SpeakerStruct(userId: userID, admin: admin))
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
    
    static func getAllGroups(completion: (([GroupStruct], Error?) -> Void)? = nil) {
        dbRef.collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
               print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
           } else {
                var groupsToDisplay: [GroupStruct] = []
                for document in snapshot!.documents {
                    let groupId: String = document.documentID
                    var speakers: [SpeakerStruct] = []
                    let speakerData = document["speakers"] as? [NSDictionary]
                    for speaker in speakerData ?? [] {
                        let admin: Bool = speaker["admin"] as? Bool ?? false
                        let userID: String = speaker["userID"] as? String ?? "None"
                        speakers.append(SpeakerStruct(userId: userID, admin: admin))
                    }
                    let spectators: [String] = document.get("spectators") as? [String] ?? []
                    let followable: Bool = document.get("followable") as? Bool ?? false
                    groupsToDisplay.append(GroupStruct(groupID: groupId, speakers: speakers, spectators: spectators, followable: followable))
                }
                completion!(groupsToDisplay, nil)
           }
       }
    }
    
    static func userWritten(userID: String, completion: ((Bool, Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userID).getDocument { (snapshot, error) in
            if snapshot?.exists ?? false {
                if completion != nil {
                    completion!(true, nil)
                }
            } else {
                if completion != nil {
                    completion!(false, nil)
                }
            }
        }
    }

    static func getUser(completion: ((UserStruct?, Error?) -> Void)? = nil) {
        getUser(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUser(userId: String, completion: ((UserStruct?, Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                if !(snapshot?.exists ?? false) && completion != nil {
                    let error_str:[String: Any] = ["User not in database":userId]
                    completion!(nil, NSError.init(domain: "", code: 401, userInfo: error_str))
                } else {
                    let displayName: String = snapshot?.get("displayName") as? String ?? userId
                    let groups: [String] = snapshot?.get("groupList") as? [String] ?? []
                    let following: [String] = snapshot?.get("followingList") as? [String] ?? []
                    if completion != nil {
                        completion!(UserStruct(userId: userId, displayName: displayName, groupList: groups, followList: following), nil)
                    }
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
                    if document.get("displayName") != nil {
                        let displayName: String = (document.get("displayName") as? String)!
                        let groups: [String] = document.get("groupList") as? [String] ?? []
                        let following: [String] = document.get("followingList") as? [String] ?? []
                        let userId: String = document.documentID
                        if userId != getCurrentUser()?.uid {
                            usersToDisplay.append(UserStruct(userId: userId, displayName: displayName, groupList: groups, followList: following))
                        }
                    }
                }
                completion!(usersToDisplay, nil)
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
    
    static func getUserFollowingList(completion: (([String], Error?) -> Void)? = nil) {
        getUserFollowingList(userId: getCurrentUser()!.uid, completion: completion)
    }
    
    static func getUserFollowingList(userId: String, completion: (([String], Error?) -> Void)? = nil) {
        dbRef.collection("users").document(userId).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                let following: [String] = snapshot?.get("followingList") as? [String] ?? []
                if completion != nil {
                    completion!(following, nil)
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
    
    static func updateCurrentInAppUser(completion: (() -> Void)? = nil) {
        if getCurrentUser() != nil {
            var displayName: String?
            var userOptions: (hasProfilePicture: Bool, followingNotifications: Bool, myNotifications: Bool)?
            var profilePicture: UIImage?
            getUserDisplayName() { fetchedName, error in
                print("got display name")
                displayName = fetchedName
                getUserOptions() { fetchedOptions, error in
                    print("got user options")
                    userOptions = fetchedOptions
                    if userOptions!.hasProfilePicture {
                        getUserProfilePicture() { fetchedImage, error in
                            print("fetched image")
                            profilePicture = fetchedImage
                            self.currentInAppUserData = InAppCurrentUser(displayName: displayName!, profilePicture: profilePicture, userOptions: userOptions!)
                            if completion != nil {
                                print("about to do completion")
                                completion!()
                            }
                        }
                    } else {
                        self.currentInAppUserData = InAppCurrentUser(displayName: displayName!, profilePicture: nil, userOptions: userOptions!)
                        if completion != nil {
                            print("about to do completion")
                            completion!()
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
