//
//  SignupViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/17/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onSignup(_ sender: Any) {
        
        if EmailTextField.text?.isEmpty ?? true || PasswordTextField.text?.isEmpty ?? true || ConfirmPasswordTextField.text?.isEmpty ?? true {
            Alerts.singleChoiceAlert(title: "Error", message: "One or more required fields is empty.", vc: self)
        }
    }


}
