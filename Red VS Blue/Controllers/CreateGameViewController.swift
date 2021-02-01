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
    
    var nonEmptyRoomIds = [String]()
    var digits: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        userNameView.layer.cornerRadius = 12
        userNameView.layer.borderWidth = 2
        userNameView.layer.borderColor = UIColor.black.cgColor
        
        UserManager.shared.beginListeningForSingleUser(uid: Auth.auth().currentUser!.uid, changeListener: updateNameView)
        RoomManager.shared.beginListeningForRooms(changeListener: appendRoomIds)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        RoomManager.shared.stopListening()
        UserManager.shared.stopListening()
    }
    
    func appendRoomIds() {
        nonEmptyRoomIds = []
        for document in RoomManager.shared._queryDocuments! {
            //print("added something !!!")
            self.nonEmptyRoomIds.append(document.documentID)
        }
        print(nonEmptyRoomIds)
        RoomManager.shared.stopListening()
        createRoom()
    }
    
    func createRoom() {
        digits = "4057" // TODO: Set it back
        while nonEmptyRoomIds.contains(digits) {
            digits = RandomStringGenerator.shared.generateRandomRoomNumber()
        }
        updateDigitCodes(digits: digits)
        RoomManager.shared.addNewRoom(id: digits, name: UserManager.shared.name, bio: UserManager.shared.bio)
        RoomManager.shared.beginListeningForTheRoom(id: digits, changeListener: playerJoined)
    }
    
    func playerJoined() {
        if RoomManager.shared.clientUserName == nil {
            return
        }
        print(RoomManager.shared.clientUserName!)
        performSegue(withIdentifier: gameSelectionSegueIdentifier, sender: self)
    }
    
    func updateNameView() {
        userNameLabel.text = UserManager.shared.name
    }
    
    func updateDigitCodes(digits: String) {
        for label in digitCodeLabels {
            let index = label.tag
            label.text = String(Array(digits)[index])
        }
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        RoomManager.shared.deleteRoom(id: digits)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameSelectionSegueIdentifier {
//            (segue.destination as! GameSelectionViewController).roomRef = gameDatumRef
//            (segue.destination as! GameSelectionViewController).user = user
        }
    }
}
