//
//  JoinGameViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/19.
//

import UIKit
import Firebase

class JoinGameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var gameDataRef: CollectionReference!
    var gameDatumRef: DocumentReference!
    var gameDataListener: ListenerRegistration!
    
    var digits: String!
    var nonEmptyRoomIds = [String]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        codeTextField.delegate = self
        codeTextField.addTarget(self, action: #selector(self.updateDigitCodeView), for: .editingChanged)
        gameDataRef = Firestore.firestore().collection("GameData")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        nonEmptyRoomIds = []
        
        nameView.layer.cornerRadius = 12
        nameView.layer.borderWidth = 2
        nameView.layer.borderColor = UIColor.black.cgColor
        nameLabel.text = user.name
        
        startListening()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameDataListener.remove()
    }
    
    func startListening() {
        gameDataListener = gameDataRef.addSnapshotListener({ (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                self.nonEmptyRoomIds = []
                for document in documentSnapshot.documents {
                    self.nonEmptyRoomIds.append(document.data()["roomId"] as! String)
                }
                //print(self.nonEmptyRoomIds)
            } else {
                print("Error getting user data \(error!)")
                return
            }
        })
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressedJoinButton(_ sender: Any) {
        if digits.count != 4 {
            // TODO: Alert
            return
        }
        if nonEmptyRoomIds.contains(digits) {
            gameDataListener = gameDataRef.whereField("roomId", isEqualTo: digits!).addSnapshotListener({ (documentSnapshot, error) in
                if let error = error {
                    print("Get specific game room data failed \(error)")
                    return
                }
                self.gameDatumRef = self.gameDataRef.document(documentSnapshot!.documents[0].documentID)
                print("Can update data now.")
            })
        }
    }
    
    @objc func updateDigitCodeView() {
        // Source: https://stackoverflow.com/questions/49921687/how-to-add-space-between-uitextfield-placeholder-characters
        let attributedString = NSMutableAttributedString(string: codeTextField.text!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(65.0), range: NSRange(location: 0, length: attributedString.length == 0 ? attributedString.length : attributedString.length - 1))
        codeTextField.attributedText = attributedString
        digits = codeTextField.text!
    }
    
    // Source: https://stackoverflow.com/questions/18546467/how-to-make-text-field-that-to-accept-only-4-digit-or-numbers-in-iphone
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textstring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let length = textstring.count
        if length > 4 || !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: textstring)) {
            return false
        }
        return true
    }
}
