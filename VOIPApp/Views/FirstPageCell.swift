//
//  FirstPageCell.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 18/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class FirstPage: PageCell {
    
    override func setupViews() {
        super.setupViews()
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 42)
        titleLabel.textAlignment = .left
        titleLabel.deactivateAllConstraints()
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 90, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }   
}
