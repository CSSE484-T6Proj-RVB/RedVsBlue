//
//  TicTacToeManager.swift
//  Red VS Blue
//
//  Created by 马闻泽 on 2/2/21.
//

import Foundation
import Firebase

class GameDataManager {
    
    var _gameDocumentRef: DocumentReference?
    var _document: DocumentSnapshot?
    var _gameListener: ListenerRegistration?
    
    var _gameCollectionRef: CollectionReference?
    
    static let shared = GameDataManager()
    
    func setReference(roomId: String, gameName: String) {
        _gameDocumentRef = Firestore.firestore().collection(kCollectionRooms).document(roomId).collection(kCollectionGameData).document(gameName)
    }
    
    private init() {}
    
    func beginListening(changeListener: (() -> Void)?) {
        stopListening()
        _gameListener = _gameDocumentRef!.addSnapshotListener { (documentSnapshot, error) in
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
        _gameListener?.remove()
    }
    
    func updateDataWithField(fieldName: String, value: Any) {
        _gameDocumentRef?.updateData([
            fieldName: value
        ])
    }
    
    func getDataWithField(fieldName: String) -> Any {
        if let value = _document?.get(fieldName) {
            return value
        }
        return ""
    }
}
