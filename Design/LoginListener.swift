//
//  LoginListener.swift
//  Dialogue
//
//  Created by William Lemens on 10/21/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth


class LoginListener {
    static func isUserSignedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    static func attemptLogin(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}
