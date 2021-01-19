//
//  GameSelectionViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import UIKit
import Firebase

class GameSelectionViewController: UIViewController {
    
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
                print("ClientName: \(documentSnapshot.data()!["clientUserName"])")
                print("HostName: \(documentSnapshot.data()!["hostUserName"])")
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
}
