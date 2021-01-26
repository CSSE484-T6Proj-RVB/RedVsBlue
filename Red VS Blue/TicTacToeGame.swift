//
//  TicTacToeGame.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/20.
//

import Foundation
import UIKit

class TicTacToeGame: Game, CustomStringConvertible {
    
    var name = "Tic Tac Toe"
    var segueName = "TicTacToeGameSegue"
    var description = "The object of Tic Tac Toe is to get three in a row. You play on a three by three game board. The first player is known as X and the second is O. Players alternate placing X's and O's on the game board until either oppent has three in a row or all nine squares are filled."
    var gameIconImage = #imageLiteral(resourceName: "GameIcon_TicTacToe.PNG")
    
    enum MarkType: String {
        case none = "-"
        case x = "X"
        case o = "O"
    }
    
    var board: [MarkType]
    
    enum State: String {
        case xTurn = "X's Turn"
        case oTurn = "O's Turn"
        case xWin = "X Wins"
        case oWin = "O Wins"
        case tie = "Tie Game"
    }
    
    var state: State
    
    init() {
        board = [MarkType](repeating: .none, count: 9)
        state = .xTurn
    }
    
    func getBoardString(_ indicies: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8]) -> String {
        var gameString = ""
        
        for i in indicies {
            gameString += board[i].rawValue
        }
        
        return gameString
    }
    
    func pressedSquareAt(_ index: Int) -> Bool {
        if board[index] != .none {
            //print("not empty")
            return false
        }
        switch state {
        case .xWin, .oWin, .tie:
            print("This game is over already!")
            return false
        case .xTurn:
            board[index] = .x
            state = .oTurn
        case .oTurn:
            board[index] = .o
            state = .xTurn
        }
        checkForWin()
        return true
    }
    
    func checkForWin() {
        
        // Check for a tie BEFORE Checking for a win
        if !board.contains(.none) {
            state = .tie
        }
        
        var linesOf3 = [String]()
        
        //linesOf3.append("\(board[0].rawValue)\(board[1].rawValue)\(board[2].rawValue)")
        
        linesOf3.append(getBoardString([0, 1, 2]))
        linesOf3.append(getBoardString([3, 4, 5]))
        linesOf3.append(getBoardString([6, 7, 8]))
        
        linesOf3.append(getBoardString([0, 3, 6]))
        linesOf3.append(getBoardString([1, 4, 7]))
        linesOf3.append(getBoardString([2, 5, 8]))
        
        linesOf3.append(getBoardString([0, 4, 8]))
        linesOf3.append(getBoardString([2, 4, 6]))
        
        for lineOf3 in linesOf3 {
            if lineOf3 == "XXX" {
                state = .xWin
            } else if lineOf3 == "OOO" {
                state = .oWin
            }
        }
    }
    
}
