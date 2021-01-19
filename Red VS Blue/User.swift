//
//  User.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import Foundation
import Firebase

class User {
    var name: String
    var bio: String
    var userDocId: String
    var id: String
    
    var matchesPlayed: Int
    var matchesWon: Int
    
    init(documentSnapshot: DocumentSnapshot) {
        self.userDocId = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        
        self.name = data["name"] as! String
        self.bio = data["bio"] as! String
        self.id = data["id"] as! String
        
        self.matchesPlayed = data["matchesPlayed"] as! Int
        self.matchesWon = data["matchesWon"] as! Int
    }
    
}