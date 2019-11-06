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


struct Speakers {
    var admin: Bool
    var userID: String
    
    init(userID: String, admin: Bool) {
        self.userID = userID
        self.admin = admin
    }
}

struct Spectators {
    var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
}

struct Group {
    var groupID: String
    var speakers: [Speakers]
    var spectators: [Spectators]
    
    init(groupID: String, speakers: [Speakers], spectators: [Spectators]) {
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

class NetworkHelper {
    static func getGroup(groupID: String) -> Group {
        var output:Group = Group(groupID: "None", speakers: [], spectators: [])
        Firestore.firestore().collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error)")
            } else {
                for document in (snapshot?.documents)! {
                    if document.documentID == groupID {
                        print("\(document.documentID) ==> \(document.data())")
                        // TODO: Confrom document data to defined structures
                        output = Group(groupID: document.documentID, speakers: [], spectators: [])
                        completion(output, nil)
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
}
