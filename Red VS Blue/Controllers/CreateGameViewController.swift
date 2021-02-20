//
//  CreateGameViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import UIKit
import Firebase

class CreateGameViewController: UIViewController {
    
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var digitCodeLabels: [UILabel]!
    
    var digits: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        RoundCornerFactory.shared.setCornerAndBorder(view: userNameView, cornerRadius: 12, borderWidth: 2, borderColor: UIColor.black.cgColor)
        UsersManager.shared.beginListening(changeListener: updateNameView)
        RoomsManager.shared.beginListeningForRooms(changeListener: addRoom)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomsManager.shared.stopListening()
        RoomManager.shared.stopListening()
        UsersManager.shared.stopListening()
    }
    
    func addRoom() {
        RoomsManager.shared.stopListening()
        digits = "4057"
        while RoomsManager.shared.getOngoingWithId(roomId: digits) != nil {
            digits = RandomStringGenerator.shared.generateRandomRoomNumber()
        }
        RoomsManager.shared.addNewRoom(id: digits)
        updateDigitCodes(digits: digits)
        RoomManager.shared.setReference(roomId: digits)
        RoomManager.shared.beginListening(changeListener: playerJoined)
    }
    
    func playerJoined() {
        if RoomManager.shared.clientId == nil {
            return
        }
        print(RoomManager.shared.clientId!)
        performSegue(withIdentifier: gameSelectionSegueIdentifier, sender: self)
    }
    
    func updateNameView() {
        userNameLabel.text = UsersManager.shared.getNameWithId(uid: UserManager.shared.uid)
    }
    
    func updateDigitCodes(digits: String) {
        for label in digitCodeLabels {
            let index = label.tag
            label.text = String(Array(digits)[index])
        }
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        RoomsManager.shared.deleteRoom(id: digits)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameSelectionSegueIdentifier {
            RoomStatusStorage.shared.initialize(roomId: digits, isHost: true)
        }
    }
}
