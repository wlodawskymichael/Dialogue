//  ContactTableViewCell.swift
//  Dialogue
//
//  Created by Dylan Ramage on 11/7/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    
    static let identifier:String = "ContactTableViewCell"
    
    var titleLabel = UILabel()
    var profilePicture = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profilePicture)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profilePicture)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected {
            contentView.backgroundColor = UIColor.green
        } else {
            contentView.backgroundColor = UIColor.white
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePicture.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11),
            profilePicture.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            profilePicture.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
            profilePicture.widthAnchor.constraint(equalToConstant: 44.0),
            profilePicture.heightAnchor.constraint(equalToConstant: 44.0),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 69),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
}
