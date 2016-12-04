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
                        drawText(rect: innerRectangles[row][column]!, text: numStr, font: UIFont.init(name: "Noteworthy-Bold" , size: 17)!, color: UIColor.blue)
                    }
                }
            }
        }
//        print(values)
//        print(readOnlyCells)
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
        
        // set the Obliqueness to 0
        let skew = 0
        
        let attributes: NSDictionary = [
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: font
        ]
        
        text.draw(in: rect, withAttributes: (attributes as! [String : Any]))
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
        
        if valid {
            print("Sudoku game is valid")
            
            for i in 0..<Int(sudokuSize) {
                let rowChars = [Character](lines[i].characters)
                
                for j in 0..<Int(sudokuSize) {
                    let toAdd = Int("\(rowChars[j])")!
                    // TODO: WIP
                    values[i][j] = toAdd
                    
                    // if the number to add in the cell in not blank (0), set that cell to read only so that it can't be overwritten by the player later.
                    if toAdd != 0 {
                        readOnlyCells[i][j] = true
                    }
                }
            }
        }
        print(values)
        print(readOnlyCells)
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
            // TODO: Put the verification thing here
            values[mostRecentCellTap.1][mostRecentCellTap.0] = value
            self.reset()
            self.setNeedsDisplay()
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
    
    /*
     * Set the game back to a state where it can recieve the next interaction
     */
    public func reset() {
        
        self.mostRecentCellTap = (-1, -1)
        gsdb.setSudokuBoxSelected(state: false)
    }
    
    // MARK: Verification
    
    func verifyMoveLegality(index: (Int, Int)) -> Bool {
        
        let number = values[index.0][index.1]
        var valid = true
        
        //Check number isn't repeated in the row
        for i in 0..<Int(sudokuSize) {
            
            if values[index.0][i] == number && i != index.1 {
                valid = false
                break
            }
        }
        
        print("Move is \(valid ? "" : "not ")valid")
        return valid
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
