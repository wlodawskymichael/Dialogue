//
//  SignupViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/17/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onGoogleSignup(_ sender: Any) {
        Loading.mockLoading(wait: 3.5) {
            Alerts.notImplementedAlert(functionalityDescription: "This button will allow users to signup with Google in future releases.", vc: self)
        }
    }
    
    @IBAction func onFacebookSignup(_ sender: Any) {
        Loading.mockLoading(wait: 3.5) {
            Alerts.notImplementedAlert(functionalityDescription: "This button will allow users to signup with Facebook in future releases.", vc: self)
        }
    }
    
    @IBAction func onSignup(_ sender: Any) {
        let vc = self
        if EmailTextField.text?.isEmpty ?? true || PasswordTextField.text?.isEmpty ?? true || ConfirmPasswordTextField.text?.isEmpty ?? true {
            Alerts.singleChoiceAlert(title: "Error", message: "One or more required fields is empty.", vc: self)
            return
        }
        if ConfirmPasswordTextField.text! != PasswordTextField.text! {
            Alerts.singleChoiceAlert(title: "Error", message: "Passwords do not match.", vc: self)
            return
        }
        if PasswordTextField.text?.count ?? 0 < 6 {
            Alerts.singleChoiceAlert(title: "Error", message: "Password must be at least 6 characters long.", vc: self)
            return
        }
        // TODO: Check for email format on client side
        //let emailRegEx = try! NSRegularExpression( pattern:"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
        //if emailRegEx.firstMatch(in: EmailTextField.text!, options: [], range: NSRange(location: 0, length: EmailTextField.text!.count)) != nil {
        //    Alerts.singleChoiceAlert(title: "Error", message: "Invalid email.", vc: self)
        //}
        
        Loading.show()
        Auth.auth().createUser(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (result, error) in
            Loading.hide()
            if error != nil {
                Alerts.singleChoiceAlert(title: "Error", message: "Error signing up.", vc: vc)
                return
            } else {
                vc.performSegue(withIdentifier: "signupToDialogue", sender: nil)
            }
        }
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
