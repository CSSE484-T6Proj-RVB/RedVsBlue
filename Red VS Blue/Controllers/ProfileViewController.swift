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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Your Profile"
        
        RoundCornerFactory.shared.setCornerAndBorder(view: nameView, cornerRadius: 15, borderWidth: 5, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(view: nameTextFieldView, cornerRadius: 10, borderWidth: 1, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(view: bioView, cornerRadius: 15, borderWidth: 5, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(view: bioTextFieldView, cornerRadius: 10, borderWidth: 1, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(view: statusView, cornerRadius: 30, borderWidth: 2, borderColor: UIColor.black.cgColor)

        UserManager.shared.beginListeningForSingleUser(uid: UserManager.shared.uid, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserManager.shared.stopListening()
    }
    
    func updateView() {
        nameLabel.text = UserManager.shared.name
        bioLabel.text = UserManager.shared.bio
        matchesPlayedLabel.text = "Matches Played: \(UserManager.shared.matchesPlayed)"
        matchesWonLabel.text = "Matches Won: \(UserManager.shared.matchesWon)"
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
            UserManager.shared.updateName(name: nameField.text!)
            let alertControllerConfirmNameChange = UIAlertController(title: nil, message: "You have changed your name", preferredStyle: .alert)
            alertControllerConfirmNameChange.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertControllerConfirmNameChange, animated: true, completion: nil)
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
            if bioField.text == "" {
                let alertControllerNoBio = UIAlertController(title: nil, message: "You didn't write anything", preferredStyle: .alert)
                alertControllerNoBio.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertControllerNoBio, animated: true, completion: nil)
                return
            }
            
            UserManager.shared.updateBio(bio: bioField.text!)
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
            UserManager.shared.updateBio(bio: "")
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
