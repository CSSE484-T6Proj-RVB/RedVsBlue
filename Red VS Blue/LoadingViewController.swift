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
    
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var hostBioLabel: UILabel!
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientBioLabel: UILabel!
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    var gameSelectedIndex: Int!
    var currentUser: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectedGameDescription.layer.cornerRadius = 15
        selectedGameDescription.layer.borderWidth = 2
        
        let game =  GameCollection.singleton.games[gameSelectedIndex]
        self.selectedGameIcon.image = game.gameIconImage
        self.selectedGameLabel.text = game.name
        self.selectedGameDescription.text = game.description
        
        
        
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomListener.remove()
    }
    
    func startListening() {
        roomListener = roomRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.clientNameLabel.text = documentSnapshot.data()!["clientUserName"] as? String
                let clientBio = documentSnapshot.data()!["clientUserBio"] as? String
                self.clientBioLabel.text = clientBio == "" ? "This player has no bio." : clientBio
                self.hostNameLabel.text = documentSnapshot.data()!["hostUserName"] as? String
                let hostBio = documentSnapshot.data()!["hostUserBio"] as? String
                self.hostBioLabel.text = hostBio == "" ? "This player has no bio." : hostBio
                
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
}
