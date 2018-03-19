//
//  MainTabBarController.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 13/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.tabBar.barTintColor = .white
        
        navigationController?.isNavigationBarHidden = true
        setupViewControllers()
    }
    
    func setupViewControllers() {
        //History Controller
        let historyController = createTabBarController(selectedImage: #imageLiteral(resourceName: "clock").withRenderingMode(.automatic), title: "History", rootViewController: HistoryController())
        
        //Contacts Controller
        let contactsController = createTabBarController(selectedImage: #imageLiteral(resourceName: "man").withRenderingMode(.automatic), title: "Contacts", rootViewController: ContactListController())
        
        self.viewControllers = [historyController, contactsController]
        
        self.tabBar.tintColor = .voipAppGreen
        self.tabBar.barTintColor = .white
    }
    
    func createTabBarController(selectedImage: UIImage, title: String, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        viewController.tabBarItem.title = title
        viewController.tabBarItem.selectedImage = selectedImage
        viewController.tabBarItem.image = selectedImage
        let navController = UINavigationController(rootViewController: viewController)
        return navController
    }
}
