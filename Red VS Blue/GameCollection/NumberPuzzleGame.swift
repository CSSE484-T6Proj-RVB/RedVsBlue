//
//  NumberPuzzleGame.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/21.
//

import Foundation
import UIKit

class NumberPuzzleGame: Game {
    var name = "Number Puzzle"
    var segueName = "NumberPuzzleGameSegue"
    var description = "The 15 puzzle is a sliding puzzle that consists of a frame of numbered square tiles in random order with one tile missing. The puzzle also exists in other sizes, particularly the smaller 8 puzzle. If the size is 3×3 tiles, the puzzle is called the 8 puzzle or 9 puzzle, and if 4×4 tiles, the puzzle is called the 15 puzzle or 16 puzzle named, respectively, for the number of tiles and the number of spaces. The goal of the puzzle is to place the tiles in order by making sliding moves that use the empty space."
    var gameIconImage = #imageLiteral(resourceName: "GameIcon_NumberPuzzle.PNG")
    
    var puzzle: [Int]
    var size: Int
    
    init() {
        puzzle = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        size = 4
    }
    
    func pressedButtonAtIndex(index: Int) {
        if !canMove(index: index) {
            return
        }
        swapNumbers(firstIndex: index, secondIndex: getEmptyIndex())
        
    }
    
    func canMove(index: Int) -> Bool {
        return validClickPositions().contains(index)
    }
    
    func validClickPositions() -> [Int] {
        let emptyIndex = getEmptyIndex()
        var validPositions = [Int]()

        if emptyIndex > 3 {validPositions.append(emptyIndex - 4)}
        
        if emptyIndex < 12 {validPositions.append(emptyIndex + 4)}
        
        if emptyIndex % size != 0 {validPositions.append(emptyIndex - 1)}
        
        if emptyIndex % size != 3 {validPositions.append(emptyIndex + 1)}
        
        return validPositions
    }
    
    func getEmptyIndex() -> Int {
        for index in 0 ..< size * size {
            if puzzle[index] == 15 {
                return index
            }
        }
        return -1
    }
    
    func swapNumbers(firstIndex: Int, secondIndex: Int) {
        let firstValue = puzzle[firstIndex]
        puzzle[firstIndex] = puzzle[secondIndex]
        puzzle[secondIndex] = firstValue
    }
    
    func shuffle() {
        let times = Int.random(in: 0 ... 200) + 100
        for _ in 0 ... times {
            let arr = validClickPositions()
            let index = Int.random(in: 0 ..< arr.count)
            swapNumbers(firstIndex: arr[index], secondIndex: getEmptyIndex())
        }
    }
    
}
