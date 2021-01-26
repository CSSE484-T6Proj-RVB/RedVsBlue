//
//  GameSelectionViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import UIKit

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
    
    var gameButtons: [UIButton] = []
    var currentSelectedButtonIndex: Int =  -1
    
    let resultViewSegueIdentifier = "ResultViewSegue"
    let loadingSegueIdentifier = "LoadingSegue"
    
    let kKeyGameSelected = "currentGameSelected"
    let kKeyEndGameRequest = "endGameRequest"
    let kKeyStartGameRequest = "startGameRequest"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadGameButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        //UserManager.shared.beginListeningForSingleUser(uid: Auth.auth().currentUser!.uid, changeListener: nil)
        if RoomManager.shared.isHost {
            hostGoButton.isHidden = false
            clientWaitingLabel.isHidden = true
        } else {
            hostGoButton.isHidden = true
            clientWaitingLabel.isHidden = false
        }
        
//        if user.identity == 1 {
//            self.roomRef.updateData([
//                "hostScore": user.score
//            ])
//        } else if user.identity == 0 {
//            self.roomRef.updateData([
//                "clientScore": user.score
//            ])
//        }
        RoomManager.shared.beginListeningForTheRoom(id: RoomManager.shared.roomId, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
    }
    
    func updateView() {
        let hostBio = RoomManager.shared.hostUserBio
        let clientBio = RoomManager.shared.clientUserBio
        hostNameLabel.text = RoomManager.shared.hostUserName
        hostBioLabel.text = hostBio == "" ? "This player has no bio." : hostBio
        hostScoreLabel.text = String(RoomManager.shared.hostScore)
        clientNameLabel.text = RoomManager.shared.clientUserName
        clientBioLabel.text = clientBio == "" ? "This player has no bio." : clientBio
        clientScoreLabel.text = String(RoomManager.shared.clientScore)
        if let currentGameSelected = RoomManager.shared.currentGameSelected {
            if !RoomManager.shared.isHost {
                resetAllIcon()
                selectIcon(currentSelected: currentGameSelected)
                updateGameSelectedLabel(currentSelected: currentGameSelected)
                currentSelectedButtonIndex = currentGameSelected
            }
        }
        if let _ = RoomManager.shared.endGameRequest {
            let alertController = UIAlertController(title: "Game Ended",
                                                    message: "The other player has left!",
                                                    preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .default)
            { (action) in
                RoomManager.shared.deleteRoom(id: RoomManager.shared.roomId)
                self.performSegue(withIdentifier: self.resultViewSegueIdentifier, sender: self)
            })
            
            present(alertController, animated: true, completion: nil)
        }
        if let _ = RoomManager.shared.startGameRequest {
            self.performSegue(withIdentifier: self.loadingSegueIdentifier, sender: self)
        }
    }
    
    func loadGameButtons() {
        let verticalGap = 20, iconWidth = 80, startingXPos = 20, startingYPos = 20, minimumHorizontalGap = 5
        let realViewWidth = Int(UIScreen.main.bounds.width) - startingXPos * 2
        let maxCol = Int(realViewWidth / (iconWidth + minimumHorizontalGap))
        let horizontalGap = (realViewWidth - maxCol * iconWidth) / (maxCol - 1)
        
        var x = startingXPos, y = startingYPos, col = 0
        
        for index in 0..<GameCollection.shared.games.count {
            let game = GameCollection.shared.games[index]
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
        if !RoomManager.shared.isHost {
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
        RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyGameSelected, value: sender.tag)
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
        gameSelectedLabel.text = "Current Selected: \(GameCollection.shared.games[currentSelected].name)"
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
        // TODO: Make sure the player has gone back
        if currentSelectedButtonIndex != -1 {
            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyStartGameRequest, value: true)
            self.performSegue(withIdentifier: self.loadingSegueIdentifier, sender: self)
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
            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: self.kKeyEndGameRequest, value: true)
            self.performSegue(withIdentifier: self.resultViewSegueIdentifier, sender: self)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == loadingSegueIdentifier {
//            (segue.destination as! LoadingViewController).roomRef = roomRef
            (segue.destination as! LoadingViewController).gameSelectedIndex = currentSelectedButtonIndex == GameCollection.shared.games.count - 1 ? Int.random(in: 0..<GameCollection.shared.games.count - 1) : currentSelectedButtonIndex
//            (segue.destination as! LoadingViewController).currentUser = user
        }
    }
}
