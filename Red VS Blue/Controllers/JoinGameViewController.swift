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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        codeTextField.delegate = self
        codeTextField.addTarget(self, action: #selector(self.updateDigitCodeView), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UsersManager.shared.beginListening(changeListener: updateNameView)
        RoomsManager.shared.beginListeningForRooms(changeListener: nil)
        
        nameView.layer.cornerRadius = 12
        nameView.layer.borderWidth = 2
        nameView.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UsersManager.shared.stopListening()
        RoomsManager.shared.stopListening()
    }
    
    func updateNameView() {
        userNameLabel.text = UsersManager.shared.getNameWithId(uid: UserManager.shared.uid)
    }
    
    @IBAction func pressedBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressedJoinButton(_ sender: Any) {
        if digits == nil || digits.count != 4 {
            AlertDialog.showAlertDialog(viewController: self, title: "Error",
                                        message: "Please Enter 4 digits", confirmTitle: "OK", finishHandler: nil)
            return
        }
        let onGoing = RoomsManager.shared.getOngoingWithId(roomId: digits)
        if onGoing == nil {
            // Room Does not exist
            AlertDialog.showAlertDialog(viewController: self, title: "Error",
                                        message: "The Game Room Does not Exist!", confirmTitle: "OK", finishHandler: nil)
        } else if onGoing! {
            // ONGOING

            AlertDialog.showAlertDialog(viewController: self, title: "Error",
                                        message: "The Game is ongoing!", confirmTitle: "OK", finishHandler: nil)
        } else {
            // JOINABLE
            RoomsManager.shared.joinRoom(id: digits)
            performSegue(withIdentifier: gameSelectionSegueIdentifier, sender: self)
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
            (segue.destination as! GameSelectionViewController).roomId = digits
            (segue.destination as! GameSelectionViewController).isHost = false
            (segue.destination as! GameSelectionViewController).score = 0
        }
    }
}
