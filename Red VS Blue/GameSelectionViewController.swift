//
//  GameSelectionViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import UIKit
import Firebase

class GameSelectionViewController: UIViewController {
    
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var hostBioLabel: UILabel!
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientBioLabel: UILabel!
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func startListening() {
        roomListener = roomRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.clientNameLabel.text = documentSnapshot.data()!["clientUserName"] as? String
                self.clientBioLabel.text = documentSnapshot.data()!["clientUserBio"] as? String
                self.hostNameLabel.text = documentSnapshot.data()!["hostUserName"] as? String
                self.hostBioLabel.text = documentSnapshot.data()!["hostUserBio"] as? String
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
}
