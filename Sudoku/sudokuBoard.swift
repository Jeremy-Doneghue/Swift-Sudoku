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
    
    let sampleGame: String = "604000023|207308610|008906700|040502130|900000500|500074290|102009360|069000070|430617900"
    
    // 2D Array of Integers storing the current state of the game.
    var values = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    
    // 2D Array of Booleans storing which cells in values (above) are read only. true = read only cell.
    var readOnlyCells = [[Bool]](repeating: [Bool](repeating: false, count: 9), count: 9)
    
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
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSFontAttributeName: font
        ]
        
        let stringSize = text.size(attributes: (attributes as! [String : Any]))
        let centeredRect = CGRect(
            x: rect.origin.x + (rect.width - stringSize.width) / 2,
            y: rect.origin.y + (rect.height - stringSize.height) / 2,
            width: stringSize.width,
            height: stringSize.height
        )

        
        
        text.draw(in: centeredRect, withAttributes: (attributes as! [String : Any]))
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
            if line.characters.count != Int(sudokuSize) {
                valid = false
            }
        }
        
        // Enter the numbers into the array
        if valid {
            for i in 0..<Int(sudokuSize) {
                let rowChars = [Character](lines[i].characters)
                
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
    func viewIsTapped(_ sender:UITapGestureRecognizer) {
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
            values[mostRecentCellTap.1][mostRecentCellTap.0] = value
            boxesFilled += 1  // Increment global box filled counter
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
            
            // Decrement global box filled counter (kindof a hack, setValueAtHighlightedCell() increments the counter by 1, 
            // even though we are technically removing a number. oh well this works.
            boxesFilled -= 2
        }
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
        var boxesToTest = [(Int, Int)]()       // Array of indexes to empty boxes
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
                
                if numSolved == numToSolve {
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
                        boxesFilled += 1            //Increment global counter for boxes filled
                        self.setNeedsDisplay()      // Update the display with the new values
                    }
                }
                
                numValidPlacements = 0
            }
            
            // Reset boxes to test and existing values
            boxesToTest = [(Int, Int)]()
            existingValuesInSubGrid = [Int]()
        }
        
        if boxesFilled < numToSolve {
            solve(numToSolve: numToSolve - (numSolved - initialSolved))
        }
    }
}
