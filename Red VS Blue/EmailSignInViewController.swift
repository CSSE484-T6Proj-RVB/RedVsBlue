//
//  EmailSignInViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/17.
//

import UIKit
import Firebase

class EmailSignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let mainSegueIdentifier = "MainSegue"
    var usersRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        usersRef = Firestore.firestore().collection("Users")
    }
    
    @IBAction func pressedEmailSignInButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Error signing in existing user \(error)")
                self.showErrorDialog(str: error.localizedDescription.description)
                return
            }
            print("Signing in with existing user worked!")
            self.performSegue(withIdentifier: self.mainSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func pressedEmailSignUpButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Error creating new user for Email/Password \(error)")
                self.showErrorDialog(str: error.localizedDescription.description)
                return
            }
            
            print("It worked!!! A new user is created and now signed in.")
            
            self.usersRef.addDocument(data: [
                "id": Auth.auth().currentUser!.uid
            ])
            print("User doc created.")
            
            self.performSegue(withIdentifier: self.mainSegueIdentifier, sender: self)
        }
    }
    
    func showErrorDialog(str: String) {
        let alertController = UIAlertController(title: "Error",
                                                message: str,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
}
