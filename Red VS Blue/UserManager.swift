//
//  UserManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/24.
//

import Foundation
import Firebase

let kCollectionUsers = "Users"
let kKeyName = "name"
let kKeyBio = "bio"
let kKeyPhotoUrl = "photoUrl"
let kKeyMatchesPlayed = "matchesPlayed"
let kKeyMatchesWon = "matchesWon"

class UserManager {
    var _userCollectionRef: CollectionReference
    var _document: DocumentSnapshot?
    var _userListener: ListenerRegistration?
    
    static let shared = UserManager()
    
    private init() {
        _userCollectionRef = Firestore.firestore().collection(kCollectionUsers)
    }
    
    func addNewUserMabye(uid: String, name: String?, photoUrl: String?) {
        let userRef = _userCollectionRef.document(uid)
        userRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting user: \(error)")
            }
            if let documentSnapshot = documentSnapshot {
                if documentSnapshot.exists {
                    print("There is already a User Object for this auth user. DO NOTHING.")
                } else {
                    print("Creating a User with Document id \(uid)")
                    userRef.setData([
                        kKeyName: name ?? "",
                        kKeyBio: "",
                        kKeyPhotoUrl: photoUrl ?? "",
                        kKeyMatchesPlayed: 0,
                        kKeyMatchesWon: 0
                    ])
                }
            }
        }
    }
    
    func beginListening(uid: String, changeListener: () -> Void) {
        
    }
    
    func stopListening() {
        _userListener?.remove()
    }
    
    func updateName(name: String) {
        
    }
    
    var name: String {
        if let value = _document?.get(kKeyName) {
            return value as! String
        }
        return ""
    }
    
    var bio: String {
        if let value = _document?.get(kKeyBio) {
            return value as! String
        }
        return ""
    }
}
