//
//  SigninViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/17/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth

class SigninViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    @IBAction func onSignin(_ sender: Any) {
        let vc = self
        if !(EmailTextField.text?.isEmpty ?? true || PasswordTextField.text?.isEmpty ?? true) {
            Auth.auth().signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (result, error) in
                if error != nil {
                    Alerts.singleChoiceAlert(title: "Error", message: "Email or Password was invalid.", vc: vc)
                } else {
                    vc.performSegue(withIdentifier: "signinToDialogue", sender: nil)
                }
                
            }
        } else {
            Alerts.singleChoiceAlert(title: "Error", message: "Email or Password field is empty.", vc: self)
        }
    }
    

}
