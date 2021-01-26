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
    var isGameEnded: Bool!
    
    let kKeyTicTacToe_isHostTurn = "0_tictactoe_isHostTurn"
    let kKeyTicTacToe_lastPressed = "0_tictactoe_lastPressed"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        isGameEnded = false
        game = TicTacToeGame()
        
        gameBoardView.layer.cornerRadius = 15
        gameBoardView.layer.borderWidth = 10
        gameBoardView.layer.borderColor = UIColor.black.cgColor
        
        self.gameStateLabel.text = RoomManager.shared.isHost ? "Your Turn" : "Waiting for the other player..."
        self.upperBannerView.backgroundColor = RoomManager.shared.isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = RoomManager.shared.isHost ? UIColor.red: UIColor.blue
        
        if true {
            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyTicTacToe_isHostTurn, value: true)
            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyTicTacToe_lastPressed, value: -1)
        }
        RoomManager.shared.beginListeningForTheRoom(id: RoomManager.shared.roomId, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
    }
    
    func updateView() {
        let isHostTurn = RoomManager.shared.getDataWithField(fieldName: kKeyTicTacToe_isHostTurn) as! Bool
        isCurrentUserTurn = isHostTurn == RoomManager.shared.isHost
        gameStateLabel.text = self.isCurrentUserTurn ? "Your Turn" : "Waiting for the other player..."
        
        if RoomManager.shared.isHost {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
            opponentNameLabel.text = RoomManager.shared.clientUserName! + ": O"
            yourScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
            yourNameLabel.text = RoomManager.shared.hostUserName + ": X"
        } else {
            opponentScoreLabel.text = "Score: \(RoomManager.shared.hostScore)"
            opponentNameLabel.text = RoomManager.shared.hostUserName + ": X"
            yourScoreLabel.text = "Score: \(RoomManager.shared.clientScore)"
            yourNameLabel.text = RoomManager.shared.clientUserName! + ": O"
        }
        
        let lastPressed = RoomManager.shared.getDataWithField(fieldName: kKeyTicTacToe_lastPressed) as! Int
        if lastPressed != -1 && isCurrentUserTurn {
            _ = game.pressedSquareAt(lastPressed)
        }
        updateGameView()
        
        if isGameEnded {
            return
        }
        
        switch self.game.state {
        case .xTurn, .oTurn: break
        case .xWin:
            isGameEnded = true
            self.popResultMessage(message: RoomManager.shared.isHost ? "You Win!" : "You Lose!")
            RoomManager.shared.score += RoomManager.shared.isHost ? 1 : 0
        case .oWin:
            isGameEnded = true
            self.popResultMessage(message: !RoomManager.shared.isHost ? "You Win!" : "You Lose!")
            RoomManager.shared.score += !RoomManager.shared.isHost ? 1 : 0
        case .tie:
            isGameEnded = true
            self.popResultMessage(message: "Tie Game!")
        }
    }
    
    @IBAction func pressedGameBoardButton(_ sender: Any) {
        let button = sender as! UIButton
        if !isCurrentUserTurn {
            self.popAlertMessage(message: "It's not your turn")
        } else {
            if !game.pressedSquareAt(button.tag) {
                let alertController = UIAlertController(title: nil,
                                                        message: "This square is not empty or the game is over",
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "OK",
                                                        style: .cancel,
                                                        handler: nil))
                
                present(alertController, animated: true, completion: nil)
            } else {
                RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyTicTacToe_lastPressed, value: button.tag)
                RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyTicTacToe_isHostTurn, value: !RoomManager.shared.isHost)
            }
        }
        print(game.getBoardString())
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
        let alertController = UIAlertController(title: nil,
                                                message: "It's not your turn",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .cancel,
                                                handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func popResultMessage (message: String) {
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default)
        { (action) in
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
}
