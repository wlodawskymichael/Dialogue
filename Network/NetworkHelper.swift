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


struct Speaker {
    var admin: Bool
    var userID: String
    
    init(userID: String, admin: Bool) {
        self.userID = userID
        self.admin = admin
    }
}

struct Group {
    var groupID: String
    var speakers: [Speaker]
    var spectators: [String]
    
    init(groupID: String, speakers: [Speaker], spectators: [String]) {
        self.groupID = groupID
        self.speakers = speakers
        self.spectators = spectators
    }
}

// TODO
struct Message: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date

    var kind: MessageKind
}

    private static let dbRef = Firestore.firestore()
    
    static func getGroup(groupID: String, completion:  @escaping (Group, Error?) -> Void) {
        var group = Group(groupID: "None", speakers: [], spectators: [])
        self.dbRef.collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            } else {
                for document in snapshot!.documents {
                    if document.documentID == groupID {
                        // Conform group to Group struct
                        var speakers: [Speaker] = []
                        var spectators: [String] = []
                        
                        let speakerData = document["speakers"] as? [NSDictionary]
                        for speaker in speakerData ?? [] {
                            let admin: Bool = speaker["admin"] as? Bool ?? false
                            let userID: String = speaker["userID"] as? String ?? "None"
                            speakers.append(Speaker(userID: userID, admin: admin))
                        }
                        spectators = document["spectators"] as? [String] ?? []
                        
                        group = Group(groupID: document.documentID, speakers: speakers, spectators: spectators)
                        
                        // Call completion handler
                        completion(group, nil)
                    }
                }
            }
        }
        return output
    }
    
    static func getMyGroups() -> [Group] {
        var output:[Group] = []
//        Firestore.firestore().collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
//            if error != nil {
//                print("***ERROR: \(error)")
//            } else {
//                let groupIDs:[String] = snapshot?.get("groupList") as! [String]
//                for group in groupIDs {
//                    output.append(getGroup(groupID: group))
//                }
//            }
//        }
        Firestore.firestore().collection("users").document("userID").collection("groupList").document().getDocument { (snapshot, error) in
            print(snapshot?.data())
        }
        return output
    }
    
    static func getUserFriendList(completion: @escaping () -> Void) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            }
        }
    }
    
    
}
