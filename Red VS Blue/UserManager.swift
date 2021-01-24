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
    var _queryDocuments: [DocumentSnapshot]?
    
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
    
    func beginListeningForLeaderboard(isMatchesPlayed: Bool, changeListener: (() -> Void)?) {
        stopListening()
        let query = isMatchesPlayed ? _userCollectionRef.order(by: kKeyMatchesPlayed, descending: true).limit(to: 10).whereField(kKeyMatchesPlayed, isGreaterThan: 0) : _userCollectionRef.order(by: kKeyMatchesWon, descending: true).limit(to: 10).whereField(kKeyMatchesWon, isGreaterThan: 0)
        _userListener = query.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print("Error listening leaderboard \(error)")
            }
            if let querySnapshot = querySnapshot {
                self._queryDocuments = querySnapshot.documents
                changeListener?()
            }
        })
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
    
    func getQueryDocumentCount() -> Int {
        return _queryDocuments?.count ?? 0
    }
    
    func getNameAtIndex(index: Int) -> String {
        if let value = _queryDocuments?[index].get(kKeyName) {
            return value as! String
        }
        return ""
    }
    
    func getMatchesPlayedAtIndex(index: Int) -> Int {
        if let value = _queryDocuments?[index].get(kKeyMatchesPlayed) {
            return value as! Int
        }
        return 0
    }
    
    func getMatchesWonAtIndex(index: Int) -> Int {
        if let value = _queryDocuments?[index].get(kKeyMatchesWon) {
            return value as! Int
        }
        return 0
    }
}
