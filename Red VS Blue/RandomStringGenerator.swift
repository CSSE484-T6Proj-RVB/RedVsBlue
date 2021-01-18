//
//  RandomStringGenerator.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import Foundation
import Firebase

class RandomStringGenerator {
    
    // Source: https://jimpix.co.uk/words/random-username-generator.asp#results
    var randomUsernames = ["lesservaluable", "vomitorygiving", "cheltedadjoining", "smishunion", "irritableultimate", "spotlessgave", "runpoose", "belovedthottage", "justicelunctured", "experiencehowl", "loyaltyfungus", "kayakingemerge", "gothiccarry", "erstwhileorodruin", "effluviumgrin", "biteerect", "unreliableslowly", "hobbitonschants", "bawdscarton", "cumindisfigured", "dindowspelt", "joinerundertaker", "efficientdemocracy", "amucknunchy", "glagtroubled"]
    
    var randomHangmanWords = ["random", "word"]
    
    func generateRandomUsername() -> String {
        return randomUsernames[Int.random(in: 0..<randomUsernames.count)]
    }
    
    func generateRandomHangmanWord() -> String {
        return randomHangmanWords[Int.random(in: 0..<randomHangmanWords.count)]
    }
    
    func generateRandomRoomNumber() -> String {
        var roomNum = ""
        for _ in 0..<4 {
            roomNum += "\(Int.random(in: 0..<10))"
        }
        return roomNum
//        let gameDataRef = Firestore.firestore().collection("GameData")
//        var existingGameCode: [String] = []
//
//        var roomNum = "1234"
//        print("aa")
//        gameDataRef.getDocuments { (documentSnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                print("a")
//                for document in documentSnapshot!.documents {
//                    existingGameCode.append(document.data()["roomId"] as! String)
//                }
//                print(existingGameCode)
//                var isDuplicated = true
////                while isDuplicated {
////
////                    isDuplicated = existingGameCode.contains(roomNum)
////
////                }
//            }
//        }
////        while roomNum == nil {
////
////        }
//        return roomNum
    }
}
