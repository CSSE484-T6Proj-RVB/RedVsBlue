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
    
    var gameDataRef: CollectionReference!
    var gameDatumRef: DocumentReference!
    var gameDataListener: ListenerRegistration!
    var gameDatumListener: ListenerRegistration!
    var randomRoomNumGenerator = RandomStringGenerator()
    var nonEmptyRoomIds = [String]()
    var digits: String!
    var user: User!
    
    let gameSelectionSegueIdentifier = "GameSelectionSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        gameDataRef = Firestore.firestore().collection("GameData")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        nonEmptyRoomIds = []
        userNameView.layer.cornerRadius = 12
        userNameView.layer.borderWidth = 2
        userNameView.layer.borderColor = UIColor.black.cgColor
        
        userNameLabel.text = user.name
        
        startListening()
        
        digits = randomRoomNumGenerator.generateRandomRoomNumber()
        while nonEmptyRoomIds.contains(digits) {
            digits = randomRoomNumGenerator.generateRandomRoomNumber()
        }
        
        updateDigitCodes(digits: digits)
        createGameRoomData()
        
        startListeningForTheRoom()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameDataListener.remove()
        gameDatumListener.remove()
        
        
    }
    
    func startListening() {
        gameDataListener = gameDataRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.nonEmptyRoomIds = []
                for document in documentSnapshot.documents {
                    if let roomId = document.data()["roomId"]{
                        self.nonEmptyRoomIds.append(roomId as! String)
                    }
                }
            } else {
                print("Error getting rooms data \(error!)")
                return
            }
        })
    }
    
    func startListeningForTheRoom() {
        gameDatumListener = gameDatumRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                if let _ = documentSnapshot.data()!["clientUserName"] {
                    print("Player joined in.")
                    self.performSegue(withIdentifier: self.gameSelectionSegueIdentifier, sender: self)
                }
            } else {
                print("Error getting room data \(error!)")
                return
            }
        })
        
    }
    
    func createGameRoomData() {
        gameDatumRef = gameDataRef.addDocument(data: [
            "roomId": digits!,
            "hostUserName":  user.name,
            "hostUserBio":  user.bio
        ])
    }
    
    func updateDigitCodes(digits: String) {
        print(digits)
        for label in digitCodeLabels {
            let index = label.tag
            label.text = String(Array(digits)[index])
        }
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        gameDatumRef.delete()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameSelectionSegueIdentifier {
            (segue.destination as! GameSelectionViewController).roomRef = gameDatumRef
        }
    }
}
