//
//  UsersManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/1.
//

import Foundation
import Firebase

class UsersManager {
    
    var _userCollectionRef: CollectionReference
    var _document: DocumentSnapshot?
    var _userListener: ListenerRegistration?
    var _queryDocuments: [DocumentSnapshot]?
    
    static let shared = UsersManager()
    
    private init() {
        _userCollectionRef = Firestore.firestore().collection(kCollectionUsers)
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
    
    func stopListening() {
        _userListener?.remove()
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
