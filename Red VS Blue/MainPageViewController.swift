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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
}
