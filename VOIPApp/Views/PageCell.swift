//
//  PageCell.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 18/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            if let _ = delegate {
                self.okButton.isHidden = false
            }
            else {
                self.okButton.isHidden = true
            }
            
            titleLabel.text = page?.title
            
            if let imageData = page?.image {
                imageView.image = imageData
            }
        }
    }
    
    var delegate: OnBoardingControllerDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    lazy var okButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 30
        btn.layer.masksToBounds = true
        btn.setTitle("Dismiss", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 45, green: 143, blue: 255)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleDismiss() {
        delegate?.handleDismiss()
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(okButton)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 160)
        imageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
        okButton.anchor(top: nil, left: nil, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 120, height: 60)
        okButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

