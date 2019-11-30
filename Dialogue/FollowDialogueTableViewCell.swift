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
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.accessoryType = selected ? .checkmark : .none
    }

}
