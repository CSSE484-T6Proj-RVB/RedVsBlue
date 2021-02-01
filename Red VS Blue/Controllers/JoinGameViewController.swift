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
    @IBOutlet weak var userNameLabel: UILabel!
    
    var digits: String!
    var nonEmptyRoomIds = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        codeTextField.delegate = self
        codeTextField.addTarget(self, action: #selector(self.updateDigitCodeView), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UserManager.shared.beginListeningForSingleUser(uid: Auth.auth().currentUser!.uid, changeListener: updateNameView)
        
        nonEmptyRoomIds = []
        
        nameView.layer.cornerRadius = 12
        nameView.layer.borderWidth = 2
        nameView.layer.borderColor = UIColor.black.cgColor
        
        RoomManager.shared.beginListeningForRooms(changeListener: appendRoomIds)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserManager.shared.stopListening()
        RoomManager.shared.stopListening()
    }
    
    func appendRoomIds() {
        nonEmptyRoomIds = []
        for document in RoomManager.shared._queryDocuments! {
            self.nonEmptyRoomIds.append(document.documentID)
        }
        print(nonEmptyRoomIds)
        //RoomManager.shared.stopListening()
    }
    
    func updateNameView() {
        userNameLabel.text = UserManager.shared.name
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressedJoinButton(_ sender: Any) {
        if digits == nil || digits.count != 4 {
            let alertController = UIAlertController(title: "Error",
                                                    message: "Please Enter 4 digits",
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        if nonEmptyRoomIds.contains(digits) {
            if digits == "2" {
                // TODO: Check for isGoing
                return
            }
            RoomManager.shared.joinRoom(id: digits, name: UserManager.shared.name, bio: UserManager.shared.bio)
            performSegue(withIdentifier: gameSelectionSegueIdentifier, sender: self)
        } else {
            let alertController = UIAlertController(title: "Error",
                                                    message: "The Game Room Does not Exist!",
                                                    preferredStyle: .alert)

            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .cancel,
                                                    handler: nil))

            present(alertController, animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gameSelectionSegueIdentifier {
//            (segue.destination as! GameSelectionViewController).roomRef = gameDatumRef
//            (segue.destination as! GameSelectionViewController).user = user
        }
    }
}
