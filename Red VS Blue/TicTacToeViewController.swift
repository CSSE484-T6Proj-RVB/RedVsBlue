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
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    var xImage = #imageLiteral(resourceName: "TicTacToe_X.PNG")
    var oImage = #imageLiteral(resourceName: "TicTacToe_O.PNG")
    
    var user: User!
    var game: TicTacToeGame!
    
    var isCurrentUserTurn: Bool!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        game = TicTacToeGame()
        
        gameBoardView.layer.cornerRadius = 15
        gameBoardView.layer.borderWidth = 10
        gameBoardView.layer.borderColor = UIColor.black.cgColor
        
        self.gameStateLabel.text = user.identity == 1 ? "Your Turn" : "Waiting for the other player..."
        self.upperBannerView.backgroundColor = user.identity == 0 ? UIColor.red: UIColor.blue
        self.lowerBannerView.backgroundColor = user.identity == 0 ? UIColor.blue: UIColor.red
        
        self.roomRef.updateData([
            "startGameRequest": false,
            "tictactoe_isHostTurn": true,
            "tictactoe_lastPressed": -1
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
                print(documentSnapshot)
                let isHostTurn = documentSnapshot.data()!["tictactoe_isHostTurn"] as! Bool
                self.isCurrentUserTurn = isHostTurn == (self.user.identity == 1)
                self.gameStateLabel.text = self.isCurrentUserTurn ? "Your Turn" : "Waiting for the other player..."
                
                let lastPressed = documentSnapshot.data()!["tictactoe_lastPressed"] as? Int
                if lastPressed != nil && lastPressed != -1 {
                    if self.isCurrentUserTurn {
                        _ = self.game.pressedSquareAt(lastPressed!)
                    }
                }
                self.updateView()
                
                switch self.game.state {
                case .xTurn, .oTurn: break
                    // Continue
                case .xWin:
                    self.popResultMessage(message: self.user.identity == 1 ? "You Win!" : "You Lose!")
                    self.user.score = self.user.identity == 1 ? self.user.score + 1 : self.user.score
                case .oWin:
                    self.popResultMessage(message: self.user.identity == 0 ? "You Win!" : "You Lose!")
                    self.user.score = self.user.identity == 0 ? self.user.score + 1 : self.user.score
                case .tie:
                    self.popResultMessage(message: "Tie Game!")
                }
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
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
                self.roomRef.updateData([
                    "tictactoe_lastPressed": button.tag,
                    "tictactoe_isHostTurn": user.identity == 0
                ])
            }
        }
        print(game.getBoardString())
    }
    
    func updateView() {
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
