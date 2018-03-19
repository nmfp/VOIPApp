//
//  Recent.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 12/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class HistoryCell: BaseCell {
    
    var recent: Recent? {
        didSet {
            if let imageData = recent?.contact?.profileImage {
                contactImageView.image = UIImage(data: imageData)
            }
            else {
                contactImageView.image = #imageLiteral(resourceName: "avatar-default")
            }
            
            let attributedText = NSMutableAttributedString(string: recent?.contact?.name ?? "", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)])
            attributedText.append(NSAttributedString(string: "\n\(recent?.contact?.voipAppNumber ?? "")", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor(red: 193, green: 193, blue: 193)]))
            contactLabel.attributedText = attributedText
            
            guard let date = recent?.date else {return}
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let recentDateParts = dateFormatter.string(from: date).components(separatedBy: .whitespaces)
            
            let timeAttributedText = NSMutableAttributedString(string: recentDateParts[1], attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.voipAppGreen])
            timeAttributedText.append(NSAttributedString(string: "\n\(recentDateParts[0])", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            timeLabel.attributedText = timeAttributedText
        }
    }
    
    let height: CGFloat = 50
    
    lazy var contactImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = height / 2
        iv.clipsToBounds = true
        return iv
    }()
    
    let contactLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "contact name"
        label.numberOfLines = 2
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .voipAppGreen
        label.textAlignment = .right
        label.numberOfLines = 2
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var recentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contactImageView, contactLabel, timeLabel])
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    override func setupViews() {
        addSubview(recentStackView)
        
        contactImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: height, height: height)
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        recentStackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 12, paddingBottom: 5, paddingRight: 12, width: 0, height: 0)
    }
}

