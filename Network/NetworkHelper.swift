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

class NetworkHelper {
    
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
    }
    
    static func getUserFriendList(completion: @escaping () -> Void) {
        dbRef.collection("users").document(UserHandling.getCurrentUser()!.uid).getDocument { (snapshot, error) in
            if error != nil {
                print("***ERROR: \(error ?? "Couldn't print error" as! Error)")
            }
        }
    }
    
    
}
