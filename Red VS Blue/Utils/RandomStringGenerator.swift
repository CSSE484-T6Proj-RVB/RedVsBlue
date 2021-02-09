//
//  RandomStringGenerator.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import Foundation
import Firebase

class RandomStringGenerator {
    
    var randomHangmanWords: [String]
    
    static let shared = RandomStringGenerator()
    
    private init() {
        let file = "HangmanDictionary"
        randomHangmanWords = []
//        randomHangmanWords = ["balloon","baby", "back", "ball", "bank", "base", "basket", "bath", "bean", "bear", "bedroom", "beer", "behave", "before", "begin", "behind", "bell", "below", "besides", "best", "better", "between", "bird", "birth", "birthday"]
        do {
            if let hangmanDicFilePath = Bundle.main.path(forResource: file, ofType: "txt", inDirectory: "Data") {
                let contents = try String(contentsOfFile: hangmanDicFilePath)
                let rawData = contents.components(separatedBy: "\n")
                for str in rawData {
                    if str.count > 3 && str.count <= 7 {
                        randomHangmanWords.append(str)
                    }
                }
//                print(randomHangmanWords.count)
//                print(randomHangmanWords)
            }
        } catch {
            print("Error reading dic")
        }
    }
    
    // TODO: Make this collection bigger
    // Source: https://jimpix.co.uk/words/random-username-generator.asp#results
    var randomUsernames = ["lesservaluable", "vomitorygiving", "cheltedadjoining", "smishunion", "irritableultimate", "spotlessgave", "runpoose", "belovedthottage", "justicelunctured", "experiencehowl", "loyaltyfungus", "kayakingemerge", "gothiccarry", "erstwhileorodruin", "effluviumgrin", "biteerect", "unreliableslowly", "hobbitonschants", "bawdscarton", "cumindisfigured", "dindowspelt", "joinerundertaker", "efficientdemocracy", "amucknunchy", "glagtroubled"]
    
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
    }
}
