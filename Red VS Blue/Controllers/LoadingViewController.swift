//
//  LoadingViewController.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 1/21/21.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var selectedGameIcon: UIImageView!
    @IBOutlet weak var selectedGameLabel: UILabel!
    @IBOutlet weak var selectedGameDescription: UITextView!
    
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var hostBioLabel: UILabel!
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientBioLabel: UILabel!
    
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var readyMessageLabel: UILabel!
    
    var isReady = false
    var gameSelectedIndex: Int!
    var gameSegueIdentifiers: [String] = []
    
    let kKeyHostReady = "hostReady"
    let kKeyClientReady = "clientReady"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        for game in GameCollection.shared.games {
            gameSegueIdentifiers.append(game.segueName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        selectedGameDescription.layer.cornerRadius = 15
        selectedGameDescription.layer.borderWidth = 2
        
        let game =  GameCollection.shared.games[gameSelectedIndex]
        self.selectedGameIcon.image = game.gameIconImage
        self.selectedGameLabel.text = game.name
        self.selectedGameDescription.text = game.description
        self.readyMessageLabel.isHidden = true
        self.isReady = false
        
//        RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyHostReady, value: false)
//        RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyClientReady, value: false)
//
//        RoomManager.shared.beginListeningForTheRoom(id: RoomManager.shared.roomId, changeListener: updateView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
    }
    
    func updateView() {
//        let hostBio = RoomManager.shared.hostUserBio
//        let clientBio = RoomManager.shared.clientUserBio
//        hostNameLabel.text = RoomManager.shared.hostUserName
//        hostBioLabel.text = hostBio == "" ? "This player has no bio." : hostBio
//        clientNameLabel.text = RoomManager.shared.clientUserName
//        clientBioLabel.text = clientBio == "" ? "This player has no bio." : clientBio
//        let hostReady = RoomManager.shared.hostReady
//        let clientReady = RoomManager.shared.clientReady
//        if hostReady && clientReady {
//            performSegue(withIdentifier: self.gameSegueIdentifiers[self.gameSelectedIndex], sender: self)
//        }
    }
    
    @IBAction func pressedReadyButton(_ sender: Any) {
        isReady = !isReady
        readyButton.backgroundColor = isReady ? UIColor.red : UIColor.green
        readyButton.setTitle(isReady ? "Cancel" : "Ready!", for: .normal)
        readyMessageLabel.isHidden = !isReady
//        if RoomManager.shared.isHost {
//            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyStartGameRequest, value: false)
//            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyHostReady, value: isReady)
//        } else {
//            RoomManager.shared.updateDataWithField(id: RoomManager.shared.roomId, fieldName: kKeyClientReady, value: isReady)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TicTacToeGameSegue" {
//            (segue.destination as! TicTacToeViewController).roomRef = roomRef
//            (segue.destination as! TicTacToeViewController).user = currentUser
            //(segue.destination as! TicTacToeViewController).game = GameCollection.singleton.games[self.gameSelectedIndex]
        }
    }
    
}
