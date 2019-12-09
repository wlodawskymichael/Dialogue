//
//  SettingsTableViewCell.swift
//  Dialogue
//
//  Created by William Lemens on 12/2/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    let nameLabel = UILabel()
    let adminToggle = UISwitch()
    let userImage = UIImageView()
    let adminLabel = UILabel()
    let kickButton = UIButton()
    
    static let identifier:String = "settingsCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(adminToggle)
        contentView.addSubview(userImage)
        contentView.addSubview(adminLabel)
        contentView.addSubview(kickButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        adminToggle.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        adminLabel.translatesAutoresizingMaskIntoConstraints = false
        kickButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            userImage.bottomAnchor.constraint(equalTo: adminLabel.topAnchor, constant: -5),
            userImage.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -5),
            userImage.widthAnchor.constraint(equalToConstant: 44.0),
            userImage.heightAnchor.constraint(equalToConstant: 44.0),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            nameLabel.bottomAnchor.constraint(equalTo: adminToggle.topAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(equalTo: adminLabel.topAnchor, constant: -5),
            
            kickButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            kickButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            kickButton.bottomAnchor.constraint(equalTo: adminToggle.topAnchor, constant: -5),
            kickButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            kickButton.widthAnchor.constraint(equalToConstant: 44.0),
            kickButton.heightAnchor.constraint(equalToConstant: 44.0),
            
            adminLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            adminLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            adminLabel.trailingAnchor.constraint(equalTo: adminToggle.leadingAnchor, constant: -5),
            
            adminToggle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            adminToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        
        adminLabel.text = "Admin access:"
        
        kickButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        kickButton.tintColor = .red
    }

}
