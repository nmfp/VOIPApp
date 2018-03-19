//
//  ViewController.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 12/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class HistoryController: UITableViewController, NSFetchedResultsControllerDelegate {

    let cellId = "cellId"
    
    lazy var fetchedResultsController: NSFetchedResultsController<Recent> = {
        let request: NSFetchRequest<Recent> = Recent.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        do {
            try frc.performFetch()
        }
        catch let err {
            print(err)
        }
        
        return frc
    }()
    
    fileprivate func showTutorial() {
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "firstTime")
        if firstTime {
            let onboardingController = OnBoardingController()
            self.present(onboardingController, animated: true, completion: nil)
        }
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "Call History"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "info").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleShowOnboarding))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTutorial()
        setupNavBar()
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.register(HistoryCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func handleShowOnboarding() {
        let onboardingController = OnBoardingController()
        self.present(onboardingController, animated: true, completion: nil)
    }
    
    //MARK:- FetchedResultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //MARK: - TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections![section].numberOfObjects
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HistoryCell
        let recent = fetchedResultsController.object(at: indexPath)
        cell.recent = recent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

