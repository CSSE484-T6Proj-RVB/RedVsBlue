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
    
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if LoginViewController.isGuest {
            return
        }
    }
    
    func startListening() {
        if LoginViewController.isGuest {
            return
        }
    }
    
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
        self.performSegue(withIdentifier: profileSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedGamesButton(_ sender: Any) {
        self.performSegue(withIdentifier: gamePageSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedLeaderboardButton(_ sender: Any) {
        self.performSegue(withIdentifier: leaderboardSegueIdentifier, sender: self)
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
//        let alertController = UIAlertController(title: "Warning",
//                                                message: "You should sign in first!",
//                                                preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Confirm",
//                                                style: .cancel,
//                                                handler: nil))
//        present(alertController, animated: true, completion: nil)
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: "Warning!",
                                    message: "You should sign in first!",
                                    confirmTitle: "Confirm", finishHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier {
            // Nothing Needed
        } else if segue.identifier == createGameSegueIdentifier {
//            (segue.destination as! CreateGameViewController).user = user
        } else if segue.identifier == joinGameSegueIdentifier {
//            (segue.destination as! JoinGameViewController).user = user
        }
    }
}
