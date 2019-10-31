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
        
        if UserDefaults.standard.object(forKey: "user_uid_key") != nil {
            self.performSegue(withIdentifier: "signinToDialogue", sender: nil)
        }
    }
    
    @IBAction func onGoogleSignin(_ sender: Any) {
        Loading.mockLoading(wait: 3.5) {
            Alerts.notImplementedAlert(functionalityDescription: "This button will signin the user with Google in future releases.", vc: self)
        }
        
    }
    
    @IBAction func onFacebookSignin(_ sender: Any) {
        Loading.mockLoading(wait: 3.5) {
            Alerts.notImplementedAlert(functionalityDescription: "This button will signin the user with Facebook in future releases", vc: self)
        }
    }
    
    @IBAction func onSignin(_ sender: Any) {
        let vc = self
        Loading.show()
        if !(EmailTextField.text?.isEmpty ?? true || PasswordTextField.text?.isEmpty ?? true) {
            Auth.auth().signIn(withEmail: EmailTextField.text!, password: PasswordTextField.text!) { (result, error) in
                Loading.hide()
                if error != nil {
                    Alerts.singleChoiceAlert(title: "Error", message: "Email or Password was invalid.", vc: vc)
                } else {
                    vc.performSegue(withIdentifier: "signinToDialogue", sender: nil)
                }
                
            }
        } else {
            Loading.hide()
            Alerts.singleChoiceAlert(title: "Error", message: "Email or Password field is empty.", vc: self)
        }
    }
    

    // code to dismiss keyboard when user clicks on background

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
