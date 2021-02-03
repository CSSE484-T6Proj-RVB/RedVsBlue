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
    
    @IBOutlet weak var testButton: UIButton!
    
    @IBOutlet weak var gameSelectedLabel: UILabel!
    @IBOutlet weak var hostScoreLabel: UILabel!
    @IBOutlet weak var clientScoreLabel: UILabel!
    
    @IBOutlet weak var clientWaitingLabel: UILabel!
    @IBOutlet weak var hostGoButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    var gameButtons: [UIButton] = []
    var currentSelectedButtonIndex: Int =  -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadGameButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        RoomManager.shared.setReference(roomId: RoomStatusStorage.shared.roomId)
        RoomManager.shared.beginListening(changeListener: updateRoomData)
        UsersManager.shared.beginListening(changeListener: updateNameAndBio)
        if RoomStatusStorage.shared.isHost {
            hostGoButton.isHidden = false
            clientWaitingLabel.isHidden = true
        } else {
            hostGoButton.isHidden = true
            clientWaitingLabel.isHidden = false
        }
        
        RoomManager.shared.updateDataWithField(fieldName: RoomStatusStorage.shared.isHost ? kKeyHostScore : kKeyClientScore, value: RoomStatusStorage.shared.score)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
        UsersManager.shared.stopListening()
    }
    
    func updateNameAndBio() {
        let hostId = RoomManager.shared.hostId
        let clientId = RoomManager.shared.clientId!
        let hostBio = UsersManager.shared.getBioWithId(uid: hostId)
        let clientBio = UsersManager.shared.getBioWithId(uid: clientId)
        hostNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
        hostBioLabel.text = hostBio == "" ? "This player has no bio." : hostBio
        clientNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
        clientBioLabel.text = clientBio == "" ? "This player has no bio." : clientBio
    }
    
    func updateRoomData() {

        hostScoreLabel.text = String(RoomManager.shared.hostScore)

        clientScoreLabel.text = String(RoomManager.shared.clientScore)
        
        
        if let currentGameSelected = RoomManager.shared.currentGameSelected {
            if !RoomStatusStorage.shared.isHost {
                resetAllIcon()
                selectIcon(currentSelected: currentGameSelected)
                updateGameSelectedLabel(currentSelected: currentGameSelected)
                currentSelectedButtonIndex = currentGameSelected
            }
        }
        if let _ = RoomManager.shared.endGameRequest {
            
            AlertDialog.showAlertDialog(viewController: self, title: "Game Ended",
                                        message: "The other player has left!",
                                        confirmTitle: "OK") {
                RoomsManager.shared.deleteRoom(id: RoomStatusStorage.shared.roomId)
                if RoomManager.shared.clientScore + RoomManager.shared.hostScore == 0 {
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                self.performSegue(withIdentifier: resultViewSegueIdentifier, sender: self)
            }
        }
        if let startRequest = RoomManager.shared.startGameRequest {
            if startRequest {
                self.performSegue(withIdentifier: loadingSegueIdentifier, sender: self)
            }
        }
    }
    
    func loadGameButtons() {
        let verticalGap = 20, iconWidth = 80, startingXPos = 20, startingYPos = 20, minimumHorizontalGap = 5
        let realViewWidth = Int(UIScreen.main.bounds.width) - startingXPos * 2
        let maxCol = Int(realViewWidth / (iconWidth + minimumHorizontalGap))
        let horizontalGap = (realViewWidth - maxCol * iconWidth) / (maxCol - 1)
        
        var x = startingXPos, y = startingYPos, col = 0
                
        for index in 0 ..< GameCollection.shared.games.count {
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
            scrollView.addSubview(button)
            x += horizontalGap + iconWidth
            col += 1
            button.addTarget(self, action: #selector(pressedGameIcon), for: .touchUpInside)
            gameButtons.append(button)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(realViewWidth), height: CGFloat(y + verticalGap + iconWidth))
    }
    
    @objc func pressedGameIcon (sender: UIButton!) {
        if !RoomStatusStorage.shared.isHost {
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
        RoomManager.shared.updateCurrentGameSelected(id: sender.tag)
        currentSelectedButtonIndex = sender.tag
    }
    
    func resetAllIcon() {
        for button in gameButtons {
            button.layer.borderWidth = 0
        }
    }
    
    func selectIcon(currentSelected: Int!) {
        RoundCornerFactory.shared.setCornerAndBorder(button: gameButtons[currentSelected], cornerRadius: 15, borderWidth: 5, borderColor: UIColor.yellow.cgColor)
    }
    
    func updateGameSelectedLabel(currentSelected: Int!) {
        gameSelectedLabel.text = "Current Selected: \(GameCollection.shared.games[currentSelected].name)"
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
//        // TODO: Make sure the player has gone back
        if currentSelectedButtonIndex != -1 {
            RoomManager.shared.setStartGameRequest(value: true)
        } else {
            AlertDialog.showAlertDialog(viewController: self, title: nil,
                                        message: "You should select a game first.",
                                        confirmTitle: "OK", finishHandler: nil)
        }
    }
    
    
    @IBAction func pressedLeaveButton(_ sender: Any) {
        AlertDialog.showAlertDialog(viewController: self, title: nil,
                                    message: "Are you sure you want to leave the game?",
                                    confirmTitle: "Confirm") {
            RoomManager.shared.setEndGameRequest(value: true)
            if RoomManager.shared.clientScore + RoomManager.shared.hostScore == 0 {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
            self.performSegue(withIdentifier: resultViewSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == loadingSegueIdentifier {
            (segue.destination as! LoadingViewController).gameSelectedIndex = currentSelectedButtonIndex == GameCollection.shared.games.count - 1 ? Int.random(in: 0..<GameCollection.shared.games.count - 1) : currentSelectedButtonIndex
        } else if segue.identifier == resultViewSegueIdentifier {
            (segue.destination as! ResultViewController).clientScore = RoomManager.shared.clientScore
            (segue.destination as! ResultViewController).hostScore = RoomManager.shared.hostScore
        }
    }
}
