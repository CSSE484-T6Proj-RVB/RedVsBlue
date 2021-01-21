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
    
    @IBOutlet weak var gameScrollView: UIView!
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
                if let _ = documentSnapshot.data()!["endGameRequest"] as? Bool {
                    let alertController = UIAlertController(title: "Game Ended",
                                                            message: "The other player has left!",
                                                            preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: "OK",
                                                            style: .default)
                    { (action) in
                        self.deleteRoomAndLeave()
                    })
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
    
    func loadGameButtons() {
        let viewWidth = gameScrollView.frame.size.width
        let horizontalGap = 10, verticalGap = 20, iconWidth = 80, startingXPos = 20, startingYPos = 20
        var x = startingXPos, y = startingYPos
        //gameScrollView.frame.size.height = CGFloat(numRows * (verticalGap + iconWidth))
        
        for game in GameCollection.singleton.games {
            let button = UIButton(type: .custom) as UIButton
            if x + horizontalGap + iconWidth >= Int(viewWidth) {
                y += verticalGap + iconWidth
                x = startingXPos
            }
            button.frame = CGRect(x: x, y: y, width: iconWidth, height: iconWidth)
            button.setImage(game.gameIconImage, for: .normal)
            //button.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
            gameScrollView.addSubview(button)
            x += horizontalGap + iconWidth
        }
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
    }
    
    
    @IBAction func pressedLeaveButton(_ sender: Any) {
        let alertController = UIAlertController(title: nil,
                                                message: "Are you sure you want to leave the game?",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm",
                                                style: .default)
        { (action) in
            //self.roomRef.delete()
            self.roomRef.updateData([
                "endGameRequest": true
            ])
            self.navigationController?.popToRootViewController(animated: true)
            // TODO: Game Result Page
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteRoomAndLeave() {
        roomRef.delete()
        navigationController?.popToRootViewController(animated: true)
    }
}
