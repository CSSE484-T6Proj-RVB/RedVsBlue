//
//  LoadingViewController.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 1/21/21.
//

import Foundation
import UIKit
import Firebase

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var selectedGameIcon: UIImageView!
    @IBOutlet weak var selectedGameLabel: UILabel!
    @IBOutlet weak var selectedGameDescription: UITextView!
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectedGameDescription.layer.cornerRadius = 15
        selectedGameDescription.layer.borderWidth = 2
        
        roomRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("error getting room reference: \(error)")
            } else {
                let index = documentSnapshot?.data()!["currentGameSelected"] as! Int
                let game =  GameCollection.singleton.games[index]
                self.selectedGameIcon.image = game.gameIconImage
                self.selectedGameLabel.text = game.name
                self.selectedGameDescription.text = game.description
            }
        }
        
        startListening()
    }
    
    func startListening() {
        roomListener = roomRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
              
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
}
