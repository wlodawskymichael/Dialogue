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

class NetworkHelper {
    
   static func getGroup(groupID: String) -> Group {
        Firestore.firestore().collection("groups").getDocuments { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error)")
            } else {
                for document in (snapshot?.documents)! {
                    if document.documentID == groupID {
                        print("\(document.documentID) ==> \(document.data())")
                        // TODO: Confrom document data to defined structurs
                        // return Group(groupID: document.documentID, speakers: [], spectators: [])
                    }
                }
            }
        }
        return Group(groupID: "None", speakers: [], spectators: [])
    }
}
