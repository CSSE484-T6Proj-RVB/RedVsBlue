//
//  RoomStatusStorage.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/2/3.
//

import Foundation

class RoomStatusStorage {
    
    var roomId: String
    var isHost: Bool
    var score: Int
    
    static let shared = RoomStatusStorage()
    
    private init() {
        roomId = "-1"
        isHost = false
        score = 0
    }
    
    func initialize(roomId: String, isHost: Bool) {
        self.roomId = roomId
        self.isHost = isHost
        self.score = 0
    }
}
