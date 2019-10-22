//
//  MyDialogueViewController.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/22/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class MyDialogueViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onProfile(_ sender: Any) {
        Alerts.notImplementedAlert(functionalityDescription: "This button will allow user customization in future releases.", vc: self)
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
