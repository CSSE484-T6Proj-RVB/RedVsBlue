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
    var uid: String
    
    var matchesPlayed: Int
    var matchesWon: Int
    
    var identity: Int = -1 //-1: not assigned     0: client     1: host
    var score: Int = 0
    
    init(documentSnapshot: DocumentSnapshot) {
        self.uid = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        
        self.name = data["name"] as! String
        self.bio = data["bio"] as! String
        
        self.matchesPlayed = data["matchesPlayed"] as! Int
        self.matchesWon = data["matchesWon"] as! Int
    }
    
}
