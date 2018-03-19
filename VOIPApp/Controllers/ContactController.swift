//
//  ContactController.swift
//  VOIPApp
//
//  Created by Nuno Pereira on 15/03/2018.
//  Copyright © 2018 Nuno Pereira. All rights reserved.
//

import Foundation
import UIKit

protocol ContactListDelegate {
    func updateVoipContacxtView()
}

class ContactController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var contact: Contact? {
        didSet {
            nameTextField.text = contact?.name
            phoneNumberTextField.text = contact?.phoneNumber
            voipAppTextField.text = contact?.voipAppNumber
            emailTextField.text = contact?.email
            
            if let imageData = contact?.profileImage {
                contactImageView.image = UIImage(data: imageData)
                setupImageCircularStyle()
            }
        }
    }
    
    let height: CGFloat = 100
    
    lazy var contactImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        iv.layer.cornerRadius = height / 2
        return iv
    }()
    
    //Labels
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Phone:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let voipAppNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Voip App:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email:"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //TextFields
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your phone number"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let voipAppTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your VoipApp number"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var delegate: ContactListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = contact?.name
    }
    
    fileprivate func setupNavBar() {
        navigationItem.title = "New Contact"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSaveContact))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    fileprivate func setupViews() {
        view.addSubview(contactImageView)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(phoneNumberLabel)
        view.addSubview(phoneNumberTextField)
        view.addSubview(voipAppNumberLabel)
        view.addSubview(voipAppTextField)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        
        contactImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        contactImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        nameLabel.anchor(top: contactImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 24, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        nameTextField.anchor(top: nameLabel.topAnchor, left: nameLabel.rightAnchor, bottom: nameLabel.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        phoneNumberLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        phoneNumberTextField.anchor(top: phoneNumberLabel.topAnchor, left: phoneNumberLabel.rightAnchor, bottom: phoneNumberLabel.bottomAnchor, right: nameTextField.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        voipAppNumberLabel.anchor(top: phoneNumberLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        voipAppTextField.anchor(top: voipAppNumberLabel.topAnchor, left: voipAppNumberLabel.rightAnchor, bottom: voipAppNumberLabel.bottomAnchor, right: nameTextField.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        emailLabel.anchor(top: voipAppNumberLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        emailTextField.anchor(top: emailLabel.topAnchor, left: emailLabel.rightAnchor, bottom: emailLabel.bottomAnchor, right: nameTextField.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
//        NSLayoutConstraint.activate([
//            contactImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
//            contactImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            contactImageView.heightAnchor.constraint(equalToConstant: height),
//            contactImageView.widthAnchor.constraint(equalToConstant: height),
//
//            nameLabel.topAnchor.constraint(equalTo: contactImageView.bottomAnchor, constant: 24),
//            nameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
//            nameLabel.heightAnchor.constraint(equalToConstant: 50),
//            nameLabel.widthAnchor.constraint(equalToConstant: 100),
//
//            nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor),
//            nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 12),
//            nameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
//            nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor),
//
//            phoneNumberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
//            phoneNumberLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
//            phoneNumberLabel.heightAnchor.constraint(equalToConstant: 50),
//            phoneNumberLabel.widthAnchor.constraint(equalToConstant: 100),
//
//            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberLabel.topAnchor),
//            phoneNumberTextField.leftAnchor.constraint(equalTo: phoneNumberLabel.rightAnchor, constant: 12),
//            phoneNumberTextField.rightAnchor.constraint(equalTo: nameTextField.rightAnchor),
//            phoneNumberTextField.bottomAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor),
//
//            voipAppNumberLabel.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 2),
//            voipAppNumberLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
//            voipAppNumberLabel.heightAnchor.constraint(equalToConstant: 50),
//            voipAppNumberLabel.widthAnchor.constraint(equalToConstant: 100),
//
//            voipAppTextField.topAnchor.constraint(equalTo: voipAppNumberLabel.topAnchor),
//            voipAppTextField.leftAnchor.constraint(equalTo: voipAppNumberLabel.rightAnchor, constant: 12),
//            voipAppTextField.rightAnchor.constraint(equalTo: nameTextField.rightAnchor),
//            voipAppTextField.bottomAnchor.constraint(equalTo: voipAppNumberLabel.bottomAnchor),
//
//            emailLabel.topAnchor.constraint(equalTo: voipAppNumberLabel.bottomAnchor, constant: 2),
//            emailLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
//            emailLabel.heightAnchor.constraint(equalToConstant: 50),
//            emailLabel.widthAnchor.constraint(equalToConstant: 100),
//
//            emailTextField.topAnchor.constraint(equalTo: emailLabel.topAnchor),
//            emailTextField.leftAnchor.constraint(equalTo: emailLabel.rightAnchor, constant: 12),
//            emailTextField.rightAnchor.constraint(equalTo: nameTextField.rightAnchor),
//            emailTextField.bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor)
//            ])
    }
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleSaveContact() {
        if contact == nil {
            saveNewContact()
        }
        else {
            saveEditedContact()
        }
        dismissViewController()
    }
    
    fileprivate func saveNewContact() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let newContact = Contact(context: context)
        newContact.name = nameTextField.text
        newContact.phoneNumber = phoneNumberTextField.text
        newContact.voipAppNumber = voipAppTextField.text!.count > 0 ? voipAppTextField.text : nil
        newContact.email = emailTextField.text
        
        if let profileImage = contactImageView.image, profileImage != #imageLiteral(resourceName: "select_photo_empty") {
            let imageData = UIImageJPEGRepresentation(profileImage, 0.7)
            newContact.profileImage = imageData
        }
        
        ContactsManager.shared.saveNewContactToDevice(contact: newContact, completion: { (identifier, err) in
            if let err = err {
                print("Error saving contact: ", err)
                return
            }
            
            newContact.identifier = identifier
            DispatchQueue.main.async {
                do {
                    try context.save()
                    self.delegate?.updateVoipContacxtView()
                }
                catch let errSaveNewCont {
                    print("Error saving new contact...", errSaveNewCont)
                }
            }
        })
    }
    
    fileprivate func saveEditedContact() {
        contact?.name = nameTextField.text
        contact?.phoneNumber = phoneNumberTextField.text
        contact?.voipAppNumber = voipAppTextField.text!.count > 0 ? voipAppTextField.text : nil
        contact?.email = emailTextField.text
        
        if let profileImage = contactImageView.image, profileImage != #imageLiteral(resourceName: "select_photo_empty") {
            let imageData = UIImageJPEGRepresentation(profileImage, 0.7)
            contact?.profileImage = imageData
        }
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        ContactsManager.shared.updateContactToDevice(contact: contact!) { (success, err) in
            if let err = err {
                print("Error saving contact: ", err)
                return
            }
            
            do {
                try context.save()
            }
            catch let errSaveEditCont {
                print("Error saving edited contact...", errSaveEditCont)
            }
        }
    }
    
    @objc func handleCancel() {        
        dismissViewController()
    }
    
    fileprivate func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupImageCircularStyle(){
        contactImageView.layer.borderColor = UIColor.black.cgColor
        contactImageView.layer.borderWidth = 2
    }
    
    //MARK:- ImagePickerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            contactImageView.image = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            contactImageView.image = originalImage
        }
        
        setupImageCircularStyle()
        dismiss(animated: true, completion: nil)
    }
}
