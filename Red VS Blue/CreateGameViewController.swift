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
    var randomRoomNumGenerator = RandomStringGenerator()
    var nonEmptyRoomIds = [String]()
    var digits: String!
    var user: User!
    
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
        print(gameDatumRef.documentID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameDataListener.remove()
        gameDatumRef.delete()
        
    }
    
    func startListening() {
        gameDataListener = gameDataRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                for document in documentSnapshot.documents {
                    self.nonEmptyRoomIds.append(document.data()["roomId"] as! String)
                }
            } else {
                print("Error getting user data \(error!)")
                return
            }
        })
    }
    
    func createGameRoomData() {
        gameDatumRef = gameDataRef.addDocument(data: [
            "roomId": digits!,
            "hostUsername":  user.name,
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
        self.navigationController?.popViewController(animated: true)
    }
}
