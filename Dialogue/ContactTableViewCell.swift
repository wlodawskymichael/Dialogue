//  ContactTableViewCell.swift
//  Dialogue
//
//  Created by Dylan Ramage on 11/7/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    static let identifier:String = "ContactTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
