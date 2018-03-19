//
//  ContactsManager.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 14/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import Contacts
import CoreData

struct ContactsManager {
    
    static let shared = ContactsManager()
    let userDefaults = UserDefaults.standard
    
    fileprivate let contactStore = CNContactStore()
    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactIdentifierKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
    
    func loadContacts() {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        
        if authStatus == CNAuthorizationStatus.notDetermined {
            contactStore.requestAccess(for: entityType, completionHandler: { (success, err) in
                if let err = err {
                    print("Error on requesting contacts access: ", err)
                    return
                }
                if success {
                    self.userDefaults.set(false, forKey: "firstTime")
                    self.getContacts()
                }
                else {
                    print("Contacts access denied!")
                }
            })
        }
        else if authStatus == CNAuthorizationStatus.authorized {
            self.getContacts()
        }
    }
    
    fileprivate func createContactsCoreData(privateContext: NSManagedObjectContext) {
        let fetchRequest = CNContactFetchRequest(keysToFetch: self.keys)
        do {
            try self.contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (cnContact, pointer) in
                let contact = Contact(context: privateContext)
                self.fillContactFields(contactToSetup: contact, deviceContact: cnContact)
            })
            do {
                try privateContext.save()
                
                DispatchQueue.main.async {
                    do {
                        let cont = CoreDataManager.shared.persistentContainer.viewContext
                        if cont.hasChanges {
                            try cont.save()
                        }
                    }
                    catch let errSavingParentCoredata{
                        print("Error saving into Core Data: ", errSavingParentCoredata)
                        return
                    }
                }
            }catch let errUpdatingCoreData {
                print("Error updating coredata: ", errUpdatingCoreData)
            }
        }
        catch let fetchingErr {
            print("Error fetching contacts from store: ", fetchingErr)
        }
    }
    
    fileprivate func updateCoreDataContacts(privateContext: NSManagedObjectContext, contacts: [Contact]) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest = CNContactFetchRequest(keysToFetch: self.keys)
            do {
                try self.contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (cnContact, pointer) in
                    
                    let matchingContact = contacts.first(where: {cnContact.identifier == $0.identifier!})
                    
                    if let found = matchingContact {
                        //update single contact
                        self.fillContactFields(contactToSetup: found, deviceContact: cnContact)
                    }
                    else {
                        //create new one
                        let contact = Contact(context: privateContext)
                        self.fillContactFields(contactToSetup: contact, deviceContact: cnContact)
                    }
                })
                
                do {
                    try privateContext.save()
                    
                    DispatchQueue.main.async {
                        do {
                            let cont = CoreDataManager.shared.persistentContainer.viewContext
                            if cont.hasChanges {
                                try cont.save()
                            }
                        }
                        catch let errSavingParentCoredata{
                            print("Error saving into Core Data: ", errSavingParentCoredata)
                            return
                        }
                    }
                }catch let errUpdatingCoreData {
                    print("Error updating coredata: ", errUpdatingCoreData)
                }
            }
            catch let fetchingErr {
                print("Error fetching contacts: ", fetchingErr)
            }
        
        }
        
    }
    
    fileprivate func fillContactFields(contactToSetup: Contact, deviceContact: CNContact) {
        contactToSetup.identifier = deviceContact.identifier
        contactToSetup.profileImage = deviceContact.imageData
        contactToSetup.name = deviceContact.givenName + " " + deviceContact.familyName
        contactToSetup.phoneNumber = deviceContact.phoneNumbers.first?.value.stringValue
        
        for num in deviceContact.phoneNumbers {
            let label = CNLabeledValue<NSString>.localizedString(forLabel: num.label ?? "").capitalized
            contactToSetup.voipAppNumber = label.contains("Voip App") ? num.value.stringValue : nil
        }
    }
    
    fileprivate func getContacts() {
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do {
                let contacts = try privateContext.fetch(request)
                
                if contacts.count == 0 {
                    self.createContactsCoreData(privateContext: privateContext)
                }
                else {
                    self.updateCoreDataContacts(privateContext: privateContext, contacts: contacts)
                }
            }
            catch let err {
                print(err)
            }
    }
    
    fileprivate func getContactFromDeviceByIdentifier(contact: Contact) -> CNContact? {
        let predicate = CNContact.predicateForContacts(withIdentifiers: [contact.identifier!])
        
        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
            return contacts.first
        }
        catch let errFetchContPredicate {
            print("Error fetching contacts with predicate: ", errFetchContPredicate)
            return nil
        }
    }
    
    func deleteContactFromDevice(contact: Contact, completion: @escaping (Bool, Error?) -> ()) {
        guard let contactToDelete = getContactFromDeviceByIdentifier(contact: contact)?.mutableCopy() as? CNMutableContact else {return};
        let request = CNSaveRequest()
        request.delete(contactToDelete)
        
        do {
            try contactStore.execute(request)
            completion(true, nil)
        }
        catch let errDeleteContDevice {
            print("Error deleting contact from device: ", errDeleteContDevice)
            completion(false, errDeleteContDevice)
        }
    }
    
    func updateContactToDevice(contact: Contact, completion: @escaping (Bool, Error?) -> ()) {
        guard let contactToUpdate = getContactFromDeviceByIdentifier(contact: contact)?.mutableCopy() as? CNMutableContact else {return};
        setupContactToSaveDevice(contact: contact, contactToSave: contactToUpdate);
        let request = CNSaveRequest()
        request.update(contactToUpdate)
        
        do {
            try contactStore.execute(request)
            completion(true, nil)
        }
        catch let errUpdatingContDevice {
            print("Error updating contact to device: ", errUpdatingContDevice)
            completion(false, errUpdatingContDevice)
        }
    }
    
    func saveNewContactToDevice(contact: Contact, completion: @escaping (String?, Error?) -> ()) {
        
        let newContact = CNMutableContact()
        setupContactToSaveDevice(contact: contact, contactToSave: newContact)

        let request = CNSaveRequest()
        request.add(newContact, toContainerWithIdentifier: nil)
        
        do {
            try contactStore.execute(request)
            completion(newContact.identifier, nil)
        }
        catch let errSaveContDevice {
            print("Error saving new contact on device: ", errSaveContDevice)
            completion(nil, errSaveContDevice)
        }
    }
    
    fileprivate func setupContactToSaveDevice(contact: Contact, contactToSave: CNMutableContact){
        var numbersArray = [CNLabeledValue<CNPhoneNumber>]()
        
        if let imageData = contact.profileImage {
            contactToSave.imageData = imageData
        }
        
        if let fullName = contact.name {
            let nameParts = fullName.components(separatedBy: .whitespaces)
            contactToSave.givenName = nameParts[0]
            if nameParts.count > 1 {
                let startIdx = fullName.index(nameParts[0].endIndex, offsetBy: 1)
                contactToSave.familyName = String(fullName[startIdx...])
            }
        }
        
        if let phoneNumber = contact.phoneNumber {
            let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phoneNumber))
            numbersArray.append(phoneNumber)
        }
        
        if let voipAppNumber = contact.voipAppNumber {
            let voipAppNumber = CNLabeledValue(label: "Voip App", value: CNPhoneNumber(stringValue: voipAppNumber))
            numbersArray.append(voipAppNumber)
        }
        
        if numbersArray.count > 0 {
            contactToSave.phoneNumbers = numbersArray;
        }
        
        if let emailAddress = contact.email {
            let email = CNLabeledValue(label: CNLabelWork, value: emailAddress as NSString)
            contactToSave.emailAddresses = [email]
        }
    }
}
