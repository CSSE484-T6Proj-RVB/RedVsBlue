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
    
    let isHost = RoomStatusStorage.shared.isHost
    let roomId = RoomStatusStorage.shared.roomId
    
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
        
        RoundCornerFactory.shared.setCornerAndBorder(textView: selectedGameDescription, cornerRadius: 15, borderWidth: 2)
        
        let game =  GameCollection.shared.games[gameSelectedIndex]
        self.selectedGameIcon.image = game.gameIconImage
        self.selectedGameLabel.text = game.name
        self.selectedGameDescription.text = game.description
        self.readyMessageLabel.isHidden = true
        self.isReady = false
        
        RoomManager.shared.setReference(roomId: roomId)

        RoomManager.shared.updateDataWithField(fieldName: kKeyHostReady, value: false)
        RoomManager.shared.updateDataWithField(fieldName: kKeyClientReady, value: false)

        RoomManager.shared.beginListening(changeListener: updateView)
        UsersManager.shared.beginListening(changeListener: updateNameAndBio)
        updateNameAndBio()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
        UsersManager.shared.stopListening()
    }
    
    func updateNameAndBio() {
        let hostId = RoomManager.shared.hostId
        let clientId = RoomManager.shared.clientId!
        let hostBio = UsersManager.shared.getBioWithId(uid: hostId)
        let clientBio = UsersManager.shared.getBioWithId(uid: clientId)
        hostNameLabel.text = UsersManager.shared.getNameWithId(uid: hostId)
        hostBioLabel.text = hostBio == "" ? "This player has no bio." : hostBio
        clientNameLabel.text = UsersManager.shared.getNameWithId(uid: clientId)
        clientBioLabel.text = clientBio == "" ? "This player has no bio." : clientBio
    }
    
    func updateView() {
        let hostReady = RoomManager.shared.hostReady
        let clientReady = RoomManager.shared.clientReady
        if hostReady && clientReady {
            performSegue(withIdentifier: self.gameSegueIdentifiers[self.gameSelectedIndex], sender: self)
        }
    }
    
    @IBAction func pressedReadyButton(_ sender: Any) {
        isReady = !isReady
        readyButton.backgroundColor = isReady ? UIColor.red : UIColor.green
        readyButton.setTitle(isReady ? "Cancel" : "Ready!", for: .normal)
        readyMessageLabel.isHidden = !isReady
        if isHost {
            RoomManager.shared.setStartGameRequest(value: false)
            RoomManager.shared.updateDataWithField(fieldName: kKeyHostReady, value: isReady)
        } else {
            RoomManager.shared.updateDataWithField(fieldName: kKeyClientReady, value: isReady)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ticTacToeGameSegueIdentifier {
            
        }
    }
    
}
