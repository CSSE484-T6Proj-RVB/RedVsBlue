//
//  MainPageViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/17.
//

import UIKit
import Firebase

class MainPageViewController: UIViewController {
    
    var authStateListenerHandle: AuthStateDidChangeListenerHandle!
    let profileSegueIdentifier = "ProfileSegue"
    var usersRef: CollectionReference!
    var usersDataListener: ListenerRegistration!
    var userDataId: String!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        usersRef = Firestore.firestore().collection("Users")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        signOutButton.setTitle(LoginViewController.isGuest ? "Back to sign in" : "Sign out", for: .normal)
        authStateListenerHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if Auth.auth().currentUser == nil && !LoginViewController.isGuest {
                print("No user, go back to login page")
                self.navigationController?.popToRootViewController(animated: true)
            } else if LoginViewController.isGuest {
                print("Continue as guest")
            } else {
                print("Signed in. Stay on this page. User: \(Auth.auth().currentUser!.uid)")
            }
        })
        
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if LoginViewController.isGuest {
            return
        }
        usersDataListener.remove()
    }
    
    func startListening() {
        if LoginViewController.isGuest {
            return
        }
        usersDataListener = usersRef.whereField("id", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.userDataId = documentSnapshot.documents[0].documentID
            } else {
                print("Error getting photos \(error!)")
                return
            }
        })
    }
    
    @IBAction func pressedProfileButton(_ sender: Any) {
        if LoginViewController.isGuest {
            let alertController = UIAlertController(title: "Warning",
                                                    message: "You should sign in first!",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Confirm",
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: self.profileSegueIdentifier, sender: self)
    }
    
    
    @IBAction func pressedSignOutButton(_ sender: Any) {
        if LoginViewController.isGuest {
//            self.navigationController?.popViewController(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier{
            (segue.destination as! ProfileViewController).userRef = usersRef.document(userDataId)
        }
    }
}
