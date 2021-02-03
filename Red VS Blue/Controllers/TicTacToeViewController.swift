//
//  TicTacToeViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/21.
//

import UIKit
import Firebase

class TicTacToeViewController: UIViewController {
    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet var gameBoardButtons: [UIButton]!
    @IBOutlet weak var gameStateLabel: UILabel!
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    var xImage = #imageLiteral(resourceName: "TicTacToe_X.PNG")
    var oImage = #imageLiteral(resourceName: "TicTacToe_O.PNG")
    
    var game: TicTacToeGame!
    var isCurrentUserTurn: Bool!
    var isWin = false
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        game = TicTacToeGame()
        
        RoundCornerFactory.shared.setCornerAndBorder(view: gameBoardView, cornerRadius: 15, borderWidth: 10, borderColor: UIColor.black.cgColor)

        self.gameStateLabel.text = isHost ? "Your Turn" : "Waiting for the other player..."
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue

        GameDataManager.shared.setReference(roomId: roomId, gameName: kTicTacToeGameName)

        RoomManager.shared.setReference(roomId: roomId)
        
        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kTicTacToeGameName)
        }
        
        RoomManager.shared.beginListening(changeListener: updateScoreLabel) // Score and ids
        UsersManager.shared.beginListening(changeListener: updateNameAndBio) // Name and bio
        GameDataManager.shared.beginListening(changeListener: updateView) // gamedata
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isHost {
            GameDataManager.shared.deleteGameDocument()
        }
        RoomManager.shared.stopListening()
        UsersManager.shared.stopListening()
        GameDataManager.shared.stopListening()
        RoomStatusStorage.shared.score += isWin ? 1 : 0
    }
    
    func updateScoreLabel() {
        if isHost {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
            yourScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
        } else {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
            yourScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
        }
    }
    
    func updateNameAndBio() {
        let hostId = RoomManager.shared.hostId
        let clientId = RoomManager.shared.clientId!
        
        if isHost {
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId) + ": O"
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId) + ": X"
        } else {
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId) + ": X"
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId) + ": O"
        }
    }
    
    func updateView() {
        if let isHostTurn = GameDataManager.shared.getDataWithField(fieldName: kKeyIsHostTurn) as? Bool {
            isCurrentUserTurn = isHostTurn == isHost
            gameStateLabel.text = isCurrentUserTurn ? "Your Turn" : "Waiting for the other player..."

            let lastPressed = GameDataManager.shared.getDataWithField(fieldName: kKeyTicTacToe_lastPressed) as! Int
            if lastPressed != -1 && isCurrentUserTurn {
                _ = game.pressedSquareAt(lastPressed)
            }
            updateGameView()

            switch self.game.state {
            case .xTurn, .oTurn: break
            case .xWin:
                self.popResultMessage(message: isHost ? "You Win!" : "You Lose!")
                self.isWin = isHost
            case .oWin:
                self.popResultMessage(message: !isHost ? "You Win!" : "You Lose!")
                self.isWin = !isHost
            case .tie:
                self.isWin = false
                self.popResultMessage(message: "Tie Game!")
            }
        }
    }
    
    @IBAction func pressedGameBoardButton(_ sender: Any) {
        let button = sender as! UIButton
        if !isCurrentUserTurn {
            self.popAlertMessage(message: "It's not your turn")
        } else {
            if !game.pressedSquareAt(button.tag) {
                AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: "This square is not empty or the game is over", confirmTitle: "OK", finishHandler: nil)
            } else {
                GameDataManager.shared.updateDataWithField(fieldName: kKeyTicTacToe_lastPressed, value: button.tag)
                GameDataManager.shared.updateDataWithField(fieldName: kKeyIsHostTurn, value: !isHost)
            }
        }
        //print(game.getBoardString())
    }
    
    func updateGameView() {
        for button in gameBoardButtons {
            let buttonIndex = button.tag
            switch game.board[buttonIndex] {
            case .none:
                button.setImage(nil, for: UIControl.State.normal)
            case .x:
                button.setImage(xImage, for: .normal)
            case .o:
                button.setImage(oImage, for: .normal)
            }
        }
    }
    
    func popAlertMessage (message: String) {
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: "It's not your turn", confirmTitle: "OK", finishHandler: nil)
    }
    
    func popResultMessage (message: String) {
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: message, confirmTitle: "OK") {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
}
