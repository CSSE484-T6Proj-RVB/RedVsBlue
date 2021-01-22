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
    
    @IBOutlet weak var gameSelectedLabel: UILabel!
    @IBOutlet weak var hostScoreLabel: UILabel!
    @IBOutlet weak var clientScoreLabel: UILabel!
    
    @IBOutlet weak var clientWaitingLabel: UILabel!
    @IBOutlet weak var hostGoButton: UIButton!
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    var gameButtons: [UIButton] = []
    var currentSelectedButtonIndex: Int =  -1
    
    let loadingSegue = "LoadingSegue"
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if user.identity == 0 {
            hostGoButton.isHidden = true
            clientWaitingLabel.isHidden = false
        } else if user.identity == 1{
            hostGoButton.isHidden = false
            clientWaitingLabel.isHidden = true
        } else {
            // never happens
            print("This should never be printed!!!!!!!!!!!!!!!!!!!!!!!!")
        }
        if user.identity == 1 {
            self.roomRef.updateData([
                "hostScore": user.score
            ])
        } else if user.identity == 0 {
            self.roomRef.updateData([
                "clientScore": user.score
            ])
        }
        
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
                self.hostScoreLabel.text = String(documentSnapshot.data()!["hostScore"] as! Int)
                self.clientScoreLabel.text = String(documentSnapshot.data()!["clientScore"] as! Int)
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
                if let selectedTag = documentSnapshot.data()!["currentGameSelected"] as? Int {
                    if self.user.identity == 0 {
                        self.resetAllIcon()
                        self.selectIcon(currentSelected: selectedTag)
                        self.updateGameSelectedLabel(currentSelected: selectedTag)
                        self.currentSelectedButtonIndex = selectedTag

                    }
                }
                let startGameRequest = documentSnapshot.data()!["startGameRequest"] as? Bool
                if startGameRequest != nil && startGameRequest! {
                    self.performSegue(withIdentifier: self.loadingSegue, sender: self)
                }
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
    
    func loadGameButtons() {
        let verticalGap = 20, iconWidth = 80, startingXPos = 20, startingYPos = 20, maxCol = 4
        let realViewWidth = Int(gameScrollView.frame.size.width) - startingXPos * 2
        let horizontalGap = (realViewWidth - maxCol * iconWidth) / (maxCol - 1)
        
        var x = startingXPos, y = startingYPos, col = 0
        
        for index in 0..<GameCollection.singleton.games.count {
            let game = GameCollection.singleton.games[index]
            let button = UIButton(type: .custom) as UIButton
            if col == maxCol {
                col = 0
                y += verticalGap + iconWidth
                x = startingXPos
            }
            button.frame = CGRect(x: x, y: y, width: iconWidth, height: iconWidth)
            button.setImage(game.gameIconImage, for: .normal)
            button.tag = index
            gameScrollView.addSubview(button)
            x += horizontalGap + iconWidth
            col += 1
            button.addTarget(self, action: #selector(pressedGameIcon), for: .touchUpInside)
            gameButtons.append(button)
        }
    }
    
    @objc func pressedGameIcon (sender: UIButton!) {
        print(sender.tag)
        if user.identity == 0 {
            let alertController = UIAlertController(title: nil,
                                                    message: "You cannot select the game.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        resetAllIcon()
        selectIcon(currentSelected: sender.tag)
        updateGameSelectedLabel(currentSelected: sender.tag)
        self.roomRef.updateData([
            "currentGameSelected": sender.tag
        ])
        currentSelectedButtonIndex = sender.tag
    }
    
    func resetAllIcon() {
        for button in gameButtons {
            button.layer.borderWidth = 0
        }
    }
    
    func selectIcon(currentSelected: Int!) {
        gameButtons[currentSelected].layer.borderWidth = 5
        gameButtons[currentSelected].layer.cornerRadius = 15
        gameButtons[currentSelected].layer.borderColor = UIColor.yellow.cgColor
    }
    
    func updateGameSelectedLabel(currentSelected: Int!) {
        gameSelectedLabel.text = "Current Selected: \(GameCollection.singleton.games[currentSelected].name)"
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
        if currentSelectedButtonIndex != -1 {
            self.roomRef.updateData([
                "startGameRequest": true
            ])
            self.performSegue(withIdentifier: self.loadingSegue, sender: self)
        } else {
            let alertController = UIAlertController(title: nil,
                                                    message: "You should select a game first.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController, animated: true, completion: nil)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == loadingSegue {
            (segue.destination as! LoadingViewController).roomRef = roomRef
            (segue.destination as! LoadingViewController).gameSelectedIndex = currentSelectedButtonIndex
            (segue.destination as! LoadingViewController).currentUser = user
        }
    }
}
