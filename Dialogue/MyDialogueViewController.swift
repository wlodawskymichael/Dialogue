//
//  MyDialogueViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/22/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyDialogueViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onProfile(_ sender: Any) {
        if LoginListener.isUserSignedIn() {
            Alerts.singleChoiceAlert(title: "Login Status", message: "The user is logged in.", vc: self)
        } else {
            Alerts.singleChoiceAlert(title: "Error", message: "The user is not logged in!", vc: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
