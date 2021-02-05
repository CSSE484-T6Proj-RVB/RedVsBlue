//
//  GameCollection.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import Foundation

class GameCollection {
    
    static let shared = GameCollection()
    
    var games: [Game]
    
    private init() {
        games = [TicTacToeGame(), CountTo21Game(), NumberPuzzleGame(), RandomGame()]
        //games = [TicTacToeGame(), RandomGame()]
    }
}
