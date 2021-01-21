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
        
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roomListener.remove()
    }
    
    func startListening() {
        roomListener = roomRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                print(documentSnapshot)
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
    }
    
    @IBAction func pressedGameBoardButton(_ sender: Any) {
        let button = sender as! UIButton
        game.pressedSquareAt(button.tag)
        updateView()
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
    
}
