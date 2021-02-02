//
//  UserManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/24.
//

import Foundation
import Firebase

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
    
    func beginListeningForSingleUser(uid: String, changeListener: (() -> Void)?) {
        stopListening()
        let userRef = _userCollectionRef.document(uid)
        _userListener =  userRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print("Error listening for user \(error)")
                return
            }
            if let documentSnapshot = documentSnapshot {
                self._document = documentSnapshot
                changeListener?()
            }
        }
    }
    
    func stopListening() {
        _userListener?.remove()
    }
    
    func updateName(name: String) {
        let userRef = _userCollectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyName: name
        ])
    }
    
    func updateBio(bio: String) {
        let userRef = _userCollectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyBio: bio
        ])
    }
    
    func updateMatchesPlayed(mp: Int) {
        let userRef = _userCollectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyMatchesPlayed: mp
        ])
    }
    
    func updateMatchesWon(mw: Int) {
        let userRef = _userCollectionRef.document(Auth.auth().currentUser!.uid)
        userRef.updateData([
            kKeyMatchesWon: mw
        ])
    }
    
    var uid: String {
        return Auth.auth().currentUser!.uid
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
    
    var matchesPlayed: Int {
        if let value = _document?.get(kKeyMatchesPlayed) {
            return value as! Int
        }
        return 0
    }
    
    var matchesWon: Int {
        if let value = _document?.get(kKeyMatchesWon) {
            return value as! Int
        }
        return 0
    }
}
