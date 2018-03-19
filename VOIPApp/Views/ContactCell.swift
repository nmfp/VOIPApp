//
//  ContactCell.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 15/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class ContactCell: BaseCell {
    
    var contact: Contact? {
        didSet {
            if let imageData = contact?.profileImage {
                profileImageView.image = UIImage(data: imageData)
            }
            else {
                profileImageView.image = #imageLiteral(resourceName: "avatar-default")
            }
            
            let attributedText = NSMutableAttributedString(string: contact?.name ?? "", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)])
            attributedText.append(NSAttributedString(string: "\n\(contact?.phoneNumber ?? "")", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor(red: 193, green: 193, blue: 193)]))
            nameLabel.attributedText = attributedText
        }
    }
    
    let height: CGFloat = 50
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = height / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    override func setupViews() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: height, height: height)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 12, paddingBottom: 10, paddingRight: 12, width: 0, height: 0)
    }
}
