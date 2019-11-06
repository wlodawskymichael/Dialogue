//
//  DialogueTableViewCell.swift
//  Dialogue
//
//  Created by William Lemens on 11/4/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class DialogueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photo:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subLabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
