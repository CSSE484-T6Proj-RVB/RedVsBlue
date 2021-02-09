//
//  HangmanViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/3.
//

import UIKit

class HangmanViewController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet weak var upperBannerView: UIView!
    @IBOutlet weak var lowerBannerView: UIView!
    
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    
    @IBOutlet weak var yourScoreLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    
    @IBOutlet weak var letterStatusStackView: UIStackView!
    @IBOutlet weak var opponentLetterStatusStackView: UIStackView!
    
    @IBOutlet weak var hangmanImageView: UIImageView!
    
    @IBOutlet var letterButtons: [UIButton]!
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    let score = RoomStatusStorage.shared.score
    
    var imgMap = [
        6: #imageLiteral(resourceName: "Hangman-0.png"),
        5: #imageLiteral(resourceName: "Hangman-1.png"),
        4: #imageLiteral(resourceName: "Hangman-2.png"),
        3: #imageLiteral(resourceName: "Hangman-3.png"),
        2: #imageLiteral(resourceName: "Hangman-4.png"),
        1: #imageLiteral(resourceName: "Hangman-5.png"),
        0: #imageLiteral(resourceName: "Hangman-6.png")
    ]
    var word: String!
    var game: HangmanGame!
    
    var isWin: Bool!
    var dieFirst: Bool!
    var isBothDie: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        isWin = false
        dieFirst = false
        isBothDie = false
        game = HangmanGame()
        word = ""
        
        loadingView.isHidden = false
        
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue
        
        //removeAllArrangedSubviews(stackView: letterStatusStackView)
        //        for index in 0..<letterStatusStackView.arrangedSubviews.count {
        //            changeStackViewLabel(stackView: letterStatusStackView.arrangedSubviews[index] as! UIStackView, letter: String(Array(word)[index]))
        //        }
        
        GameDataManager.shared.setReference(roomId: roomId, gameName: kHangmanGameName)
        RoomManager.shared.setReference(roomId: roomId)
        
        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kHangmanGameName)
            GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_word, value: RandomStringGenerator.shared.generateRandomHangmanWord())
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
//        if let isBothDie = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_isBothDie) as? Bool {
//            if isBothDie {
//                RoomStatusStorage.shared.score += dieFirst ? 1 : 0
//            } else {
//                  RoomStatusStorage.shared.score += isWin ? 1 : 0
//            }
//        }
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
        if !loadingView.isHidden {
            guard let word = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_word) as? String else {
                return
            }
            if word == "" { return }
            self.word = word
            game.setWord(word: word)
            for _ in 0..<word.count {
                letterStatusStackView.addArrangedSubview(generateOneLetterStackView(fontSize: 30))
                // TODO For opponent, don't append letters anymore
                opponentLetterStatusStackView.addArrangedSubview(generateOneLetterStackView(fontSize: 20))
            }
            loadingView.isHidden = true
            GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_hostStatus, value: game.status!)
            GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_clientStatus, value: game.status!)
        }
        
        if RoomStatusStorage.shared.isHost {
            if let status = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_clientStatus) as? [Bool] {
                updateOpponentStatusView(status: status)
            }
        } else {
            if let status = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_hostStatus) as? [Bool] {
                updateOpponentStatusView(status: status)
            }
        }
        
        
        guard let isGameEnd = GameDataManager.shared.getDataWithField(fieldName: kKeyIsGameEnd) as? Bool else {
            return
        }
        if isGameEnd {
            let message = isWin ? "You Win!" : "You Lose!"
            popResultMessage(message: message)
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: false)
        }
        
        guard let isClientDie = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_isClientDie) as? Bool else {
            return
        }
        guard let isHostDie = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_isHostDie) as? Bool else {
            return
        }
        if isClientDie && isHostDie {
            popResultMessage(message: "Both Players Failed!")
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: false)
        }
    }
    
    @IBAction func pressedLetterButton(_ sender: Any) {
        if game.isDead() {
            AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: "You have no lives left", confirmTitle: "OK", finishHandler: nil)
            return
        }
        let button = sender as! UIButton
        let tag = button.tag
        if game.pressedLetter(letter: Character(UnicodeScalar(UnicodeScalar("a").value + UInt32(tag))!)) {
            button.setTitle(" ", for: .normal)
            if isHost {
                GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_hostStatus, value: game.status!)
            } else {
                GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_clientStatus, value: game.status!)
            }
        }
        updateGameView()
        if game.checkWin() {
            isWin = true
            GameDataManager.shared.updateDataWithField(fieldName: kKeyIsGameEnd, value: true)
        }
        
        if game.isDead() {
            guard let _ = GameDataManager.shared.getDataWithField(fieldName: kKeyHangman_isHostDie) as? Bool else {
                return
            }
            if RoomStatusStorage.shared.isHost {
                GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_isHostDie, value: true)
            } else {
                GameDataManager.shared.updateDataWithField(fieldName: kKeyHangman_isClientDie, value: true)
            }
        }
    }
    
    func updateOpponentStatusView(status: [Bool]) {
        for index in 0..<opponentLetterStatusStackView.arrangedSubviews.count {
            changeStackViewLabel(stackView: opponentLetterStatusStackView.arrangedSubviews[index] as! UIStackView,
                                 letter: status[index] ? "1" : "0")
        }
        // TODO: ? and Check Icons
    }
    
    func updateGameView() {
        for index in 0..<letterStatusStackView.arrangedSubviews.count {
            changeStackViewLabel(stackView: letterStatusStackView.arrangedSubviews[index] as! UIStackView,
                                 letter: game.status[index] ? String(Array(word)[index]).uppercased() : " ")
        }
        hangmanImageView.image = imgMap[game.lives]
    }
    
    func removeAllArrangedSubviews(stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
    }
    
    func generateOneLetterStackView(fontSize: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill // .leading .firstBaseline .center .trailing .lastBaseline
        stackView.distribution = .fill // .fillEqually .fillProportionally .equalSpacing .equalCentering
        stackView.spacing = 1
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.text = " "
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
        
        let underscoreLabel = UILabel()
        underscoreLabel.text = "‾‾‾"
        underscoreLabel.textColor = UIColor.black
        underscoreLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        stackView.addArrangedSubview(underscoreLabel)
        
        return stackView
    }
    
    func changeStackViewLabel(stackView: UIStackView, letter: String) {
        let label = stackView.arrangedSubviews[0] as! UILabel
        label.text = letter
    }
    
    func popResultMessage (message: String) {
        AlertDialog.showAlertDialogWithoutCancel(viewController: self, title: nil, message: message, confirmTitle: "OK") {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
}
