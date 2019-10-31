//
//  UserHandling.swift
//  Dialogue
//
//  Created by William Lemens on 10/31/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class UserHandling {
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
