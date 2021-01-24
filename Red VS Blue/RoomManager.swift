//
//  RoomManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/24.
//

import Foundation
import Firebase

let kCollectionGameData = "GameData"
let kKeyHostUserName = "hostUserName"
let kKeyHostUserBio = "hostUserBio"
let kKeyHostScore = "hostScore"
let kKeyHostReady = "hostReady"
let kKeyClientUserName = "clientUserName"
let kKeyClientUserBio = "clientUserBio"
let kKeyClientScore = "clientScore"
let kKeyClientReady = "clientReady"
let kKeyGameOnGoing = "onGoing"

class RoomManager {
    var _gameDataCollectionRef: CollectionReference
    var _document: DocumentSnapshot?
    var _roomListener: ListenerRegistration?
    var _queryDocuments: [DocumentSnapshot]?
    
    var roomId: String
    var score: Int
    var isHost: Bool
   
    static let shared = RoomManager()
    
    private init() {
        _gameDataCollectionRef = Firestore.firestore().collection(kCollectionGameData)
        score = 0
        isHost = false
        roomId =  ""
    }
    
    func addNewRoom(id: String, name: String, bio: String) {
        isHost = true
        score = 0
        roomId = id
        let roomRef = _gameDataCollectionRef.document(id)
        print("Creating New Room...")
        roomRef.setData([
            kKeyHostUserName: name,
            kKeyHostUserBio: bio,
            kKeyHostScore: 0,
            kKeyHostReady: false,
            kKeyGameOnGoing: false
        ])
    }
    
    func joinRoom(id: String, name: String, bio: String) {
        isHost = false
        score = 0
        roomId = id
        let roomRef = _gameDataCollectionRef.document(id)
        print("Joining the Room...")
        roomRef.updateData([
            kKeyClientUserName: name,
            kKeyClientUserBio: bio,
            kKeyClientScore: 0,
            kKeyClientReady: false,
            kKeyGameOnGoing: true
        ])
    }
    
    func beginListeningForRooms(changeListener: (() -> Void)?) {
        stopListening()
        _roomListener = _gameDataCollectionRef.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print("Error listening leaderboard \(error)")
            }
            if let querySnapshot = querySnapshot {
                self._queryDocuments = querySnapshot.documents
                changeListener?()
            }
        })
    }
    
    func beginListeningForTheRoom(id: String, changeListener: (() -> Void)?) {
        stopListening()
        let roomRef = _gameDataCollectionRef.document(id)
        _roomListener = roomRef.addSnapshotListener { (documentSnapshot, error) in
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
        _roomListener?.remove()
    }
    
    func deleteRoom(id: String) {
        let roomRef = _gameDataCollectionRef.document(id)
        roomRef.delete()
    }
    
    var hostUserName: String {
        if let value = _document?.get(kKeyHostUserName) {
            return value as! String
        }
        return ""
    }
    
    var clientUserName: String? {
        if let value = _document?.get(kKeyClientUserName) {
            return value as? String
        }
        return nil
    }
    
}
