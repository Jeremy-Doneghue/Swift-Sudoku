//
//  gamestateDeliveryBoy.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 26/11/16.
//  Copyright © 2016 Jeremy Doneghue. All rights reserved.
//

import Foundation

class GamestateDeliveryBoy {
    
    private var sudokuBoxSelected: Bool = false
    private var keypadNumberSelected: Bool = false
    private var numberToPass: Int = 0
    private var numberPadRef: numberPad?
    private var sudokuBoardRef: sudokuBoard?
    
    required init?() { }
        
    public func setNumberToPass(value: Int) {
        self.numberToPass = value
    }
    
    public func getNumberToPass() -> Int {
        return numberToPass
    }
    
    public func getReady() -> Bool {
        return sudokuBoxSelected && keypadNumberSelected
    }
    
    public func setKeypadNumberSelected(state: Bool) {
        keypadNumberSelected = state
    }
    
    public func setSudokuBoxSelected(state: Bool) {
        sudokuBoxSelected = state
    }
    
    public func selectedStates() -> (Bool, Bool) {
        return (keypadNumberSelected, sudokuBoxSelected)
    }
    
    // MARK: Game interactions
    
    func setValueAtHighlightedSudokuCell() {
        sudokuBoardRef?.setValueAtHighlightedCell(value: numberToPass)
    }
    
    // MARK: Game object references
    
    public func setNumberPad(np: numberPad) {
        self.numberPadRef = np
    }
    
    public func setSudokuBoardRef(sb: sudokuBoard) {
        self.sudokuBoardRef = sb
    }
    
    public func reset() {
        numberToPass = 0
        sudokuBoxSelected = false
        keypadNumberSelected = false
        numberPadRef!.reset()
    }
    
    
    
}
