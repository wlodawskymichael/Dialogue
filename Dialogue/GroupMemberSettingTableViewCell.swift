//
//  GroupMemberSettingTableViewCell.swift
//  Dialogue
//
//  Created by Sahil Parikh on 11/24/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class GroupMemberSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var memberDisplayName: UILabel!
    @IBOutlet weak var memberAdminToggle: UISwitch!
    
    static let identifier:String = "groupMemberCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func removeGroupMember(_ sender: Any) {
    }
    
}
