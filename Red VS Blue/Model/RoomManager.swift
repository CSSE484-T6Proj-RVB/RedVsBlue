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
let kKeyGameSelected = "currentGameSelected"
let kKeyEndGameRequest = "endGameRequest"
let kKeyStartGameRequest = "startGameRequest"

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
        // TODO: Only User ID
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
        // TODO: Only User ID
    }
    
    func updateDataWithField(id: String, fieldName: String, value: Any) {
        let roomRef = _gameDataCollectionRef.document(id)
        roomRef.updateData([
            fieldName: value
        ])
    }
    
    func beginListeningForRooms(changeListener: (() -> Void)?) {
        stopListening()
        _roomListener = _gameDataCollectionRef.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print("Error listening rooms \(error)")
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
                print("Error listening for room \(error)")
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
    
    func getDataWithField(fieldName: String) -> Any? {
        if let value = _document?.get(fieldName) {
            return value
        }
        return nil
    }
    
    var hostUserName: String {
        if let value = _document?.get(kKeyHostUserName) {
            return value as! String
        }
        return ""
    }
    
    var hostUserBio: String {
        if let value = _document?.get(kKeyHostUserBio) {
            return value as! String
        }
        return ""
    }
    
    var hostScore: Int {
        if let value = _document?.get(kKeyHostScore) {
            return value as! Int
        }
        return 0
    }
    
    var hostReady: Bool {
        if let value = _document?.get(kKeyHostReady) {
            return value as! Bool
        }
        return false
    }
    
    var clientScore: Int {
        if let value = _document?.get(kKeyClientScore) {
            return value as! Int
        }
        return 0
    }
    
    var clientUserName: String? {
        if let value = _document?.get(kKeyClientUserName) {
            return value as? String
        }
        return nil
    }
    
    var clientUserBio: String {
        if let value = _document?.get(kKeyClientUserBio) {
            return value as! String
        }
        return ""
    }
    
    var clientReady: Bool {
        if let value = _document?.get(kKeyClientReady) {
            return value as! Bool
        }
        return false
    }
    
    var currentGameSelected: Int? {
        if let value = _document?.get(kKeyGameSelected) {
            return value as? Int
        }
        return nil
    }
    
    var endGameRequest: Bool? {
        if let value = _document?.get(kKeyEndGameRequest) {
            return value as? Bool
        }
        return nil
    }
    
    var startGameRequest: Bool? {
        if let value = _document?.get(kKeyStartGameRequest) {
            return value as? Bool
        }
        return nil
    }
}
