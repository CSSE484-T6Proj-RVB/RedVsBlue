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
    
    @IBOutlet weak var gamesScrollView: UIView!
    @IBOutlet weak var testButton: UIButton!
    
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
        loadGameButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    func loadGameButtons() {
        var x = 20
        for game in GameCollection.singleton.games {
            let button = UIButton(type: .custom) as UIButton
            button.frame = CGRect(x: x, y: 20, width: 75, height: 75)
            button.setImage(game.gameIconImage, for: .normal)
            //button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
            gamesScrollView.addSubview(button)
            x = x + 20
        }
        
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
    }
    
    
    @IBAction func pressedLeaveButton(_ sender: Any) {
    }
}
