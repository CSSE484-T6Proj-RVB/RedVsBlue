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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func pressedEmailSignInButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Error signing in existing user \(error)")
                AlertDialog.showAlertDialog(viewController: self, title: "Error",
                                            message: error.localizedDescription.description,
                                            confirmTitle: "Confirm", finishHandler: nil)
                return
            }
            print("Signing in with existing user worked!")
            self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func pressedEmailSignUpButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print("Error creating new user for Email/Password \(error)")
                AlertDialog.showAlertDialog(viewController: self, title: "Error",
                                            message: error.localizedDescription.description,
                                            confirmTitle: "Confirm", finishHandler: nil)
                return
            }
            
            print("It worked!!! A new user is created and now signed in.")
            self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mainSegueIdentifier {
            print("Checking for user: \(Auth.auth().currentUser!.uid)")
            UserManager.shared.addNewUserMabye(uid: Auth.auth().currentUser!.uid, name: RandomStringGenerator.shared.generateRandomUsername(), photoUrl: Auth.auth().currentUser!.photoURL?.absoluteString)
        }
    }
    
}
