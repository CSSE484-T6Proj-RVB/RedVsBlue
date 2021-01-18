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
    var gameDataListener: ListenerRegistration!
    var randomRoomNumGenerator = RandomStringGenerator()
    var digits: String!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        gameDataRef = Firestore.firestore().collection("Users")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        userNameView.layer.cornerRadius = 12
        userNameView.layer.borderWidth = 2
        userNameView.layer.borderColor = UIColor.black.cgColor
        
        userNameLabel.text = user.name
        
        digits = randomRoomNumGenerator.generateRandomRoomNumber()
        startListening()
        updateDigitCodes(digits: digits)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameDataListener.remove()
    }
    
    func startListening() {
        
    }
    
    func createGameRoomData() {
        
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
