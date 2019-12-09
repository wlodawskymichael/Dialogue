//
//  FollowDialogueTableViewCell.swift
//  Dialogue
//
//  Created by Dylan Ramage on 11/27/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class FollowDialogueTableViewCell: UITableViewCell {
    
    static let identifier:String = "FollowDialogueTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }

}
