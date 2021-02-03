//
//  NumberPuzzleViewController.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 2/3/21.
//

import UIKit

class NumberPuzzleViewController: UIViewController {
    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet var gameBoardButtons: [UIButton]!
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    var isWin: Bool!
    var game: NumberPuzzleGame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        game = NumberPuzzleGame()
        gameBoardView.isHidden = true
        isWin = false
        RoundCornerFactory.shared.setCornerAndBorder(view: gameBoardView, cornerRadius: 15, borderWidth: 10, borderColor: UIColor.black.cgColor)
        
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue
        
        GameDataManager.shared.setReference(roomId: roomId, gameName: kNumberPuzzleGameName)
        RoomManager.shared.setReference(roomId: roomId)
        
        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kNumberPuzzleGameName)
            game.shuffle()
            GameDataManager.shared.updateDataWithField(fieldName: kKeyNumberPuzzle_puzzle, value: game.puzzle)
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
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
        } else {
            opponentNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
            yourNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
        }
    }
    
    @IBAction func pressedPuzzleButton(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag
        game.pressedButtonAtIndex(index: index)
        updatePuzzle()
        if checkWin() {
            isWin = true
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: true)
        }
    }
    
    func updateView() {
        if let puzzle = GameDataManager.shared.getDataWithField(fieldName: kKeyNumberPuzzle_puzzle) as? [Int] {
            game.puzzle = puzzle
            updatePuzzle()
            gameBoardView.isHidden = false
        }
        if let isGameEnd = GameDataManager.shared.getDataWithField(fieldName: kKeyIsGameEnd) as? Bool {
            if isGameEnd {
                let message = isWin ? "You Win!" : "You Lose!"
                popResultMessage(message: message)
                GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: false)
            }
        }
    }
    
    func updatePuzzle() {
        for button in gameBoardButtons {
            let currentDisplayedNumber = game.puzzle[button.tag]
            button.setTitle(currentDisplayedNumber == 15 ? "" : "\(currentDisplayedNumber + 1)", for: .normal)
        }
    }
    
    func popResultMessage (message: String) {
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: message, confirmTitle: "OK") {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    func checkWin() -> Bool {
        for button in gameBoardButtons {
            if game.puzzle[button.tag] != button.tag {
                return false
            }
        }
        return true
    }
}
