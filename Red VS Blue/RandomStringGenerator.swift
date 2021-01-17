//
//  RandomStringGenerator.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/18.
//

import Foundation

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
}
