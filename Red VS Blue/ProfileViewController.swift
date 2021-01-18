//
//  ProfileViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/17.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextFieldView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioTextFieldView: UIView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var matchesWonLabel: UILabel!
    @IBOutlet weak var matchesPlayedLabel: UILabel!
    
    var userDataListener: ListenerRegistration!
    var userRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Your Profile"
        
        setCornerAndBorder(view: nameView, cornerRadius: 15, borderWidth: 5, borderColor: UIColor.black.cgColor)
        setCornerAndBorder(view: nameTextFieldView, cornerRadius: 10, borderWidth: 1, borderColor: UIColor.black.cgColor)
        setCornerAndBorder(view: bioView, cornerRadius: 15, borderWidth: 5, borderColor: UIColor.black.cgColor)
        setCornerAndBorder(view: bioTextFieldView, cornerRadius: 10, borderWidth: 1, borderColor: UIColor.black.cgColor)
        setCornerAndBorder(view: statusView, cornerRadius: 30, borderWidth: 1, borderColor: UIColor.black.cgColor)

        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userDataListener.remove()
    }
    
    func startListening() {
        userDataListener = userRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.updateView(data: documentSnapshot.data()!)
            } else {
                print("Error getting user data: \(error!)")
                return
            }
        })
    }
    
    func updateView(data: [String: Any]) {
        nameLabel.text = data["name"] as? String
        bioLabel.text = data["bio"] as? String
        // TODO: Add stats tab
    }
    
    func setCornerAndBorder(view: UIView, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor
    }
    
    @IBAction func pressedUpdateNameButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit Your Name",
                                                message: nil,
                                                preferredStyle: .alert)
        //Configure
        alertController.addTextField { (textField) in
            textField.placeholder = "Your New Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Update",
                                                style: .default)
        { (action) in
            let nameField = alertController.textFields![0] as UITextField
            self.userRef.updateData([
                "name": nameField.text!
            ])
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pressedEditBioButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Edit Your Bio",
                                                message: nil,
                                                preferredStyle: .alert)
        //Configure
        alertController.addTextField { (textField) in
            textField.placeholder = "Your New Bio"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Update",
                                                style: .default)
        { (action) in
            let bioField = alertController.textFields![0] as UITextField
            self.userRef.updateData([
                "bio": bioField.text!
            ])
        })
        
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func pressedDeleteBioButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil,
                                                message: "Are you sure you want to permanently delete your current bio?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes",
                                                style: .default)
        { (action) in
            self.userRef.updateData([
                "bio": ""
            ])
        })
        
        let alertController_bad = UIAlertController(title: nil,
                                                    message: "You do not have a bio",
                                                    preferredStyle: .alert)
        alertController_bad.addAction(UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil))
        
        present(bioLabel.text == "" ? alertController_bad : alertController, animated: true, completion: nil)
    }
}
