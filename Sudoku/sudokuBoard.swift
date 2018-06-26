//
//  sudokuBoard.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 21/11/16.
//  Copyright © 2016 Jeremy Doneghue. All rights reserved.
//

import UIKit

class sudokuBoard: UIView {
    
    // MARK: Properties
    
    //GamestateDeliveryBoy -- An object used to pass information between the sudoku board and the input pad.
    var gsdb: GamestateDeliveryBoy = GamestateDeliveryBoy()!
    
    /*
     * Pass in the reference to the GamestateDeliveryBoy (gsdb)
     */
    func setGameStateDeliveryBoy(boy: GamestateDeliveryBoy) {
        self.gsdb = boy
        self.gsdb.setSudokuBoardRef(sb: self)
    }
    
    // A flag signifing whether or not the game is completely instantiated yet.
    var gameReady = false
    var isReady: Bool {
        get { return gameReady }
    }
    
    // A flag signifing whether or not a square on the board has been selected.
    var buttonSelected = false
    var selected: Bool {
        get { return buttonSelected }
    }
    
    let fontSize: CGFloat = 26
    
    //let sampleGame: String = "080065709|740903020|539782410|263801097|801509040|495300200|007158060|610230058|300094100"  // super easy 50
    //let sampleGame: String = "604000023|207308610|008906700|040502130|900000500|500074290|102009360|069000070|430617900"  // easy 40
    let sampleGame: String = "007040283|000570900|021080050|603090700|908305400|000700008|700050030|000167802|160208500"  // 36
    //let sampleGame: String = "098325000|450700008|700410000|980000200|000900410|100050000|000002745|073009600|064070032"  // moderate 33
    //let sampleGame: String = "103092000|205700190|000003000|900000040|030027000|000050207|000280050|000000030|040000976"  // hard 26
    //let sampleGame: String = "000000064|000000000|050008000|020070890|000010000|380469002|006930000|000006500|010000200"  // Very hard 22
    //let sampleGame: String = "900000500|230000000|000800306|000500000|046900008|000000034|000024000|002003000|009000001"  // Very hard 20
    //let sampleGame: String = "020000030|000007000|600004000|000402800|093000000|005000060|000900357|700000400|000030000"  // Very hard 19 - solved in 11s
    //let sampleGame: String = "306000000|009000010|000700004|040000000|800500000|000000930|000039008|060000007|000010000"  // extreme 17 - unknown time to solve
    //let sampleGame: String = "000700000|100000000|000430200|000000006|000509000|000000418|000081000|002000050|040000300" // 17
    
    // 2D Array of Integers storing the current state of the game.
    var values = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    
    // 2D Array of Booleans storing which cells in values (above) are read only. true = read only cell.
    var readOnlyCells = [[Bool]](repeating: [Bool](repeating: false, count: 9), count: 9)
    
    var solvedValues = [[Int]]()
    
    // 2D Array of Rectangles for drawing the sudoku grid.
    var innerRectangles = [[CGRect?]](repeating: [CGRect?](repeating: nil, count: 9), count: 9)

    var buttonWidth: CGFloat = 0
    var buttonHeight: CGFloat = 0
    let outerLineWidth: CGFloat = 6
    let innerBoxLineWidth: CGFloat = 1
    
    let sudokuSize: CGFloat = 9
    
    var _WIDTH: CGFloat = 0
    var _HEIGHT: CGFloat = 0
    
    var mostRecentCellTap: (x: Int, y: Int) = (-1, -1)
    
    //var complete: Bool = false
    var boxesFilled: Int = 0
    
    
    // MARK: Initialisation
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonWidth = self.bounds.width / sudokuSize
        buttonHeight = self.bounds.height / sudokuSize
        
        _WIDTH = self.bounds.width
        _HEIGHT = self.bounds.height
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(sudokuBoard.viewIsTapped(_:)))
        self.addGestureRecognizer(gesture)
        
        parseGame(game: sampleGame)
        gameReady = true
    }
    
    // MARK: Drawing
    
    /*
     * Draw the view
     */
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.black.cgColor)
        
        //Highlight cell
        if mostRecentCellTap != (-1, -1) {
            ctx?.setFillColor(UIColor.gray.cgColor)
            ctx?.fill(innerRectangles[mostRecentCellTap.x][mostRecentCellTap.y]!)
        }
        
        //outer rectangle
        let outerRect = CGRect(x: 0, y: 0, width: _WIDTH, height: _HEIGHT)
        ctx?.setLineWidth(outerLineWidth)
        ctx?.stroke(outerRect)
        
        //inner rectangles
        ctx?.setLineWidth(innerBoxLineWidth)
        for column in 0..<innerRectangles.count {
            for row in 0..<innerRectangles.count {
                innerRectangles[column][row] = CGRect(x: CGFloat(column) * buttonWidth, y: CGFloat(row) * buttonHeight, width: buttonWidth, height: buttonHeight)
                ctx?.stroke(innerRectangles[column][row]!)
            }
        }
        
        //TicTacToe dividers
        for column in 1...3 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: buttonWidth * CGFloat(3 * column), y: 0))
            path.addLine(to: CGPoint(x: buttonWidth * CGFloat(3 * column), y: _HEIGHT))
            path.close()
            path.lineWidth = outerLineWidth / 2
            path.stroke()
        }
        for row in 1...3 {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: buttonHeight * CGFloat(3 * row)))
            path.addLine(to: CGPoint(x: _WIDTH, y: buttonHeight * CGFloat(3 * row)))
            path.close()
            path.lineWidth = outerLineWidth / 2
            path.stroke()
        }
        
        // Render text
        var numStr: String = "0"
        for column in 0..<values.count {
            for row in 0..<values.count {
                
                if values[column][row] != 0 {
                    numStr = String(values[column][row])
                    
                    if readOnlyCells[column][row] == true {
                        drawText(rect: innerRectangles[row][column]!, text: numStr, font: UIFont.systemFont(ofSize: fontSize), color: UIColor.black)
                    }
                    else {
                        // If the move is legal, draw the number in blue
                        if verifyMoveLegality(index: (column, row)) {
                            drawText(rect: innerRectangles[row][column]!, text: numStr, font: UIFont.init(name: "Noteworthy-Bold" , size: 17)!, color: UIColor.blue)
                        }
                        // Else still draw the number, but put it in red.
                        else {
                            drawText(rect: innerRectangles[row][column]!, text: numStr, font: UIFont.init(name: "Noteworthy-Bold" , size: 17)!, color: UIColor.red)
                        }
                    }
                }
            }
        }
        print("Boxes filled: \(boxesFilled)")
        
        if boxesFilled == 81 {
            // TODO: Have a congratulations message!
        }
    }
    
    
    /*
     * Draw text into the specified rectangle with the specified font.
     */
    func drawText(rect: CGRect, text: String, font: UIFont, color: UIColor) {
        
        //set text color to white
        let textColor: UIColor = color
        
        // set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.center
        
        let attributes: NSDictionary = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paraStyle,
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font
        ]
        
        let stringSize = text.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary((attributes as! [String : Any])))
        let centeredRect = CGRect(
            x: rect.origin.x + (rect.width - stringSize.width) / 2,
            y: rect.origin.y + (rect.height - stringSize.height) / 2,
            width: stringSize.width,
            height: stringSize.height
        )

        
        
        text.draw(in: centeredRect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary((attributes as! [String : Any])))
    }
    
    // MARK: Numbers
    
    /*
     * Parse in values from a string in the format 820400120| x 9 - where 0 = empty square
     */
    func parseGame(game: String) {
        
        let lines: [String] = game.components(separatedBy: "|")
        print(lines)
        
        //check each line contains the correct number of characters
        var valid = true
        for line in lines {
            if line.count != Int(sudokuSize) {
                valid = false
            }
        }
        
        // Enter the numbers into the array
        if valid {
            for i in 0..<Int(sudokuSize) {
                let rowChars = Array(lines[i])
                
                for j in 0..<Int(sudokuSize) {
                    let toAdd = Int("\(rowChars[j])")!
                    values[i][j] = toAdd
                    
                    // if the number to add in the cell in not blank (0), set that cell to read only so that it can't be overwritten by the player later.
                    if toAdd != 0 {
                        readOnlyCells[i][j] = true
                        boxesFilled += 1
                    }
                }
            }
        }
        
        if valid {
            //Deubug output
            //print("Sudoku game is valid")
            //print(values)
            //print(readOnlyCells)
        }
        else { print("Game is invalid, contains contraditions") }
    }
    
    // MARK: Interaction
    
    
    /*
     * This function is called whenever the view is tapped.
     * Identifies the cell that has been tapped, checks whether the cell is read only.
     * Sets the value in the higlighted cell if the game is ready.
     */
    @objc func viewIsTapped(_ sender:UITapGestureRecognizer) {
        let location = sender.location(in: self)
        
        var cellX: CGFloat = 0
        var cellY: CGFloat = 0
        var xCellIndex = 0
        var yCellIndex = 0
        
        while cellX < location.x {
            cellX += buttonWidth
            xCellIndex += 1
        }
        while cellY < location.y {
            cellY += buttonHeight
            yCellIndex += 1
        }
        
        // Check whether the cell is read only before trying to select it
        if readOnlyCells[yCellIndex - 1][xCellIndex - 1] == false {
            mostRecentCellTap = (x: xCellIndex - 1, y: yCellIndex - 1)
            print("Mostrecent celltap set: \(mostRecentCellTap)")
            
            // Update GamestateDeliveryBoy
            gsdb.setSudokuBoxSelected(state: true)
            
            print("numpad ready: \(gsdb.selectedStates().0) sudoku ready: \(gsdb.selectedStates().1)")
            
            if (gsdb.getReady()) {
                setValueAtHighlightedCell(value: gsdb.getNumberToPass())
                gsdb.reset()
            }
            self.setNeedsDisplay()
        }
        
        // Debug output
        print("You tapped cell at: [\(yCellIndex), \(xCellIndex)]. Cell is \(readOnlyCells[yCellIndex - 1][xCellIndex - 1] ? "" : "not ")read only.\nIt has the value: \(values[yCellIndex - 1][xCellIndex - 1])")
    }
    
    /*
     * Set the value in the selected to the given value
     */
    public func setValueAtHighlightedCell(value: Int) {
        
        if gameReady && value <= Int(sudokuSize) && mostRecentCellTap.0 != -1 && mostRecentCellTap.1 != -1{
            
            let previousValue = values[mostRecentCellTap.1][mostRecentCellTap.0]
            
            values[mostRecentCellTap.1][mostRecentCellTap.0] = value // Update to new value
            
            // If we're setting a blank cell to a number, then a new box is filled
            if previousValue == 0 && value != 0 {
                boxesFilled += 1  // Increment global box filled counter
            }
            // If we're setting a previously filled box to empty, subtract from boxes filled
            else if previousValue != 0 && value == 0 {
                boxesFilled -= 1
            }
            
            self.setNeedsDisplay()
            self.reset()
        }
    }
    
    /*
     * Set the value in the selected cell back to zero
     */
    public func clearSelectedCell() {
        
        if mostRecentCellTap.0 != -1 && mostRecentCellTap.1 != -1 {
            setValueAtHighlightedCell(value: 0)
        }
    }
    
    public func resetGame() {
        for c in 0..<Int(sudokuSize) {
            for r in 0..<Int(sudokuSize) {
                if readOnlyCells[c][r] != true {
                    values[c][r] = 0;
                    boxesFilled -= 1;
                }
            }
        }
        self.setNeedsDisplay()
    }
    
    /*
     * Set the game back to a state where it can recieve the next interaction
     */
    public func reset() {
        
        self.mostRecentCellTap = (-1, -1)
        gsdb.setSudokuBoxSelected(state: false)
    }
    
    // MARK: Verification
    
    /*
     * Verify the legality of a number inserted at a particular index
     */
    func verifyMoveLegality(index: (Int, Int)) -> Bool {
        
        return verifyMoveLegality(index: index, array: values)
    }
    
    /*
     * Verify the legality of a number inserted at a particular index
     * Overload where the you can specify the array (used in the solver function)
     */
    func verifyMoveLegality(index: (Int, Int), array: [[Int]]) -> Bool {
        
        let number = array[index.0][index.1]
        var valid = true
        
        // Check number isn't repeated in the row
        for i in 0..<Int(sudokuSize) {
            if array[index.0][i] == number && i != index.1 {
                valid = false
                break
            }
        }
        
        // Some optimization: Only do this if an error has not yet been found
        if valid {
            // Check number isn't repeated in the column
            for i in 0..<Int(sudokuSize) {
                if array[i][index.1] == number && i != index.0 {
                    valid = false
                    break
                }
            }
        }
        
        // Some optimization: Only do this if an error has not yet been found
        if valid {
            // Check the number isn't repeated in the local grid
            
            // Find which mini grid the selection is in
            var localGridIdentifier = (-1, -1)
            
            if index.0 < 3 { localGridIdentifier.0 = 1 }
            else if index.0 < 6 { localGridIdentifier.0 = 2 }
            else if index.0 < 9 { localGridIdentifier.0 = 3 }
            
            if index.1 < 3 { localGridIdentifier.1 = 1 }
            else if index.1 < 6 { localGridIdentifier.1 = 2 }
            else if index.1 < 9 { localGridIdentifier.1 = 3 }
            
            for row in localGridIdentifier.0 * 3 - 3..<localGridIdentifier.0 * 3{
                for column in localGridIdentifier.1 * 3 - 3..<localGridIdentifier.1 * 3{
                    if array[row][column] == number && (row, column) != index {
                        valid = false
                        //print("invalid: grid")
                        break
                    }
                }
            }
        }
        
        //print("Move is \(valid ? "" : "not ")valid - \(number) at \(index)")
        return valid
    }
    
    
    
    // MARK: Solver
    
    
    /*
     * Find the next move if the player is stuck
     */
    func hint() {
        solve(numToSolve: 1)
    }
    
    func solve(numToSolve: Int) {
        
        // If the puzzle is already complete, save time and do nothing
        if boxesFilled >= 81 {
            return
        }
        
        // The number of boxes solved in this call of solve()
        var numSolved = 0
        
        // The initial number of boxes solved in the game
        let initialSolved = boxesFilled
        
        //Make a new copy of the game array
        var newArray = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for row in 0..<values.count {
            for column in 0..<values.count {
                newArray[row][column] = values[row][column]
            }
        }
        
        let subgrids = [(1, 1), (1, 2), (1,3), (2,1), (2,2), (2,3), (3,1), (3,2), (3,3)]  // Values to multiply to find the real indexes of points in subgrids
        var boxesToTest = [(Int, Int)]()       // Array of indexes to empty boxes in the subgrid
        var existingValuesInSubGrid = [Int]()  // Array of numbers that already are already set in a subgrid
            
        for localGridIdentifier in subgrids {
            
            // Get the info about the local grid that we need
            for row in localGridIdentifier.0 * 3 - 3..<localGridIdentifier.0 * 3 {
                for column in localGridIdentifier.1 * 3 - 3..<localGridIdentifier.1 * 3 {
                    //print(newArray[row][column])
                    
                    // Identify empty boxes in this subgrid
                    if newArray[row][column] == 0 {
                        boxesToTest.append((row, column))
                    }
                    else {
                        // Add to the array of numbers already in the subgrid
                        existingValuesInSubGrid.append(newArray[row][column])
                    }
                }
            }
            
            // The index to the box to place the next value if one is found
            var validPlacementIndex: (Int, Int) = (-1, -1)
            
            // The number of valid placements in the subgrid for a number between 1 and 9 (inclusive), if this is 1, then that is the correct value for the box.
            var numValidPlacements = 0
            
            for i in 1...9 {                                                    // For each number
                
                if numSolved == numToSolve {                                    // Break if we've solved the number of boxes we were asked to
                    break
                }
                
                for box in boxesToTest {                                        // For each empty box in the subgrid
                    if !existingValuesInSubGrid.contains(i) {                   // If i does not already exist in the subgrid
                        newArray[box.0][box.1] = i                              // Place i in the box
                        if verifyMoveLegality(index: box, array: newArray) {    // If number i in that box is a valid move, then...
                            numValidPlacements += 1                             // Increment the number of valid placements for i in the subgrid
                            validPlacementIndex = box                           // Keep a record of which box that was in
                        }
                        newArray[box.0][box.1] = 0
                    }
                }
                
                if numValidPlacements != 0 {
                    //print("Num valid placements for \(i) in \(localGridIdentifier): \(numValidPlacements)")
                    
                    // If there is only 1 valid placement for i in the subgrid, it must be the solution for that box
                    if numValidPlacements == 1 {
                        newArray[validPlacementIndex.0][validPlacementIndex.1] = i //Update the solver's copy of game state and the main state
                        values[validPlacementIndex.0][validPlacementIndex.1] = i
                        numSolved += 1
                        boxesFilled += 1            // Increment global counter for boxes filled
                        self.setNeedsDisplay()      // Update the display with the new values
                    }
                }
                
                numValidPlacements = 0
            }
            
            // Reset boxes to test and existing values
            boxesToTest = [(Int, Int)]()
            existingValuesInSubGrid = [Int]()
        }
        
        if boxesFilled == initialSolved {
            print("could not find next move, trying recursive backtracking algorithm")
            solve()
            return
        }
        
        if boxesFilled < numToSolve {
            solve(numToSolve: numToSolve - (numSolved - initialSolved))
        }
    }
    
    // MARK: Backtrack Solve
    
    var tries = 0
    
    var backtrackArray = [[Int]]()
    func solve() {
        
        //solve(numToSolve: 81)
        
        backtrackArray = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
        for row in 0..<values.count {
            for column in 0..<values.count {
                backtrackArray[row][column] = values[row][column]
            }
        }
        
        if solveBacktrack(array: &backtrackArray) {
            values = backtrackArray
            print("recursive solve was a success")
            print(tries)
            self.setNeedsDisplay()
        }
        else {
            print("could not find a solution in a reasonable amount of time")
            print(tries)
        }
    }
    
    func solveBacktrack(array: inout [[Int]]) -> Bool {
        
        tries += 1
        if tries > 500000 {
            return false
        }
        
        var pt = (0, 0)
        if !FindUnassignedLocation(foundPoint: &pt) {
            return true  //Success
        }
        
        for i in 1...9 {
            
            array[pt.0][pt.1] = i
            if verifyMoveLegality(index: pt, array: array) {
                
                if solveBacktrack(array: &array) {
                    return true
                }
            
                //Failure, revert
                array[pt.0][pt.1] = 0
            }
            else {
                array[pt.0][pt.1] = 0
            }
        }
        return false
    }
    
    func FindUnassignedLocation(foundPoint: inout (Int, Int)) -> Bool {
        
        for row in 0..<Int(sudokuSize) {
            for col in 0..<Int(sudokuSize) {
                if backtrackArray[row][col] == 0 {
                    foundPoint.0 = row
                    foundPoint.1 = col
                    return true
                }
            }
        }
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
