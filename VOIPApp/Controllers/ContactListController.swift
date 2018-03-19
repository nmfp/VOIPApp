//
//  ContactListController.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 13/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import UIKit
import CoreData

class ContactListController: UITableViewController, NSFetchedResultsControllerDelegate, ContactListDelegate {
    
    lazy var fetchedResultsController: NSFetchedResultsController<Contact> = {
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
    
    lazy var segmentedController: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["VoipApp", "All"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.addTarget(self, action: #selector(handleChangeContactList), for: .valueChanged)
        return sc
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "arrow-small-16").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddContact))
        return rightBarButton
    }()
    
    fileprivate func setupNavbar() {
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "info").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleShowOnboarding))
        navigationItem.titleView = segmentedController
    }
    
//    var allContacts = [Contact]()
    var voipAppContacts = [Contact]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavbar()
//        fetchAllContacts()
        handleChangeContactList()
        
        tableView.tableFooterView = UIView()
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
    }
    
    @objc func handleShowOnboarding() {
        let onboardingController = OnBoardingController()
        self.present(onboardingController, animated: true, completion: nil)
    }
    
    @objc func handleChangeContactList() {
        if segmentedController.selectedSegmentIndex == 0 {
            self.voipAppContacts = getVoipAllContacts()
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
            return
        }
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.tableView.reloadData()
    }
    
    @objc func handleAddContact() {
        let contactController = ContactController()
        contactController.delegate = self;
        let navController = UINavigationController(rootViewController: contactController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func updateVoipContacxtView() {
        handleChangeContactList()
    }
    
    //MARK:- FetchedResultsController
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        var voipAppIdx: IndexPath?
        if segmentedController.selectedSegmentIndex == 0 {
            guard let contactForIndexPath = anObject as? Contact else { return }
            let voipAppContactForIndexPath = voipAppContacts.first(where: {$0.objectID == contactForIndexPath.objectID})
            let indexToUpdate = voipAppContacts.index(of: voipAppContactForIndexPath!)
            voipAppIdx = IndexPath(row: indexToUpdate!, section: 0)
        }
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            if segmentedController.selectedSegmentIndex == 0 {
                voipAppContacts.remove(at: voipAppIdx!.row)
                tableView.deleteRows(at: [voipAppIdx!], with: .fade)
            }
            else {
                tableView.deleteRows(at: [indexPath!], with: .fade)
            }
        case .update:
            if segmentedController.selectedSegmentIndex == 0 {
                tableView.reloadRows(at: [voipAppIdx!], with: .fade)
            }
            else {
                tableView.reloadRows(at: [indexPath!], with: .fade)
            }
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //MARK:- TableView methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let total = fetchedResultsController.sections![section].numberOfObjects
        return segmentedController.selectedSegmentIndex == 0 ? getVoipAllContacts().count : total
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        cell.contact = segmentedController.selectedSegmentIndex == 0 ? getVoipAllContacts()[indexPath.row] : fetchedResultsController.object(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = segmentedController.selectedSegmentIndex == 0 ? voipAppContacts[indexPath.row] : fetchedResultsController.object(at: indexPath)
        
        guard let _ = contact.voipAppNumber else {return}
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let recent = Recent(context: context)
        recent.contact = contact
        recent.date = Date()
        
        do {
            try context.save()
        }
        catch let errorSaveRecent {
            print("Failed to save Recent: ", errorSaveRecent)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: editContact)
        editAction.backgroundColor = UIColor(red: 45, green: 143, blue: 255)
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteContact)
        return [deleteAction, editAction]
    }
    
    func editContact(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Trying to edit contact...")
        let contact = segmentedController.selectedSegmentIndex == 0 ? getVoipAllContacts()[indexPath.row] : fetchedResultsController.object(at: indexPath)
        let contactController = ContactController()
        contactController.contact = contact
        contactController.delegate = self
        let navController = UINavigationController(rootViewController: contactController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func deleteContact(action: UITableViewRowAction, indexPath: IndexPath) {
        print("Trying to delete contact...")
        
        var contactToDelete: Contact?
        if segmentedController.selectedSegmentIndex == 0 {
            contactToDelete = voipAppContacts[indexPath.row]
            let correctIndexPath = fetchedResultsController.indexPath(forObject: contactToDelete!)
            contactToDelete = fetchedResultsController.object(at: correctIndexPath!)
        }
        else {
            contactToDelete = fetchedResultsController.object(at: indexPath)
        }
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        ContactsManager.shared.deleteContactFromDevice(contact: contactToDelete!) { (success, err) in
            if let err = err {
                print("Error saving contact: ", err)
                return
            }
            DispatchQueue.main.async {
                do {
                    context.delete(contactToDelete!)
                    try context.save()
                }
                catch let errDelFromCoredata {
                    print("Error deleting contact from core data: ", errDelFromCoredata)
                }
            }
        }
    }
    
    func getVoipAllContacts() -> [Contact] {
        return (fetchedResultsController.sections![0].objects as! [Contact]).filter({$0.voipAppNumber != nil})
    }
}
