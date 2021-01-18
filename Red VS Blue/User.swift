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
    var id: String
    
    init(documentSnapshot: DocumentSnapshot) {
        self.id = documentSnapshot.documentID
        let data = documentSnapshot.data()!
        
        self.name = data["name"] as! String
        self.bio = data["bio"] as! String
    }
    
}
