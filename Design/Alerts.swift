//
//  Alerts.swift
//  Dialogue
//
//  Created by Michael Wlodawsky on 10/17/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class Alerts {
    static func singleChoiceAlert(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

}
