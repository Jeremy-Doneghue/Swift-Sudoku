//
//  SudokuGameParser.swift
//  Paper Games
//
//  Created by Jeremy Doneghue on 20/11/17.
//  Copyright © 2017 Jeremy Doneghue. All rights reserved.
//

import Foundation

class SudokuGameParser {
    
    enum SudokuGameParserError: Error {
        case incorrectLength
        case invalidCharacters
    }
    
    /*
     * Parse in values from a string
     */
    static func parseGame(game: String, dimension: Int) throws -> [[Int]] {
        
        // Get each character as its integer representation
        let chars = Array(game.utf8)
        
        // Check length of array. Should be equal to dimention squared
        if chars.count != (dimension * dimension) {
            print("Failed to parse sudoku game description: Incorrect length")
            throw SudokuGameParserError.incorrectLength
        }
        
        // Check that the puzzle description only contains numbers 1 - 9
        for char in chars {
            // If a character is out of range of the puzzle
            if Int(char) > 48 + dimension || Int(char) < 48 {
                print("Failed to parse sudoku game description: Invalid chars")
                throw SudokuGameParserError.invalidCharacters
            }
        }
        
        // Initialise the array to return
        var values = [[Int]](repeating: [Int](repeating: 0, count: dimension), count: dimension)
        
        // Turn a 1D array into a 2D array by the dimention
        // e.g. [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ] => [[1, 2, 3][1, 2, 3][1, 2, 3]]
        for i in 0..<chars.count {
            let row = Int(floor(Float(i) / Float(dimension)))
            let col = i % dimension
            values[row][col] = Int(chars[i] - 48)
        }
        
        return values
    }
}
