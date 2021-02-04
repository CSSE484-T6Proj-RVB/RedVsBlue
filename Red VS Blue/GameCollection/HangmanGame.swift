//
//  HangmanGame.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import Foundation
import UIKit

class HangmanGame: Game {
    var name = "Hangman"
    var segueName = "HangmanGameSegue"
    var description = "One player thinks of a word or phrase; the others try to guess what it is one letter at a time. The player draws a number of dashes equivalent to the number of letters in the word. If a guessing player suggests a letter that occurs in the word, the other player fills in the blanks with that letter in the right places. If the word does not contain the suggested letter, the other player draws one element of a hangman’s gallows. As the game progresses, a segment of the gallows and of a victim is added for every suggested letter not in the word. The number of incorrect guesses before the game ends is up to the players, but completing a character in a noose provides a minimum of six wrong answers until the game ends. The first player to guess the correct answer thinks of the word for the next game."
    
    var gameIconImage = #imageLiteral(resourceName: "GameIcon_Hangman.PNG")
    
    var word: String!
    var lives: Int
    var attempts: [Character]
    var status: [Bool]!
    
    init() {
        self.lives = 6
        self.attempts = []
    }
    
    func setWord(word: String) {
        self.word = word
        self.status = [Bool](repeating: false, count: word.count)
    }
    
    func pressedLetter(letter: Character) -> Bool {
        if isDead() {
            print("You are already dead!")
            return false
        }
        if checkWin() {
            print("You already won!")
            return false
        }
        if attempts.contains(letter) {
            print("You already guessed this letter")
            return true
        }
        attempts.append(letter)
        if self.word.contains(letter) {
            for index in 0..<word.count {
                if Array(word)[index] == letter {
                    self.status[index] = true
                }
            }
            return true
        }
        self.lives -= 1
        return true
    }
    
    func checkWin() -> Bool {
        return self.status.allSatisfy({$0})
    }
    
    func isDead() -> Bool {
        return self.lives <= 0
    }
}
