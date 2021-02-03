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
    
    var isWin = false
    
    var puzzle = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    let size = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
                
        gameBoardView.layer.cornerRadius = 15
        gameBoardView.layer.borderWidth = 10
        gameBoardView.layer.borderColor = UIColor.black.cgColor
        
        self.upperBannerView.backgroundColor = isHost ? UIColor.blue: UIColor.red
        self.lowerBannerView.backgroundColor = isHost ? UIColor.red: UIColor.blue

        GameDataManager.shared.setReference(roomId: roomId, gameName: kNumberPuzzleGameName)

        RoomManager.shared.setReference(roomId: roomId)
        
        if isHost {
            GameDataManager.shared.createDocument(roomId: roomId, gameName: kNumberPuzzleGameName)
        }
        
        RoomManager.shared.beginListening(changeListener: updateScoreLabel) // Score and ids
        UsersManager.shared.beginListening(changeListener: updateNameAndBio) // Name and bio
        GameDataManager.shared.beginListening(changeListener: updateView) // gamedata
        shuffle()
        updatePuzzle()
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
        if canMove(index: index) {
            swap(firstIndex: index, secondIndex: getEmptyIndex())
        }
        updatePuzzle()
        if checkWin() {
            print("You win")
        }
    }
    
    func updateView() {
        if let isHostTurn = GameDataManager.shared.getDataWithField(fieldName: kKeyIsHostTurn) as? Bool {
        }
    }
    
    func updatePuzzle() {
        for button in gameBoardButtons {
            let currentDisplayedNumber = puzzle[button.tag]
            button.setTitle(currentDisplayedNumber == 15 ? "" : "\(currentDisplayedNumber + 1)", for: .normal)
        }
        print(getPuzzleArray())
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
    
    func getPuzzleArray() -> [Int] {
        var gameArray = [Int]()
        for index in 0 ..< size * size {
            gameArray.append(puzzle[index] + 1)
        }
        return gameArray
    }
    
    func swap(firstIndex: Int, secondIndex: Int) {
        let firstValue = puzzle[firstIndex]
        puzzle[firstIndex] = puzzle[secondIndex]
        puzzle[secondIndex] = firstValue
    }
    
    func canMove(index: Int) -> Bool {
        return validClickPositions().contains(index)
    }
    
    func validClickPositions() -> [Int] {
        let emptyIndex = getEmptyIndex()
        var validPositions = [Int]()

        if emptyIndex > 3 {
            validPositions.append(emptyIndex - 4)
        }
        
        if emptyIndex < 12 {
            validPositions.append(emptyIndex + 4)
        }
        
        if emptyIndex % size != 0 {
            validPositions.append(emptyIndex - 1)
        }
        
        if emptyIndex % size != 3 {
            validPositions.append(emptyIndex + 1)
        }
        
        return validPositions
    }
    
    func getEmptyIndex() -> Int {
        for index in 0 ..< size * size {
            if puzzle[index] == 15 {
                return index
            }
        }
        return -1
    }
    
    func shuffle() {
        let times = Int.random(in: 0 ... 200) + 100
        for _ in 0 ... times {
            let arr = validClickPositions()
            let index = Int.random(in: 0 ..< arr.count)
            swap(firstIndex: arr[index], secondIndex: getEmptyIndex())
        }
    }
    
    func checkWin() -> Bool {
        for button in gameBoardButtons {
            if puzzle[button.tag] != button.tag {
                return false
            }
        }
        return true
    }
}
