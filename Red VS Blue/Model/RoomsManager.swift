//
//  RoomsManager.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/1.
//

import Foundation
import Firebase

class RoomsManager {
    
    var _roomCollectionRef: CollectionReference
    var _roomListener: ListenerRegistration?
    var _queryDocuments: [DocumentSnapshot]?
    
    static let shared = RoomsManager()
    
    private init() {
        _roomCollectionRef = Firestore.firestore().collection(kCollectionRooms)
    }
    
    func addNewRoom(id: String) {
        let roomRef = _roomCollectionRef.document(id)
        print("Creating New Room...")
        roomRef.setData([
            kKeyHostId: UserManager.shared.uid,
            kKeyHostScore: 0,
            kKeyHostReady: false,
            kKeyGameOnGoing: false
        ])
    }
    
    func joinRoom(id: String) {
        let roomRef = _roomCollectionRef.document(id)
        print("Joining the Room...")
        roomRef.updateData([
            kKeyClientId: UserManager.shared.uid,
            kKeyClientScore: 0,
            kKeyClientReady: false,
            kKeyGameOnGoing: true
        ])
    }
    
    func beginListeningForRooms(changeListener: (() -> Void)?) {
        stopListening()
        _roomListener = _roomCollectionRef.addSnapshotListener({ (querySnapshot, error) in
            if let error = error {
                print("Error listening rooms \(error)")
            }
            if let querySnapshot = querySnapshot {
                self._queryDocuments = querySnapshot.documents
                changeListener?()
            }
        })
    }
    
    func deleteRoom(id: String) {
        let roomRef = _roomCollectionRef.document(id)
        roomRef.delete()
    }
    
    func stopListening() {
        _roomListener?.remove()
    }
    
    func getOngoingWithId(roomId: String) -> Bool? {
        for document in _queryDocuments! {
            if document.documentID == roomId {
                return document.get(kKeyGameOnGoing) as? Bool
            }
        }
        return nil
    }
    
}
