//
//  CountTo21ViewController.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 2/3/21.
//

import UIKit

class CountTo21ViewController: UIViewController {
    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet weak var gameStateLabel: UILabel!
    @IBOutlet weak var addOneButton: UIButton!
    @IBOutlet weak var addTwoButton: UIButton!
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    @IBOutlet weak var currentNumberLabel: UILabel!
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    var isCurrentUserTurn: Bool!
    var isWin = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        RoundCornerFactory.shared.setCornerAndBorder(view: gameBoardView, cornerRadius: 15, borderWidth: 10, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(button: addOneButton, cornerRadius: 5, borderWidth: 1, borderColor: UIColor.black.cgColor)
        RoundCornerFactory.shared.setCornerAndBorder(button: addTwoButton, cornerRadius: 5, borderWidth: 1, borderColor: UIColor.black.cgColor)
        
        self.gameStateLabel.text = isHost ? "Your Turn" : "Waiting for the other player..."
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue
        
        GameDataManager.shared.setReference(roomId: roomId, gameName: kCountTo21GameName)
        RoomManager.shared.setReference(roomId: roomId)
        
        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kCountTo21GameName)
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
    
    func updateView() {
        if let isHostTurn = GameDataManager.shared.getDataWithField(fieldName: kKeyIsHostTurn) as? Bool {
            if let currentNumber = GameDataManager.shared.getDataWithField(fieldName: kKeyCountTo21_currentNumber) as? Int {
                isCurrentUserTurn = isHostTurn == isHost
                gameStateLabel.text = isCurrentUserTurn ? "Your Turn" : "Waiting for the other player..."
                currentNumberLabel.text = String(currentNumber)
                let red = CGFloat(currentNumber)/21.0
                currentNumberLabel.backgroundColor = UIColor(red: red, green: 1 - red, blue: 0, alpha: 1)
                setButtonAvailable(value: isCurrentUserTurn)
                if let isGameEnd = GameDataManager.shared.getDataWithField(fieldName: kKeyIsGameEnd) as? Bool {
                    if isGameEnd {
                        let message = isWin ? "You Win!" : "You Lose!"
                        popResultMessage(message: message)
                        GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: false)
                    }
                }
            }
        }
    }
    
    @IBAction func pressedAddOneButton(_ sender: Any) {
        if let currentNumber = GameDataManager.shared.getDataWithField(fieldName: kKeyCountTo21_currentNumber) as? Int {
            if (1 + currentNumber) > 21 {
                return
            }
            GameDataManager.shared.updateDataWithField(fieldName: kKeyCountTo21_currentNumber, value: 1 + currentNumber)
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsHostTurn, value: !isHost)
            if (1 + currentNumber) == 21 {
                isWin = true
                GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: true)
            }
        }
    }
    
    @IBAction func pressedAddTwoButton(_ sender: Any) {
        if let currentNumber = GameDataManager.shared.getDataWithField(fieldName: kKeyCountTo21_currentNumber) as? Int {
            if (2 + currentNumber) > 21 {
                return
            }
            GameDataManager.shared.updateDataWithField(fieldName: kKeyCountTo21_currentNumber, value: 2 + currentNumber)
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsHostTurn, value: !isHost)
            if (2 + currentNumber) == 21 {
                isWin = true
                GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: true)
            }
        }
    }
    
    func setButtonAvailable(value: Bool) {
        addOneButton.isEnabled = value
        addTwoButton.isEnabled = value
    }
    
    func popResultMessage (message: String) {
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: message, confirmTitle: "OK") {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
}
