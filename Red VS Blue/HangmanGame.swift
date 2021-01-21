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
    
    var description = "One player thinks of a word or phrase; the others try to guess what it is one letter at a time. The player draws a number of dashes equivalent to the number of letters in the word. If a guessing player suggests a letter that occurs in the word, the other player fills in the blanks with that letter in the right places. If the word does not contain the suggested letter, the other player draws one element of a hangman’s gallows. As the game progresses, a segment of the gallows and of a victim is added for every suggested letter not in the word. The number of incorrect guesses before the game ends is up to the players, but completing a character in a noose provides a minimum of six wrong answers until the game ends. The first player to guess the correct answer thinks of the word for the next game."
    
    var gameIconImage = #imageLiteral(resourceName: "GameIcon_Hangman.PNG")
    
}
