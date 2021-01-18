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
    let leaderboardSegueIdentifier = "LeaderboardSegue"
    let createGameSegueIdentifier = "CreateGameSegue"
    let joinGameSegueIdentifier = "JoinGameSegue"
    
    var usersRef: CollectionReference!
    var usersDataListener: ListenerRegistration!
    var user: User!
    
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
                self.user = User(documentSnapshot: documentSnapshot.documents[0])
                //self.userDataId = documentSnapshot.documents[0].documentID
            } else {
                print("Error getting user data \(error!)")
                return
            }
        })
    }
    
    // TODO: Bad Constraints on small phones
    @IBAction func pressedNewGameButton(_ sender: Any) {
        if LoginViewController.isGuest {
            alertNotLoggedIn()
            return
        }
        self.performSegue(withIdentifier: createGameSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedJoinGameButton(_ sender: Any) {
        if LoginViewController.isGuest {
            alertNotLoggedIn()
            return
        }
        self.performSegue(withIdentifier: joinGameSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedProfileButton(_ sender: Any) {
        if LoginViewController.isGuest {
            alertNotLoggedIn()
            return
        }
        self.performSegue(withIdentifier: self.profileSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedGamesButton(_ sender: Any) {
        // TODO: Games Page
    }
    
    @IBAction func pressedLeaderboardButton(_ sender: Any) {
        self.performSegue(withIdentifier: self.leaderboardSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedSignOutButton(_ sender: Any) {
        if LoginViewController.isGuest {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("sign out error")
        }
    }
    
    func alertNotLoggedIn() {
        let alertController = UIAlertController(title: "Warning",
                                                message: "You should sign in first!",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Confirm",
                                                style: .cancel,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier {
            (segue.destination as! ProfileViewController).userRef = usersRef.document(user.id)
        } else if segue.identifier == createGameSegueIdentifier {
            (segue.destination as! CreateGameViewController).user = user
        } else if segue.identifier == joinGameSegueIdentifier {
            (segue.destination as! JoinGameViewController).user = user
        }
    }
}
