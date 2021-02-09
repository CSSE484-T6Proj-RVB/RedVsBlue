//
//  RoomManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/24.
//

import Foundation
import Firebase

class RoomManager {
    var _roomDocumentRef: DocumentReference?
    var _document: DocumentSnapshot?
    var _roomListener: ListenerRegistration?
   
    static let shared = RoomManager()
    
    private init() {}
    
    func setReference(roomId: String) {
        _roomDocumentRef = Firestore.firestore().collection(kCollectionRooms).document(roomId)
    }
    
    func beginListening(changeListener: (() -> Void)?) {
        stopListening()
        _roomListener = _roomDocumentRef!.addSnapshotListener { (documentSnapshot, error) in
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
    
    func updateCurrentGameSelected(id: Int) {
        _roomDocumentRef?.updateData([
            kKeyGameSelected: id
        ])
    }
    
    func updateActualGameSelected(id: Int) {
        _roomDocumentRef?.updateData([
            kKeyActualGameSelected: id
        ])
    }
    
    func setEndGameRequest(value: Bool) {
        _roomDocumentRef?.updateData([
            kKeyEndGameRequest: value
        ])
    }
    
    func setStartGameRequest(value: Bool) {
        _roomDocumentRef?.updateData([
            kKeyStartGameRequest: value
        ])
    }
    
    func updateDataWithField(fieldName: String, value: Any) {
        _roomDocumentRef?.updateData([
            fieldName : value
        ])
    }
    
    var hostId: String {
        if let value = _document?.get(kKeyHostId) {
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
    
    var clientId: String? {
        if let value = _document?.get(kKeyClientId) {
            return value as? String
        }
        return nil
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
    
    var actualGameIndex: Int? {
        if let value = _document?.get(kKeyActualGameSelected) {
            return value as? Int
        }
        return nil
    }
}
