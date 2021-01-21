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
    
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var readyMessageLabel: UILabel!
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    var isReady = false
    var gameSelectedIndex: Int!
    var currentUser: User!
    var gameSegueIdentifiers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        for game in GameCollection.singleton.games {
            gameSegueIdentifiers.append(game.segueName)
        }
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
        self.readyMessageLabel.isHidden = true
        self.isReady = false
        
        self.roomRef.updateData([
            "clientReady": false,
            "hostReady": false
        ])
        
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
                let clientReadyBool = documentSnapshot.data()!["clientReady"] as! Bool
                let hostReadyBool = documentSnapshot.data()!["hostReady"] as! Bool
                if clientReadyBool && hostReadyBool {
                    self.performSegue(withIdentifier: self.gameSegueIdentifiers[self.gameSelectedIndex], sender: self)
                }
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
    
    @IBAction func pressedReadyButton(_ sender: Any) {
        isReady = !isReady
        readyButton.backgroundColor = isReady ? UIColor.red : UIColor.green
        readyButton.setTitle(isReady ? "Cancel" : "Ready!", for: .normal)
        readyMessageLabel.isHidden = !isReady
        if currentUser.identity == 0 {
            self.roomRef.updateData([
                "clientReady": isReady
            ])
        } else if currentUser.identity == 1 {
            self.roomRef.updateData([
                "hostReady": isReady
            ])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TicTacToeGameSegue" {
            (segue.destination as! TicTacToeViewController).roomRef = roomRef
            (segue.destination as! TicTacToeViewController).user = currentUser
            //(segue.destination as! TicTacToeViewController).game = GameCollection.singleton.games[self.gameSelectedIndex]
        }
    }
    
}
