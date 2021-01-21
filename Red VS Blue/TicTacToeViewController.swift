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
    
    var roomRef: DocumentReference!
    var roomListener: ListenerRegistration!
    
    var xImage = #imageLiteral(resourceName: "iPhone_X.png")
    var oImage = #imageLiteral(resourceName: "iPhone_O.png")
    
    var user: User!
    var game: TicTacToeGame!
        
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
        
        self.roomRef.updateData([
            "tictactoe_isHostTurn": true,
            "startGameRequest": false,
            "tictactoe_lastPressed": -1
        ])
        
//        updateView()
        self.gameStateLabel.text = user.identity == 1 ? "Your Turn" : "Waiting for the other player..."
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
                let isCurrentUserTurn = isHostTurn == (self.user.identity == 1)
                self.gameStateLabel.text = isCurrentUserTurn ? "Your Turn" : "Waiting for the other player..."
                let lastPressed = documentSnapshot.data()!["tictactoe_lastPressed"] as? Int
                if lastPressed != nil && lastPressed != -1 {
                    if isCurrentUserTurn {
                        self.game.pressedSquareAt(lastPressed!)
                    }
                }
                self.updateView()
                if self.game.state == .oWin {
                    if self.user.identity == 0 {
                        self.popResultMessage(message: "You Win!")
                        self.user.score = self.user.score + 1
                    } else if self.user.identity == 1 {
                        self.popResultMessage(message: "You Lose!")
                    }
                } else if self.game.state == .xWin {
                    if self.user.identity == 0 {
                        self.popResultMessage(message: "You Lose!")
                    } else if self.user.identity == 1 {
                        self.user.score = self.user.score + 1
                        self.popResultMessage(message: "You Win!")
                    }
                } else if self.game.state == .tie {
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
        
        roomRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("error getting roomRef: \(error)")
                return
            }
            let isHostTurn = documentSnapshot?.data()!["tictactoe_isHostTurn"] as! Bool
            let isCurrentUserTurn = isHostTurn == (self.user.identity == 1)
            if !isCurrentUserTurn {
                self.popAlertMessage(message: "It's not your turn")
            } else {
                if !self.game.pressedSquareAt(button.tag) {
                    let alertController = UIAlertController(title: nil,
                                                            message: "This square is not empty or the game is over",
                                                            preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK",
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.roomRef.updateData([
                        "tictactoe_lastPressed": button.tag,
                        "tictactoe_isHostTurn": !isHostTurn
                    ])
                }
                
            }
        }
        print(game.getBoardString())

//        updateView()
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
