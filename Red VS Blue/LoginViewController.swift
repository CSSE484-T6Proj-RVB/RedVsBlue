//
//  LoginViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/16.
//

import UIKit
import Firebase
import Rosefire
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    static var isGuest = false
    let mainSegueIdentifier = "LoginSegue"
    let signUpSegueIdentifier = "SignUpSegue"
    let REGISTRY_TOKEN = "9f549980-c326-4e31-aa18-869cc452b1d4"
    
    var usersRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        usersRef = Firestore.firestore().collection("Users")
        GIDSignIn.sharedInstance()?.presentingViewController = self
        googleSignInButton.style = .wide
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            print("Someone is already signed in! Just move on!")
            self.performSegue(withIdentifier: self.mainSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func pressedRosefireLoginButton(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self // This should be your view controller
        Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
            if let err = err {
                print("Rosefire sign in error! \(err)")
                return
            }
            //print("Result = \(result!.token!)")
            print("Result = \(result!.username!)")
            print("Result = \(result!.name!)")
            print("Result = \(result!.email!)")
            print("Result = \(result!.group!)")
            
            Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
                if let error = error {
                    print("Firebase sign in error! \(error)")
                    return
                }
                // User is signed in using Firebase!
                print("sign in success")
                LoginViewController.isGuest = false
                
                self.usersRef.whereField("id", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(completion: { (querySnapshot, error) in
                    if let error = error {
                        print("error \(error)")
                        return
                    }
                    if querySnapshot!.count == 0 {
                        self.usersRef.addDocument(data: [
                            "id": Auth.auth().currentUser!.uid
                        ])
                        print("User doc created.")
                    }
                })
                
                self.performSegue(withIdentifier: self.mainSegueIdentifier, sender: self)
            }
        }
    }
    
    @IBAction func pressedSignInEmailButton(_ sender: Any) {
        LoginViewController.isGuest = false
        self.performSegue(withIdentifier: self.signUpSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedSignInLaterButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning!",
                                                message: "You cannot play any games when you are not signed in!",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Continue",
                                                style: .default)
        { (action) in
            LoginViewController.isGuest = true
            self.performSegue(withIdentifier: self.mainSegueIdentifier, sender: self)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
}
